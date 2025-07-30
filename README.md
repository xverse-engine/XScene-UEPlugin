# XScene-UEPlugin

<a href="./LICENSE">
        <img alt="License" src="https://img.shields.io/badge/License-Apache_2.0-blue.svg"></a>

English | [中文](./README_CN.md)

[
  <img src="UEPlugin/Media/image/XVERSE.jpg" width="600" />
](http://xverse.cn/)
---

## Table of Contents

- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Training Module](#training-module)
- [UE Plugin](#ue-plugin)
- [Getting Started](#getting-started)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Release Note](#release-note)

---

## Introduction

XScene-UEPlugin is an Unreal Engine 5 (UE5) plugin developed by XVERSE Technology Inc. (Shenzhen, China). It provides real-time visualization, management, editing, and scalable hybrid rendering of Gaussian Splatting models—a novel technique for reconstructing 3D scenes from multi-view photos. For more details, see [3D Gaussian Splatting](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/).

---

## Project Structure
```text
📦 XScene-UEPlugin
├─ 📁 Training
│  ├─ gaussian-splatting/        # Core algorithm and training scripts
│  ├─ README.md                  # English training guide
│  └─ README_CN.md              # 中文训练指南
├─ 📁 UEPlugin
│  ├─ Config/                    # Plugin configuration presets
│  ├─ Content/                   # Example assets and Niagara emitters
│  ├─ Media/                     # Documentation images and videos
│  ├─ Plugin/                    # Plugin source code
│  ├─ README.md                  # English plugin guide
│  └─ README_CN.md              # 中文插件指南
├─ LICENSE
└─ README.md                    # Main overview file
```


---

## Training Module

The `Training` folder contains everything you need to train your own 3D Gaussian Splatting models from videos or image sequences.

**Quick Links:**

- [Training Guide (EN)](./Training/README.md)
- [训练指南 (中文)](./Training/README_CN.md)

### Highlights

- **Data Preparation:** Tools to convert multi-view images or videos into training-ready formats
- **Model Configuration:** Easily tweak `.yaml` config files for custom resolution, point count, and learning rate
- **Training Scripts:** Single-command launch on Windows using `XV3DTools.exe` or Python scripts for advanced users
- **Monitoring:** Integrated TensorBoard support for loss curves, PSNR, and other metrics

---

## UE Plugin

The `UEPlugin` folder contains all UE5 plugin assets, source code, and documentation.

**Quick Links:**

- [Plugin Guide (EN)](./UEPlugin/README.md)
- [插件指南 (中文)](./UEPlugin/README_CN.md)

### Features

- **Real-time Gaussian Splatting rendering using Niagara**
- **Drag-and-drop .gspl assets into UE5 Content Browser**
- **Fully Blueprint-compatible and extendable**
- **Dynamic lighting and LOD generation**
- **Hybrid rendering with native UE assets**
- **Crop regions & pure VFX Niagara emitters**

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/xverse-engine/XScene-UEPlugin.git
cd XScene-UEPlugin
```

### 2. Install Dependencies

#### For Training

Ensure you have Python 3.8+, PyTorch, and the required packages:

```bash
pip install -r Training/gaussian-splatting/requirements.txt
```

#### For UE Plugin

Install Unreal Engine 5.0+ and enable the **Niagara Plugin**.

### 3. Build & Run

- **Training:** See `Training/README.md` or `README_CN.md` for training steps
- **UE Plugin:** Copy `UEPlugin/Plugin` to your UE project `Plugins/` directory and enable `XVERSE3DGS` in the Plugin Browser

---

## Roadmap

- [ ] Dynamic LOD Rendering in Editor & Runtime
- [ ] Automatic Collision & Physics Proxy Generation
- [ ] Real-time Preview Window for quick iterations
- [ ] Interactive 3D-GS Asset Editing
- [ ] Compression & Streaming of 3D-GS Assets

Contributions and feature requests are welcome!

---

## Contributing

1. Fork the repository
2. Create a branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m "Add feature"`)
4. Push (`git push origin feature/my-feature`)
5. Submit a Pull Request 🎉

---

## Release Note
[v1.1.6](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.6)
- Provides a convenient and simple training code and script
- The directory structure has been adjusted to separate training and UE plugins

[v1.1.5](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.5)
- Support user-defined settings of training parameters
- Modify 3DGS densification strategy to focus more on important areas
- Support post-processing strategies for object reconstruction, which can effectively remove floaters
- Support Gaussian models with spherical harmonic coefficients up to the 3rd degree
<img src="UEPlugin/Media/image/compare/1.5-1.png" width="500" />
<img src="UEPlugin/Media/image/compare/1.5-2.png" width="500" />



[v1.1.4](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.4)
- Support UE5.4

[v1.1.3](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.3)
- Support dragging multiple ply files into the content directory
- Fix the crash issue when the buffer asset position is incorrect
- Fix bug in XV3DTools while using wrong path 
  

[v1.1.2](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.2)
- Supports more types of ply header 
- Fixed flickers when moving objects
- Update UI

[v1.1.1](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.1)
- New Model Clipping allowing the creation of a clean Niagara for VFX.
- XV3DTools v1.1.1: Users can now adjust the training iteration.

[v1.1.0](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.1.0)
- Training tools in Windows system (XV3DTools v1.0) to train a given mp4 video to GaussianSplatting ply file
- Automatic lod generation, supporting over 200,000 point clouds in niagara
- fix bug in transform

[v1.0.1](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.0.0)
- Fix bug in v1.0.0：Error while packaging for Windows in UE5.2 and UE5.3
  
[v1.0.0](https://github.com/xverse-engine/XScene-UEPlugin/tree/v1.0.0)
- Niagara-Based High-quality real-time visualizing and rendering for 3D Gaussian Splatting
- Easily importing and converting from the original Gaussian Splatting scene (.ply file) to ours
- Hybrid rendering with other UE assets 
- RTS and Geometry Editing
- Apply VFX effect to Gaussian Splatting scene
- Support dynamic illumination of Gaussian Splatting scene
- Automatic enhancement of Gaussian Splatting scene 

## Contributors

<a href="https://github.com/xverse-engine/XV3DGS-UEPlugin/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=xverse-engine/XV3DGS-UEPlugin" />
</a>