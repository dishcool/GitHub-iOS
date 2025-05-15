# GitHub iOS App - 设置指南

本文档提供了设置GitHub iOS应用的详细步骤，包括添加依赖、配置OAuth和完成项目设置。

## 添加Swift Package Manager依赖

1. 打开Xcode项目
2. 选择 File > Add Packages...
3. 在搜索栏中添加以下包（逐个添加）：

### Alamofire
- URL: https://github.com/Alamofire/Alamofire.git
- 版本: Up to Next Major (5.0.0)
- 依赖规则: 5.6.0 <= 版本 < 6.0.0

### Kingfisher
- URL: https://github.com/onevcat/Kingfisher.git
- 版本: Up to Next Major (7.0.0) 
- 依赖规则: 7.0.0 <= 版本 < 8.0.0

### SwiftyJSON
- URL: https://github.com/SwiftyJSON/SwiftyJSON.git
- 版本: Up to Next Major (5.0.0)
- 依赖规则: 5.0.0 <= 版本 < 6.0.0

### KeychainSwift
- URL: https://github.com/evgenyneu/keychain-swift.git
- 版本: Up to Next Major (20.0.0)
- 依赖规则: 20.0.0 <= 版本 < 21.0.0

### OAuthSwift
- URL: https://github.com/OAuthSwift/OAuthSwift.git
- 版本: Up to Next Major (2.0.0)
- 依赖规则: 2.2.0 <= 版本 < 3.0.0

## 项目设置

### 更新iOS部署目标
1. 选择项目导航器中的项目
2. 选择GitHub目标
3. 在"General"选项卡中，将"Deployment Info"下的"iOS Deployment Target"设置为14.0

### 添加Face ID权限
1. 打开Info.plist文件
2. 添加新键: NSFaceIDUsageDescription
3. 值设置为: "使用Face ID登录您的GitHub账户"

### 配置URL Scheme用于OAuth回调
1. 选择项目导航器中的项目
2. 选择GitHub目标
3. 选择"Info"选项卡
4. 展开"URL Types"部分
5. 点击"+"按钮添加新的URL Type
6. 设置Identifier为"com.yourcompany.github"
7. URL Schemes设置为"github"

### 创建缺少的目录结构
确保在项目中创建以下目录结构：

```
GitHub/
├── App/
├── Models/
├── Views/
│   ├── CustomComponents/
│   └── Screens/
├── ViewModels/
├── Services/
│   └── Protocols/
└── Utils/
    └── Extensions/
```

## GitHub OAuth配置

要使用GitHub OAuth功能，您需要：

1. 在GitHub上注册一个新的OAuth应用：
   - 访问 https://github.com/settings/applications/new
   - 填写应用名称、主页URL（可以是任何URL）
   - 回调URL设置为 `github://callback`
   - 点击注册应用

2. 获取Client ID和Client Secret后，更新AuthenticationService.swift中的值：

```swift
private let clientID = "YOUR_GITHUB_CLIENT_ID"
private let clientSecret = "YOUR_GITHUB_CLIENT_SECRET"
```

## 待实现的视图

要完成应用，还需要实现以下SwiftUI视图：

1. HomeView.swift - 显示流行仓库
2. SearchView.swift - 搜索仓库、用户和组织
3. ProfileView.swift - 显示用户个人资料和仓库
4. LoginView.swift - GitHub登录界面
5. RepositoryDetailView.swift - 仓库详情页面

## 本地化支持

为添加中文本地化支持：

1. 选择项目导航器中的项目
2. 选择GitHub目标
3. 点击"+"按钮，选择"New File..."
4. 选择"Strings File"，命名为"Localizable"
5. 创建后，在项目导航器中选择该文件
6. 在右侧检查器中点击"Localize..."按钮
7. 选择"Chinese (Simplified)"

## 测试

在实现UI后，应创建单元测试和UI测试：

1. 为服务层创建单元测试
2. 为视图模型创建单元测试
3. 为主要用户流程创建UI测试

## 最后步骤

1. 清理项目，确保所有文件都添加到了正确的目标
2. 构建并运行项目，确保没有编译错误
3. 测试主要功能，确保一切正常工作

祝您开发顺利！ 