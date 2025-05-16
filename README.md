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

## 应用图标

<div align="center">
  <img src="Designs/AppIcon.svg" width="200" alt="GitHub iOS应用图标"/>
</div>
<p align="center">
  <em>GitHub iOS应用图标 - 简洁的GitHub猫（Octocat）设计</em>
</p>

应用图标采用简约设计，以GitHub的品牌标识（Octocat）为核心元素，搭配现代化的深色渐变背景，符合iOS图标设计规范。矢量格式的图标位于`Designs`文件夹中，支持高分辨率显示。

详细的图标使用说明请参阅[AppIcon使用说明](Designs/AppIcon使用说明.md)文档。

## 应用截图

<div align="center">
  <h3>登录与认证</h3>
</div>

<p align="center">
  <img src="Screenshots/Login.png" width="250" alt="登录界面"/>
  <img src="Screenshots/Login-Bio.png" width="250" alt="生物识别登录"/>
</p>
<p align="center">
  <em>左: 登录界面 | 右: 生物识别登录</em>
</p>

<div align="center">
  <h3>内容浏览</h3>
</div>

<p align="center">
  <img src="Screenshots/Popular List.png" width="250" alt="热门仓库列表"/>
  <img src="Screenshots/Repository Details.png" width="250" alt="仓库详情"/>
  <img src="Screenshots/Profile.png" width="250" alt="个人资料"/>
</p>
<p align="center">
  <em>左: 热门仓库列表 | 中: 仓库详情 | 右: 个人资料</em>
</p>

<div align="center">
  <h3>搜索功能</h3>
</div>

<p align="center">
  <img src="Screenshots/Search Repo.png" width="250" alt="仓库搜索"/>
  <img src="Screenshots/Search User.png" width="250" alt="用户搜索"/>
</p>
<p align="center">
  <em>左: 仓库搜索 | 右: 用户搜索</em>
</p>

<div align="center">
  <h3>主要特点</h3>
  <p align="center">
    ✅ 简洁现代的界面设计<br/>
    ✅ 深色模式完全支持<br/>
    ✅ 中文本地化<br/>
    ✅ 流畅的用户体验<br/>
    ✅ 适配各种iOS设备<br/>
    ✅ 模拟器自动登录支持
  </p>
</div>

## 生物识别认证配置

要使用Face ID或Touch ID：

1. 在Info.plist中添加`NSFaceIDUsageDescription`键，并提供使用生物识别的原因描述

## 架构设计

本项目采用MVVM架构模式和Protocol Oriented设计原则，通过以下图表展示系统的详细设计：

### 组件图

<div align="center">
  <img src="Designs/diagram/Component-Diagram.png" width="700" alt="组件架构图"/>
</div>
<p align="center">
  <em>GitHub iOS应用的组件架构图 - 展示了不同层级间的依赖关系</em>
</p>

组件图展示了应用的整体架构，包括UI层、ViewModel层、Service层和Data层的主要组件及其相互依赖关系。该架构严格遵循单向数据流原则，确保了代码的可维护性和可测试性。

### 类图

<div align="center">
  <img src="Designs/diagram/Class-Diagram.png" width="700" alt="类图"/>
</div>
<p align="center">
  <em>GitHub iOS应用的类图 - 描述主要类及其关系</em>
</p>

类图详细展示了应用中的主要类、协议及其关系。它展示了如何通过协议实现依赖注入，以及各个模块之间如何通过接口进行通信。

### 登录流程序列图

登录流程序列图详细描述了三种登录方式的实现过程：

#### 1. OAuth登录

<div align="center">
  <img src="Designs/diagram/Login-Sequence-Diagram.png" width="750" alt="OAuth登录流程序列图"/>
</div>
<p align="center">
  <em>GitHub OAuth登录流程 - 通过GitHub网站完成授权</em>
</p>

#### 2. 生物识别登录

<div align="center">
  <img src="Designs/diagram/Login-Sequence-Diagram-Bio.png" width="750" alt="生物识别登录流程序列图"/>
</div>
<p align="center">
  <em>生物识别登录流程 - 使用Face ID或Touch ID验证身份</em>
</p>

#### 3. 自动登录

<div align="center">
  <img src="Designs/diagram/Login-Sequence-Diagram-Auto.png" width="750" alt="自动登录流程序列图"/>
</div>
<p align="center">
  <em>自动登录流程 - 应用启动时验证已保存的令牌</em>
</p>

以上图表使用Mermaid Markdown语法创建，源文件位于`Designs/diagram/`目录下。要查看这些图表，您可以使用支持Mermaid的编辑器（如VS Code加装Mermaid扩展）或在线工具如[Mermaid Live Editor](https://mermaid.live/)预览。

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
- 在模拟器环境下自动登录，无需生物认证

### UI设计

- 完全支持深色模式
- 响应式布局，适应不同屏幕尺寸
- 自定义动画提升用户体验

## 测试

项目包含全面的测试套件，覆盖了核心功能和组件。所有测试均已成功通过，测试结果截图位于 `Tests` 目录下。

### 单元测试

详细的单元测试文档位于 [Tests/UNIT_TESTS.md](Tests/UNIT_TESTS.md)，包括：

- 测试套件概述
- 测试结果展示（[查看截图](Tests/UnitTest-result.png)）
- 如何运行测试
- 测试策略
- 常见问题与解决方案

### UI 测试

详细的 UI 测试文档位于 [Tests/UI_TESTS.md](Tests/UI_TESTS.md)，包括：

- UI 测试套件概述（所有 UI 测试已合并到 GitHubUITests.swift 中以提高代码复用性）
- 测试结果展示（[查看截图](Tests/UITest-result.png)）
- 如何运行 UI 测试
- UI 测试策略和最佳实践
- 常见问题与解决方案

我们的 UI 测试采用了模块化和可复用的设计，通过共享辅助方法如 `findTabByName` 和 `waitForAnyElement` 来提高测试的稳定性和易维护性。测试报告中包含了自动捕获的屏幕截图，用于验证应用在不同状态下的 UI 表现。

## 开发团队

- Dishcool - Lead Developer

## 许可证

该项目使用 MIT 许可证

### 开发与测试增强功能

#### 模拟器自动登录

为提高开发和测试效率，本应用特别实现了在模拟器环境下的自动登录功能：

- 在模拟器中运行时，如果用户之前已登录（有保存的令牌），应用将自动使用该令牌尝试登录，无需进行生物认证
- 登录页面会显示明确的提示和"一键自动登录"按钮，提供更佳的开发体验
- 此功能仅在模拟器环境中启用，不影响真机上的生物认证安全机制
- 通过条件编译指令 `#if targetEnvironment(simulator)` 实现环境检测

这一功能大大提高了在模拟器中的开发和测试效率，减少了因模拟器不支持生物认证而导致的开发障碍。

## 使用说明

### 模拟器中的登录方式

在模拟器环境中使用本应用时，登录流程如下：

1. 首次使用需通过 GitHub OAuth 完成正常登录流程，登录成功后令牌将保存在钥匙串中
2. 之后再次启动应用时，系统将检测到模拟器环境并自动尝试使用已保存的令牌登录
3. 如果需要重新登录，可以点击个人资料页中的"退出登录"按钮，然后通过 GitHub OAuth 重新登录

这种设计极大地简化了在模拟器中的开发和测试过程，特别是在反复启动应用进行测试时，无需每次都经过完整的 OAuth 流程或面对无法使用的生物识别提示。