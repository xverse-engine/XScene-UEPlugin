# XVERSE 3D-GS UE 插件

<a href="./LICENSE">
        <img alt="License" src="https://img.shields.io/badge/License-Apache_2.0-blue.svg"></a>

[English](./README.md) | 中文

[ <img src="UEPlugin/Media/image/XVERSE.jpg" width="600" />
](http://xverse.cn/)

---

## 目录

* [简介](#简介)
* [项目结构](#项目结构)
* [训练模块](#训练模块)
* [UE 插件](#ue-插件)
* [快速开始](#快速开始)
* [路线图](#路线图)
* [贡献指南](#贡献指南)
* [版本记录](#版本记录)

---

## 简介

XVERSE 3D Gaussian Splatting （3D-GS）UE Plugin 是基于 Unreal Engine 5 (UE5) 的混合编辑插件，由 XVERSE Technology Inc. (Zhenshen, China) 开发，旨在UE中提供 Guassian Splatting 模型的生成、呈现、混合编辑能力。Guassian Splatting 是一项最近兴起的 3D 重建技术，用于从多张照片重建 3D 场景, 更多原理可以参考[这里](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/).


## 招聘
### 【图形图像算法工程师-3D重建与生成方向】

岗位职责：研发3D重建与生成领域的相关算法和应用，综合运用Gaussian Splatting、NeRF、IBR、SFM、深度估计等多种CVCG技术，依据产品需求进行组合创新和单点突破。将算法集成进图形引擎，持续打磨算法的性能和效果，追踪前沿算法的最新进展。

岗位要求：
- 1.硕士或以上学历，有扎实的计算机视觉或图形学功底，了解NeRF、Gaussian Splatting、IBR、SFM、深度估计等3D重建与生成方法中的至少一个子方向。
- 2.熟练掌握至少一种编程语言，如C++，Python等。
- 3.有顶级学术会议发表或编程竞赛优胜经验者有加分。

投递邮箱：xengine@xverse.cn

投递时请邮件标题标明申请正式员工or实习生岗位
---

## 项目结构

```text
📦 XVERSE-3D-GS-UEPlugin
📂 Training
├️ gaussian-splatting/        # 核心算法和训练脚本
├️ README.md                  # 英文训练指南
└️ README_CN.md              # 中文训练指南
📂 UEPlugin
├️ Config/                    # 插件配置预设
├️ Content/                   # 示例资源和 Niagara 效果
├️ Media/                     # 文档图片和视频
├️ Plugin/                    # 插件源码
├️ README.md                  # 英文插件指南
└️ README_CN.md              # 中文插件指南
└ LICENSE
└ README.md                    # 总览文件
```

---

## 训练模块

`Training` 文件夹包含了从视频或多视图系列进行 3D Gaussian Splatting 训练所需要的全部文件和脚本。

**快捷链接：**

* [训练指南 (EN)](./Training/README.md)
* [训练指南 (中文)](./Training/README_CN.md)

### 特性點

* **数据处理**：支持多视角图片和视频转化
* **模型配置**：通过 `.yaml` 文件设置分辨率、点云数量和学习率
* **一键运行**：支持 Windows 平台下 XV3DTools.exe 和 Python 脚本
* **监控**：集成 TensorBoard，支持 loss 曲线，PSNR 等指标

---

## UE 插件

`UEPlugin` 文件夹包含了插件源码、资源、文档等所有内容。

**快捷链接：**

* [插件指南 (EN)](./UEPlugin/README.md)
* [插件指南 (中文)](./UEPlugin/README_CN.md)

### 插件特性

* 基于 Niagara 实现实时 Gaussian Splatting 渲染
* 支持拖拽 .gspl 文件到 UE5 Content Browser
* 全面支持 Blueprint 扩展
* 动态光照和 LOD 生成
* 支持 UE 原生资产混合渲染
* 支持 Crop 区域和 VFX 效果

---

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/xverse-tech/XVERSE-3D-GS-UEPlugin.git
cd XVERSE-3D-GS-UEPlugin
```

### 2. 安装依赖

#### 训练模块

需要安装 Python 3.8+ 、PyTorch 和其他包：

```bash
pip install -r Training/gaussian-splatting/requirements.txt
```

#### UE 插件

安装 Unreal Engine 5.0+，并启用 Niagara 插件

### 3. 构建 & 运行

* **训练**：请参见 `Training/README.md` 或 `README_CN.md`
* **插件**：将 `UEPlugin/Plugin` 拷贝至 UE 项目中 `Plugins/` 目录，并在插件浏览器中启用 `XVERSE3DGS`

---

## 路线图

* [ ] 支持编辑器和运行时的动态 LOD 渲染
* [ ] 支持自动碰撞以及物理代理生成
* [ ] 支持实时预览窗口，便于快速调试
* [ ] 支持交互式 3D-GS 资产编辑
* [ ] 支持 3D-GS 资产压缩和流射

欢迎任何贡献和功能请求！

---

## 贡献指南

1. fork 本仓库
2. 创建分支 (`git checkout -b feature/my-feature`)
3. 提交你的修改 (`git commit -m "Add feature"`)
4. push 到你的分支 (`git push origin feature/my-feature`)
5. 提交 Pull Request 🎉

---

## 版本记录
[v1.1.6](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.6)
- 提供了一个便捷易用的训练代码和脚本，支持用户进行参数调整
- 目录结构调整，将目录分为3DGS训练和UE插件两部分


[v1.1.5](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.5)
- 支持用户自定义训练参数设置
- 修改3DGS致密化策略，更加关注重要领域
- 支持对象重建的后处理策略，可以有效地去除浮点数
- 支持导入0~3阶球谐系数的高斯模型
<img src="UEPlugin/Media/image/compare/1.5-1.png" width="500" />
<img src="UEPlugin/Media/image/compare/1.5-2.png" width="500" />

[v1.1.4](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.4)
- 支持 UE5.4
 
[v1.1.3](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.3)
- 支持拖动多个文件Content Browser并导入
- 修复 buffer资产位置不正确时候的闪退问题
- 修复 XV3DTools 错误路径提示

[v1.1.2](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.2)
- 支持更多类别ply头文件
- 修复移动物体闪烁的bug
- 更新UI

[v1.1.1](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.1)
- 更新剪裁功能，实现剪裁出一个干净的niagara来做特效
- XV3DTools v1.1.1：支持用户调节训练迭代次数

[v1.1.0](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.1.0)
- 导入时自动生成LOD，克服单个Niagara 200万点云数量限制
- Windows本地训练环境：使用XV3DTools，实现在windows平台下，给定mp4视频一键训练出Gaussian Splatting ply
- 修复transform的bug

[v1.0.1](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.0.0)
- 修复v1.0.0的bug：UE5.2和UE5.3下打包出现问题

[v1.0.0](https://github.com/xverse-engine/XV3DGS-UEPlugin/tree/v1.0.0)
- 基于 Niagara 的高质量且实时的 3D Gaussian Splatting 模型渲染
- 轻松将原始 Gaussian Splatting 场景（.ply 文件）导入并在UE场景中渲染
- 与其他 UE 资产混合渲染
- 旋转, 平移, 缩放
- 裁剪
- 动态光照
- 整体调色
- 制作VFX效果