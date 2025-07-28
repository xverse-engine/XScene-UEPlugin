import os
import torch
from random import randint
from utils.loss_utils import l1_loss, ssim
from gaussian_renderer import render, network_gui
import sys
import logging
import subprocess
from scene import Scene, GaussianModel
from utils.general_utils import safe_state
import uuid
import time
from tqdm import tqdm
from utils.image_utils import psnr
from utils.video_utils import extract_frames, get_parent_directory
from utils.colmap_utils import run_colmap
from train import training
from argparse import ArgumentParser, Namespace
from arguments import ModelParams, PipelineParams, OptimizationParams
import re
from datetime import datetime
import shutil


if __name__ == "__main__":
    # Set up command line argument parser
    parser = ArgumentParser(description="Training script parameters")
    lp = ModelParams(parser)
    op = OptimizationParams(parser)
    pp = PipelineParams(parser)
    parser.add_argument('--ip', type=str, default="127.0.0.1")
    parser.add_argument('--port', type=int, default=6009)
    parser.add_argument('--debug_from', type=int, default=-1)
    parser.add_argument('--detect_anomaly', action='store_true', default=False)
    parser.add_argument("--test_iterations", nargs="+", type=int, default=[7_000, 30_000])
    parser.add_argument("--save_iterations", nargs="+", type=int, default=[7_000, 30_000])
    parser.add_argument("--quiet", action="store_true")
    parser.add_argument("--checkpoint_iterations", nargs="+", type=int, default=[7_000, 30_000])
    parser.add_argument("--start_checkpoint", type=str, default = None)
    parser.add_argument("--video_path", type=str, default = None)
    parser.add_argument("--image_path", type=str, default = None)
    parser.add_argument("--fps", type=float, default = 0.5)

    parser.add_argument("--gsconverter",  type=str, default = "3dgsconverter")
    parser.add_argument("--colmap_path", type=str, default = "colmap")
    parser.add_argument("--camera_type", type=str, default = "PINHOLE", choices=["PINHOLE", "SIMPLE_PINHOLE", "RADIAL", "SIMPLE_RADIAL", "OPENCV", "FULL_OPENCV"])
    parser.add_argument("--no_single_camera", action='store_true', default=False) # 采用单个镜头
    parser.add_argument("--force_colmap", action='store_true', default=False)  # 强制重新跑colmap
    parser.add_argument("--input_colmap",  type=str, default = None) 
    parser.add_argument("--post_process", action='store_true', default=False)
    parser.add_argument("--gpu", type=str, default = "0")
    parser.add_argument("--logpath",  type=str, default ="")
    

    args = parser.parse_args(sys.argv[1:])
    args.save_iterations.append(args.iterations)

    if args.model_path == "":
        current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
        args.model_path = f"output/{current_time}"

    os.makedirs(args.model_path, exist_ok=True)
    if args.logpath == "":
        args.logpath = os.path.join(args.model_path, "train.log" )

    logging.basicConfig(
        level=logging.INFO,  # 设置日志级别
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',  # 日志格式
        handlers=[
            logging.FileHandler( args.logpath ),  # 输出到文件
            logging.StreamHandler()  # 输出到控制台
        ]
    )

    if args.input_colmap == None:
        if args.video_path != None:
            assert os.path.isfile(args.video_path), "确保输入地址为视频文件"
        if args.image_path != None:
            assert os.path.isdir(args.image_path), "确保输入地址为图像所在文件夹"
        assert (args.video_path != None and args.image_path == None) or (args.video_path == None and args.image_path != None), "确保仅提供视频路径或者图像路径"
        
        ## 兜底一些异常数据
        args.iterations = max( int(args.iterations), 100)
        args.sh_degree = max(min( int(args.sh_degree), 3), 0)
        args.fps = max(args.fps, 0.0001) # fps至少大于0

        export_path = os.path.join( args.model_path )
        # 创建输出路径
        os.makedirs(args.model_path, exist_ok=True)

        ## 存储给
        img_path_name = "images"

        # 视频取帧
        logging.info("EXTRACTING IMAGE FRAMES...")
        
        if args.video_path != None:
            scene_folder = extract_frames(args.video_path, img_path_name = img_path_name, fps=args.fps, export_path = export_path, force_colmap=args.force_colmap)
        else:
            # args.image_path 中的所有图片，都需要放到 os.path.join(scene_folder, "images" ) 中
            scene_folder = export_path # 
            targetPath = os.path.join(scene_folder, img_path_name )
            if os.path.exists(scene_folder):
                shutil.rmtree(scene_folder)
            shutil.copytree( args.image_path, targetPath )

        
        logging.info("====================================================")
        logging.info("Export colmap result in: {}".format(scene_folder) )
            
        
        # 执行colmap
        logging.info("DOING COLMAP...")
        if os.path.exists(os.path.join(scene_folder, "sparse")): # type: ignore
            logging.info("Use Cache COLMAP RESULT")
        else:
            run_colmap(scene_folder, img_path=img_path_name, camera_type=args.camera_type, gpu=args.gpu, colmap_exe=args.colmap_path, single_camera=args.no_single_camera==False) # type: ignore
        if os.path.exists(os.path.join(scene_folder, "sparse", "1")): # type: ignore
            shutil.rmtree(os.path.join(scene_folder, "sparse", "0")) # type: ignore
            os.rename(os.path.join(scene_folder, "sparse", "1"), os.path.join(scene_folder, "sparse", "0")) # type: ignore
        args.source_path = scene_folder
    else:
        assert os.path.exists(os.path.join(args.input_colmap, "sparse")), "确保输入的COLMAP结果里包含sparse文件夹"
        args.source_path = args.input_colmap
        
    
    # 执行训练
    logging.info("TRAINING...")
    print("Optimizing " + args.model_path)

    # Initialize system state (RNG)
    safe_state(args.quiet)

    # Start GUI server, configure and run training
    network_gui.init(args.ip, args.port)
    torch.autograd.set_detect_anomaly(args.detect_anomaly)
    training(lp.extract(args), op.extract(args), pp.extract(args), args.test_iterations, args.save_iterations, args.checkpoint_iterations, args.start_checkpoint, args.debug_from)

    # All done
    logging.info("\nTraining complete.")
    
    # 执行后处理
    logging.info("POSTPROCESSING...")
    logging.info("This post-processing can effectively remove floaters and enhance rendering effects. It is only recommended for object instances, not for scene instances.")
    if args.post_process:
        output_dir = args.model_path
        input_ply = os.path.join(output_dir, "point_cloud", f"iteration_{args.iterations}", "point_cloud.ply")
        mid_ply = input_ply.replace("point_cloud.ply", "point_cloud_mid.ply")
        output_ply = input_ply.replace("point_cloud.ply", "point_cloud_rm_floaters.ply")
        subprocess.run([
            args.gsconverter, "--input", f"{input_ply}", "--output", f"{mid_ply}", "--target_format", "cc", "--remove_flyers"
        ], check=True)
        subprocess.run([
            args.gsconverter, "--input", f"{mid_ply}", "--output", f"{output_ply}", "--target_format", "3dgs"
        ], check=True)
        logging.info(f"Point Cloud after Remove Floaters Save to {output_ply}")
        os.remove(mid_ply)
    
    