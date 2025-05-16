# GitHub iOS App

这是一个基于GitHub API的iOS客户端应用，使用Swift和UIKit开发，同时结合SwiftUI实现部分界面。本应用遵循Protocol Oriented设计原则，采用MVVM架构模式。

## 功能

- **登录功能**：支持GitHub OAuth登录和生物识别（Face ID/Touch ID）登录
- **主页**：展示流行的GitHub仓库，未登录用户也可访问
- **搜索页**：搜索GitHub上的仓库、用户和组织
- **个人资料页**：显示用户信息和仓库列表
- **仓库详情页**：显示仓库详细信息，包括README、代码、Issues等
- **自定义UI组件**：包含自定义的加载动画和仓库卡片组件
- **通用错误页面**：统一处理各种错误情况
- **深色模式支持**：完全适配iOS的亮色和暗色模式
- **中文本地化**：使用Localization文件实现中文界面
- **适配多种屏幕**：支持iPhone和iPad的各种屏幕尺寸

## 项目设置

### 系统要求

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

### 添加依赖包

本项目使用Swift Package Manager (SPM)管理依赖。按照以下步骤添加所需的包：

1. 在Xcode中打开项目
2. 选择 File > Add Packages...
3. 在搜索栏中依次输入并添加以下包：

| 包名称 | URL | 版本 | 用途 |
|-------|-----|------|-----|
| Alamofire | https://github.com/Alamofire/Alamofire.git | 5.6.0 或更高 | 网络请求 |
| Kingfisher | https://github.com/onevcat/Kingfisher.git | 7.0.0 或更高 | 图片加载和缓存 |
| SwiftyJSON | https://github.com/SwiftyJSON/SwiftyJSON.git | 5.0.0 或更高 | JSON解析 |
| KeychainSwift | https://github.com/evgenyneu/keychain-swift.git | 20.0.0 或更高 | 安全存储敏感数据 |
| OAuthSwift | https://github.com/OAuthSwift/OAuthSwift.git | 2.2.0 或更高 | OAuth认证 |

### GitHub OAuth配置

要使用GitHub OAuth登录功能，您需要：

1. 在GitHub上注册一个新的OAuth应用：
   - 访问 https://github.com/settings/applications/new
   - 填写应用名称、主页URL（可以是任何URL）
   - 回调URL设置为 `github://callback`
   - 点击注册应用

2. 获取Client ID和Client Secret后，打开 `AuthenticationService.swift` 文件并将以下变量更新为您的值：
   ```swift
   private let clientID = "YOUR_GITHUB_CLIENT_ID"
   private let clientSecret = "YOUR_GITHUB_CLIENT_SECRET"
   ```

3. 配置URL Scheme以处理OAuth回调：
   - 在Xcode项目中选择目标，然后选择"Info"选项卡
   - 展开"URL Types"部分
   - 添加一个新的URL Type，设置Identifier为"com.yourcompany.github"，URL Schemes为"github"

### 生物识别认证配置

要使用Face ID或Touch ID：

1. 在Info.plist中添加`NSFaceIDUsageDescription`键，并提供使用生物识别的原因描述

## 项目结构

项目使用MVVM架构，按照以下目录结构组织代码：

- **Models**: 数据模型
  - Repository.swift：仓库模型
  - User.swift：用户模型
  - Organization.swift：组织模型

- **Views**: UI视图
  - MainTabView.swift：主标签视图
  - HomeView.swift：主页视图
  - SearchView.swift：搜索视图
  - ProfileView.swift：个人资料视图
  - LoginView.swift：登录视图
  - CustomComponents/：自定义UI组件
    - LoadingIndicator.swift：加载指示器
    - RepositoryCard.swift：仓库卡片

- **ViewModels**: 视图模型
  - AuthViewModel.swift：认证视图模型
  - HomeViewModel.swift：主页视图模型
  - SearchViewModel.swift：搜索视图模型
  - ProfileViewModel.swift：个人资料视图模型
  - RepositoryDetailViewModel.swift：仓库详情视图模型

- **Services**: 服务层
  - NetworkService.swift：网络服务
  - AuthenticationService.swift：认证服务
  - RepositoryService.swift：仓库服务
  - UserService.swift：用户服务
  - Protocols/：服务协议
    - NetworkServiceProtocol.swift：网络服务协议
    - AuthenticationServiceProtocol.swift：认证服务协议
    - RepositoryServiceProtocol.swift：仓库服务协议
    - UserServiceProtocol.swift：用户服务协议

- **Tests**: 测试相关
  - 单元测试文件
  - 测试文档

## 实现细节

### 网络层

- 使用Alamofire处理网络请求
- 基于协议的设计，方便测试和依赖注入
- 统一错误处理

### 认证

- 支持GitHub OAuth认证
- 使用KeychainSwift安全存储令牌
- 支持生物识别快速登录（Face ID/Touch ID）

### UI设计

- 完全支持深色模式
- 响应式布局，适应不同屏幕尺寸
- 自定义动画提升用户体验

## 测试

项目包含全面的单元测试套件，覆盖了核心功能和组件。详细的测试文档位于 [Tests/README.md](Tests/README.md)，包括：

- 测试套件概述
- 如何运行测试
- 测试策略
- 常见问题与解决方案

## 开发团队

- Dishcool - Lead Developer

## 许可证

该项目使用 MIT 许可证