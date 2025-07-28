import os
import sys
import time
import threading
import subprocess
import logging

def _run_step_with_timer(cmd, step_name):
    """
    用 subprocess.Popen 启动命令，并在后台线程里每秒打印一次已用时，
    子进程结束后停止线程并返回 CompletedProcess 对象。
    """
    stop_event = threading.Event()

    def _timer():
        start = time.time()
        while not stop_event.is_set():
            elapsed = time.time() - start
            print(f"\r{step_name} — Elapsed: {elapsed:.1f}s", end="", flush=True)
            time.sleep(1)
        # 最后再打印一遍完整耗时
        elapsed = time.time() - start
        print(f"\r{step_name} — Done in {elapsed:.1f}s{' ' * 10}")


    t = threading.Thread(target=_timer, daemon=True)
    t.start()

    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = proc.communicate()

    stop_event.set()
    t.join()

    return proc.returncode, out, err

def run_colmap(dataset_path,
               img_path="images",
               camera_type="PINHOLE",
               gpu="1",
               single_camera=True,
               colmap_exe="colmap"):
    if gpu == "cpu":
        gpu = "-1"
    sc = 1 if single_camera else 0

    steps = [
        ("Feature extraction", [
            colmap_exe, "feature_extractor",
            "--database_path", f"{dataset_path}/database.db",
            "--image_path", f"{dataset_path}/{img_path}",
            "--ImageReader.single_camera", str(sc),
            "--ImageReader.camera_model", camera_type,
            "--SiftExtraction.use_gpu", gpu
        ]),
        ("Feature matching", [
            colmap_exe, "exhaustive_matcher",
            "--database_path", f"{dataset_path}/database.db",
            "--SiftMatching.use_gpu", gpu
        ]),
        ("Mapping", [
            colmap_exe, "mapper",
            "--database_path", f"{dataset_path}/database.db",
            "--image_path", f"{dataset_path}/{img_path}",
            "--output_path", f"{dataset_path}/sparse"
        ]),
        ("Image undistortion", [
            colmap_exe, "image_undistorter",
            "--image_path", f"{dataset_path}/{img_path}",
            "--input_path", f"{dataset_path}/sparse/0",
            "--output_path", f"{dataset_path}/dense",
            "--output_type", "COLMAP"
        ]),
    ]

    os.makedirs(f"{dataset_path}/sparse", exist_ok=True)
    os.makedirs(f"{dataset_path}/dense", exist_ok=True)

    for step_name, cmd in steps:
        logging.info(f"Start: {step_name}")
        code, out, err = _run_step_with_timer(cmd, step_name)
        if code != 0:
            logging.error(f"{step_name} failed (code {code})")
            logging.error(out)
            logging.error(err)
            sys.exit(1)
