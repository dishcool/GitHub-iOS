# GitHub iOS 应用图标使用说明

本文档提供了如何在Xcode项目中使用GitHub iOS应用图标的详细说明。

## 图标文件

设计文件夹包含以下图标资源：

- `AppIcon.svg` - 矢量格式的应用图标，分辨率为1024x1024
- `AppIcon.png` - PNG格式的应用图标，分辨率为1024x1024（需要从SVG生成）

## 在Xcode中使用图标

### 方法1：使用Asset Catalog

1. 打开Xcode项目
2. 选择Assets.xcassets
3. 右键点击，选择"New App Icon"（如果没有已存在的App Icon集合）
4. 将1024x1024的PNG图标拖拽到"App Icon - App Store"槽位
5. Xcode会自动生成其他所需尺寸

### 方法2：使用AppIcon Generator

1. 使用在线工具如[AppIcon Generator](https://appicon.co/)或[MakeAppIcon](https://makeappicon.com/)
2. 上传1024x1024的PNG图标
3. 下载生成的图标集
4. 将下载的图标集替换到项目的Assets.xcassets中的AppIcon集合

## 各种尺寸要求

iOS应用图标需要以下尺寸：

| 设备 | 尺寸 (像素) |
|------|------------|
| iPhone通知 | 20pt (@2x, @3x): 40x40, 60x60 |
| iPhone设置 | 29pt (@2x, @3x): 58x58, 87x87 |
| iPhone聚焦 | 40pt (@2x, @3x): 80x80, 120x120 |
| iPhone应用 | 60pt (@2x, @3x): 120x120, 180x180 |
| iPad通知 | 20pt (@1x, @2x): 20x20, 40x40 |
| iPad设置 | 29pt (@1x, @2x): 29x29, 58x58 |
| iPad聚焦 | 40pt (@1x, @2x): 40x40, 80x80 |
| iPad应用 | 76pt (@1x, @2x): 76x76, 152x152 |
| iPad Pro应用 | 83.5pt (@2x): 167x167 |
| App Store | 1024x1024 |

## 设计规范

设计遵循以下规范：

- 使用GitHub的品牌元素（Octocat）
- 深色渐变背景，符合现代iOS设计趋势
- 圆角矩形形状，符合iOS图标风格
- 包含移动设备元素，表明这是iOS应用
- 使用代码符号 `{}` 表示开发者工具属性

## 更新图标

如需更新图标：

1. 修改`AppIcon.svg`源文件
2. 重新生成PNG版本
3. 按照上述步骤更新Xcode中的图标资源

## 注意事项

- 确保图标在各种背景上都可见
- 不要在图标中包含透明部分
- 图标应清晰可识别，即使在较小的尺寸下
- 避免使用过于复杂的设计，以确保在小尺寸下仍然清晰 