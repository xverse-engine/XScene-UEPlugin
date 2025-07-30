# XScene-UEPlugin

<a href="./LICENSE">
        <img alt="License" src="https://img.shields.io/badge/License-Apache_2.0-blue.svg"></a>

English | [中文](./README_CN.md)

[
  <img src="Media/image/XVERSE.jpg" width="600" />
](http://xverse.cn/)


# Introduction

XScene-UEPlugin is an Unreal Engine 5 (UE5) based plugin developed by XVERSE Technology Inc. (Shenzhen, China), aiming to provide real-time visualization, management, editing, and scalable hybrid rendering of Gaussian Splatting model, which is a recently arised technique for reconstructing 3D scenes from multiple photos, more details can refer to [here](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/).

Currently, our plugin is implemented based on UE5 Niagara, fully exploiting the advantage of the features provided by UE5 to realize efficient rendering and managing for Guassian Splatting models.

Since we are at early access, current accessible features are summarized below:
- Niagara-Based High-quality real-time visualizing and rendering for 3D Gaussian Splatting
- Easily importing and converting from the original Gaussian Splatting scene (.ply file) to ours
- Hybrid rendering with other UE assets 
- RTS and volume based crop
- Crop a pure niagara for VFX
- Support dynamic illumination of Gaussian Splatting scene
- Automatic lod generation, supporting over 200,000 point clouds in niagara
- **_Training tools in Windows system (XV3DTools)_**： train a given mp4 video to GaussianSplatting ply file


# Getting Started

## Video Tutorial

Youtube（English）：  
- [[Free 3DGS Tutorial] 3D Gaussian Splatting in Unreal Engine 5 for Beginners ](https://www.youtube.com/watch?v=ohU4qo-7jJo) 
- [[Free 3DGS Tutorial] Make your 3D Gaussian Splatting easily -Turning a VIDEO into 3D](https://www.youtube.com/watch?v=yFC6SipFtyo&t=115s) 
- [[Free 3DGS Tutorial] 3D Gaussian Splatting + VFX is AWESOME！](https://www.youtube.com/watch?v=RHdLI34GD1s) 

B站（中文）：  
- [[3DGS教程] 使用免费插件在UE5上轻松玩转3D Gaussian Splatting](https://www.bilibili.com/video/BV1ei4y1W73Y/)
- [[3DGS教程] 将场景视频（.mp4）转为3D模型（.ply）的免费工具](https://www.bilibili.com/video/BV1jW4y1F7SR/)
- [[3DGS教程] 3D Gaussian Splatting + VFX 打造惊艳特效！](https://www.bilibili.com/video/BV1xW4y1F7N7/)

## System Requirements

- Windows 10 or 11
- Unreal Engine 5.1.x / 5.2.x / 5.3.x / 5.4.x / 5.5.x
- cuda11 or higher (if using the XV3DTools)


## Plugin download

  1. Open github Release page 

  <img src="Plugins/Media/a1.jpg" width="500" />

  2. Download the zip corresponding to the UE version you are using

  <img src="Plugins/Media/a2.jpg" width="500" />

  3. Unzip and move folder `XV3dGS` to folder `Plugins`

  <img src="Plugins/Media/a3.jpg" width="500" />


 ## Demo Data Download Links:

We have provided two sets of test data available for download at:
 - [Baidu Pan Download Link](https://pan.baidu.com/s/1-cwEXounPJBNtkJe5PJuSw?pwd=XV3D) 
 - [Google Drive Download Link](https://drive.google.com/drive/folders/1EgVZyYgFbYJqshA6xUheEG7JrEIgsmzR?usp=sharing)



Included in these downloads are `demo_fox_1080p.mp4` and `demo_office_1080p.mp4`, serving as two sample MP4 files for testing XV3DTools' local training capabilities.

`demo_fox_gs.ply` and `demo_office_gs.ply` are 3DGS models trained by XV3DTools, which can be imported into Unreal Engine (UE) using this plugin for real-time rendering.

 <img src="Media/image/t1.jpg" width="500" />

## Open demo project
This repo contains a demo project with an example scene and level

0. download using git clone
```
git clone https://github.com/xverse-engine/XV3DGS-UEPlugin.git
```

1. Open `XV3DGS.uproject` to start UE
2. Open `demo` level

<img src="Media/image/S3.jpg" width="500" />

## Import your guassian splatting model
### **After v1.1.3, this plugin supports dragging multiple ply files directly into the Content Browser and importing them.**

Click on the 'Load Assets' button on the navigation bar or navigate to Window/XV3dgs.
<img src="Media/image/t4.jpg" width="500" />

This action will bring up an integrated tool page by default set to load the PLY page. Click on the 'Load PLY' button.

<img src="Media/image/t3.jpg" width="500" />

This will trigger a resource selection window to appear.

<img src="Media/image/a2.jpg" width="500" />

Choose your Gaussian model file (in .ply format), then it will automaticly generate LOD and loaded into your Content Browser as a blueprint.

<img src="Media/image/a3.jpg" width="500" />

Drag the blueprint into Level Viewport and you can see your Gaussian scene.

<img src="Media/image/a4.jpg" width="500" />


## Local Training on Windows Platform

We develop the XV3DTools to train MP4 videos into Gaussian Splatting ply.
| XV3DGS-UEPlugin Version | XV3DTools Version |
|--|--|
| 1.0.0 ~ 1.1.4 | 1.1.1 |
| 1.1.5 ~ 1.1.5.1 | 1.1.2 |


**_Please Note:_** Installation of CUDA 11 or higher is required. [CUDA Download Link](https://developer.nvidia.com/cuda-downloads)


### XV3DTools Usage Steps:

0. Download XV3DTools tool from the cloud drive to your local machine: 

| XV3DTools Version | Download Link | Preview |
|--|--|--|
| 1.1.1 | [Baidu Pan](https://pan.baidu.com/s/1RA9B4pgn5jgh-lAEoq2nyw?pwd=qabd), [Google Drive](https://drive.google.com/file/d/1o-P5hvNC6W3CH8MklGIZltt_-5yZtyHS/view?usp=sharing) | <img src="Media/image/t10.jpg" width="200" /> |
| 1.1.2 | [Baidu Pan](https://pan.baidu.com/s/1n2B7Yq9LJMeq3THwoC4QQA?pwd=36id), [Google Drive](https://drive.google.com/file/d/1Ed8JG7x5fLNCykj3F7ir8Lp5VT7t_5xT/view?usp=sharing) | <img src="Media/image/xv3dtools-1.1.2.jpg" width="200" />|




  
1. Click on the icon to open the interface and switch to the 'training' page.

<img src="Media/image/t4.jpg" width="500" />

2. Click button to set the parameter "XV3DTools Folder" to the local path where XV3DTools tool is located. The path can only be composed of English words. no chinese words and no special words such as "# $ %".

3. Click button to select the MP4 file for processing and set it as the parameter "Input MP4 Path" (requires video frame rate > 20). The path can only be composed of English words. no chinese words and no special words such as "# $ %".

4. Click button to choose the output folder and set it as the parameter "Output Folder". The path can only be composed of English words. no chinese words and no special words such as "# $ %".

5. click Start Training button.

<img src="Media/image/t6.jpg" width="500" />

6. Training takes time. Once completed, locate the trained ply file in the output folder.

<img src="Media/image/t5.jpg" width="500" />

### Training Speed Reference:
- Test Machine Configuration: Windows 10, CUDA 11.8, GeForce RTX 2080 (8GB VRAM), i9-9900 processor.
- demo_fox.mp4: Video duration of 10 seconds, training time of 5 minutes( extract image with 5fps).
- demo_office.mp4: Video duration of 430 seconds, training time of 40 minutes( extract image with 1fps).





## Packaging UE level for Windows Using Our Plugins

You can refer to the following tutorial to package your own UE levels into exe files that can be run on windows System.

[packing tutorial](Media/Pack.md)

We provide a packaged Windows executable demo, you can download `pack_win_exe.zip` from [release](https://github.com/xverse-engine/XV3DGS-UEPlugin/releases), simply double-click the exe file to start it. 

# Feature Introduction

### RTS (Rotation, Translation, Scaling) Transform
Select the 3D-GS asset and drag it into the scene. then you can Transform it.

<img src="Media/image/FA0.jpg" width="500" />

You can also select a 3D-GS actor in the level viewport and transform it using GIZMO.

<img src="Media/image/a6.gif" width="500" />

### Model Clipping by Gaussian model

1. Click to select your Gaussian model blueprint, then click to select the "Clip Volume Component", and open the "Visible" box in the "Clip Volume Component".

<img src="Media/image/FA1.jpg" width="500" />

2. With the "Clip Volume Component" selected, you can see a crop volume in the window. You can modify the rotation, translation, and scale of the volume by adjusting the Transform attribute. Alternatively, use the keyboard shortcuts WER to visually adjust the GIZMO for rotation, translation, and scale.

<img src="Media/image/FA2.jpg" width="500" />

3. Keep the "Clip Volume Component" selected, and choose different cropping options in the Crop Type. The default state is no cropping, but you can change it to crop the inside or outside of the volume. The example below shows cropping the outside of the volume.

<img src="Media/image/FA3.jpg" width="500" />

4. Click the "Crop GSPoints" button to clip the specified portion and obtain a clean Niagara.

<img src="Media/image/FA4.jpg" width="500" />

5. This clean Niagara can be used for VFX. For more details, please refer to our VFX tutorial (Coming soon).

<img src="Media/image/FA5.jpg" width="500" />

### Dynamic illumination 
Dynamic lighting is not default opened.

you can enable it by turning on the withRelighting button.

<img src="Media/image/FC2.jpg" width="500" />

Supports all the UE light types

<img src="Media/image/FC1.jpg" width="500" />

The light source can be moved at will

<img src="Media/image/FC.gif" width="500" />

### Change color 

Modify the AlbedoTint parameter to change the overall color.

<img src="Media/image/FC3.jpg" width="500" />

<img src="Media/image/FB.gif" width="500" />

### LOD

For imported point clouds, LOD is automatically calculated, with the default being to explicitly display the maximum LOD within the limit of 2 million points for Niagara. The parameter "VisWhichLOD" can be used to force the use of a specific LOD.

<img src="Media/image/FD1.jpg" width="500" />

Dynamic switching of LOD based on the view camera will be supported in future updates.

