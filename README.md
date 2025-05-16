# GitHub iOS App

这是一个基于GitHub API的iOS客户端应用，使用Swift和SwiftUI/UIKit开发。本应用遵循Protocol Oriented设计原则，采用MVVM架构模式。

## 主要功能

- **认证功能**：GitHub OAuth登录和生物识别（Face ID/Touch ID）登录
- **内容浏览**：
  - 热门仓库展示（未登录也可访问）
  - 仓库详情（包含基本信息和README显示）
  - 用户资料展示
- **搜索功能**：支持搜索仓库、用户和组织
- **界面与体验**：
  - 自定义UI组件（加载动画、仓库卡片等）
  - 统一错误处理机制
  - 深色模式完全支持
  - 中文本地化
  - 适配多种屏幕尺寸（iPhone/iPad）

## 技术栈

### 核心

- **语言**: Swift 5.5+
- **UI框架**: SwiftUI (主要界面), UIKit (特定功能和兼容性)
- **架构模式**: MVVM (Model-View-ViewModel)
- **设计理念**: Protocol Oriented Programming

### 核心组件

- SwiftUI视图和修饰符
- 属性包装器: @Published, @StateObject, @ObservedObject
- Swift并发: async/await
- 基于协议的依赖注入

### 网络和数据

- **网络**: Alamofire
- **图片加载**: Kingfisher
- **JSON解析**: SwiftyJSON
- **安全存储**: KeychainSwift, UserDefaults
- **API**: GitHub REST API v3

### 认证与安全

- **OAuth认证**: OAuthSwift
- **生物识别**: LocalAuthentication框架
- **安全存储**: Keychain

### 测试与开发

- **测试框架**: XCTest, XCUITest
- **工具链**: Xcode 13.0+, Swift Package Manager, Git
- **文档**: Markdown, Mermaid (架构图表)

## 应用展示

### 应用图标

<div align="center">
  <img src="Designs/AppIcon.svg" width="200" alt="GitHub iOS应用图标"/>
  <p><em>简洁的GitHub猫（Octocat）设计</em></p>
</div>

### 界面预览

<div align="center">
  <h4>登录与认证</h4>
  <p>
    <img src="Screenshots/Login.png" width="250" alt="登录界面"/>
    <img src="Screenshots/Login-Bio.png" width="250" alt="生物识别登录"/>
  </p>
  <p><em>左: 登录界面 | 右: 生物识别登录</em></p>

  <h4>内容浏览</h4>
  <p>
    <img src="Screenshots/Popular List.png" width="250" alt="热门仓库列表"/>
    <img src="Screenshots/Repository Details.png" width="250" alt="仓库详情"/>
    <img src="Screenshots/Profile.png" width="250" alt="个人资料"/>
  </p>
  <p><em>左: 热门仓库列表 | 中: 仓库详情 | 右: 个人资料</em></p>

  <h4>搜索功能</h4>
  <p>
    <img src="Screenshots/Search Repo.png" width="250" alt="仓库搜索"/>
    <img src="Screenshots/Search User.png" width="250" alt="用户搜索"/>
  </p>
  <p><em>左: 仓库搜索 | 右: 用户搜索</em></p>
</div>

## 架构设计

本项目采用MVVM架构模式和Protocol Oriented设计原则，通过以下图表展示系统设计：

### 组件架构

<div align="center">
  <img src="Designs/diagram/Component-Diagram.png" width="700" alt="组件架构图"/>
  <p><em>展示了UI层、ViewModel层、Service层和Data层的主要组件及其依赖关系</em></p>
</div>

### 类关系图

<div align="center">
  <img src="Designs/diagram/Class-Diagram.png" width="700" alt="类图"/>
  <p><em>描述了主要类、协议及其关系，展示了依赖注入和模块间通信方式</em></p>
</div>

### 登录流程图

<div align="center">
  <h4>OAuth登录</h4>
  <img src="Designs/diagram/Login-Sequence-Diagram.png" width="700" alt="OAuth登录流程序列图"/>
  <p><em>通过GitHub网站完成授权</em></p>
  
  <h4>生物识别登录</h4>
  <img src="Designs/diagram/Login-Sequence-Diagram-Bio.png" width="700" alt="生物识别登录流程序列图"/>
  <p><em>使用Face ID或Touch ID验证身份</em></p>
  
  <h4>自动登录</h4>
  <img src="Designs/diagram/Login-Sequence-Diagram-Auto.png" width="700" alt="自动登录流程序列图"/>
  <p><em>应用启动时验证已保存的令牌</em></p>
</div>

> 图表使用Mermaid语法创建，源文件位于`Designs/diagram/`目录。可使用支持Mermaid的编辑器或[Mermaid Live Editor](https://mermaid.live/)预览。

## 项目设置与配置

### 系统要求

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

### 依赖管理

使用Swift Package Manager (SPM)添加以下依赖：

| 包名称 | URL | 版本 | 用途 |
|-------|-----|------|-----|
| Alamofire | https://github.com/Alamofire/Alamofire.git | 5.6.0+ | 网络请求 |
| Kingfisher | https://github.com/onevcat/Kingfisher.git | 7.0.0+ | 图片加载和缓存 |
| SwiftyJSON | https://github.com/SwiftyJSON/SwiftyJSON.git | 5.0.0+ | JSON解析 |
| KeychainSwift | https://github.com/evgenyneu/keychain-swift.git | 20.0.0+ | 安全存储 |
| OAuthSwift | https://github.com/OAuthSwift/OAuthSwift.git | 2.2.0+ | OAuth认证 |

### 认证配置

#### GitHub OAuth配置

1. 在GitHub上注册OAuth应用 (https://github.com/settings/applications/new)
   - 回调URL: `github://callback`
2. 在`AuthenticationService.swift`中更新凭据：
   ```swift
   private let clientID = "YOUR_GITHUB_CLIENT_ID"
   private let clientSecret = "YOUR_GITHUB_CLIENT_SECRET"
   ```
3. 配置URL Scheme (Info.plist): `github`

#### 生物识别配置

在Info.plist中添加`NSFaceIDUsageDescription`键和使用说明

## 项目结构

```
GitHub-iOS/
├── Models/                 # 数据模型
├── Views/                  # UI视图
│   ├── Main/               # 主要视图
│   └── CustomComponents/   # 自定义UI组件
├── ViewModels/             # 视图模型
├── Services/               # 服务层
│   └── Protocols/          # 服务协议
└── Tests/                  # 测试相关
```

## 测试

项目包含全面的测试套件，详细文档：
- [单元测试文档](Tests/UNIT_TESTS.md)
- [UI测试文档](Tests/UI_TESTS.md)

特点：
- 模块化和可复用的测试设计
- 共享辅助方法提高测试稳定性
- 自动捕获的屏幕截图验证UI表现

## 开发与支持

### 开发团队

- Dishcool - Lead Developer

### 许可证

该项目使用 MIT 许可证