# XVERSE 3D-GS Training

<a href="./LICENSE">
        <img alt="License" src="https://img.shields.io/badge/License-Apache_2.0-blue.svg"></a>

[English](./README.md) | 中文

[
  <img src="../UEPlugin/Media/image/XVERSE.jpg" width="600" />
](http://xverse.cn/)


# 介绍
我们提供基于原版3DGS的训练方法以及有效的后处理方案，让大家能够以最简单的方式进行训练。当然，你也可以通过修改训练参数来达到你想要的效果。

# 安装
```shell
conda env create --file environment.yml
conda activate gaussian_splatting

cd submodules/
python ./diff-gaussian-rasterization/setup.py install
python ./simple-knn/setup.py install
python ./fused-ssim/setup.py install
```

# 训练
我们尽量简化训练的输入参数，您只需提供一个视频或者一组图片，即可直接通过如下脚本完成训练。
```shell
cd gaussian-splatting
# fps=0.5 means that the video takes one frame every two seconds
python run.py --video_path /path/of/video --fps 0.5
or
python run.py --image_path /path/of/images

```
## 训练加速
由于我们的方法基于原始的 gaussian-splatting，因此我们也支持训练加速。
```shell
--optimizer_type sparse_adam
```

## 后处理
为了减少异常值和漂浮物，从而提升渲染质量，我们使用 [3dconverter](https://github.com/francescofugazzi/3dgsconverter.git) 对其进行了后处理。值得注意的是，这种方法在去除物体的漂浮物方面更为有效，但很容易意外删除场景的主要结构。因此，我们建议您仅对物体使用此后处理方法。
```shell
--post_process
```

## 程序打包
我们在[pack.py](gaussian-splatting/pack.py)中提供了打包程序，你可以将从视频或图片到获取3DGS模型的整个流程打包为可执行文件
```shell
python pack.py
```
