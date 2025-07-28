# XVERSE 3D-GS Training

<a href="./LICENSE">
        <img alt="License" src="https://img.shields.io/badge/License-Apache_2.0-blue.svg"></a>

English | [中文](./README_CN.md)

[
  <img src="../UEPlugin//Media/image/XVERSE.jpg" width="600" />
](http://xverse.cn/)


# Introduction
We provide a training method based on the original 3DGS and an effective post-processing solution, so that everyone can train in the simplest way. Of course, you can also modify the parameters to achieve the results you want.

# Installation
```shell
conda env create --file environment.yml
conda activate gaussian_splatting

cd submodules/
python ./diff-gaussian-rasterization/setup.py install
python ./simple-knn/setup.py install
python ./fused-ssim/setup.py install
```

# Training
We try to simplify the input parameters of training. You only need to provide a video or a set of pictures to complete the training directly through the following script.
```shell
cd gaussian-splatting
# fps=0.5 means that the video takes one frame every two seconds
python run.py --video_path /path/of/video --fps 0.5
or
python run.py --image_path /path/of/images

```
## Training speed acceleration
Since our method is based on the original gaussian-splatting, we also support training acceleration.
```shell
--optimizer_type sparse_adam
```

## Postprocess
To reduce outliers and floaters to improve rendering quality, We post-processed it through [3dconverter](https://github.com/francescofugazzi/3dgsconverter.git). It is worth noting that this method is more effective in removing floaters of objects, but it is easy to accidentally delete the main structure of the scene. Therefore we recommend that you use this post-processing method only for objects.
```shell
--post_process
```

## Program Packaging
We provide a packaging program in [pack.py](gaussian-splatting/pack.py), you can package the entire process from video or image to 3DGS model into an executable file.
```shell
python pack.py
```
