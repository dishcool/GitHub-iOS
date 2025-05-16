# GitHub iOS App UI Tests

## 测试概述

本项目包含以下主要 UI 测试套件：

1. **GitHubUITests** - 全面 UI 功能测试
   - 测试登录界面元素和流程
   - 测试未登录状态下的主页访问
   - 测试搜索功能
   - 测试仓库详情页面
   - 测试深色模式切换
   - 测试个人资料页面和登录导航
   - 测试屏幕旋转和截图功能

2. **GitHubUITestsLaunchTests** - 应用启动测试
   - 测试应用启动性能和界面
   - 测试应用图标

## 测试结果

所有 UI 测试均成功通过，测试结果截图如下：

![UI测试结果](/Users/dishcool/workspace/GitHub/GitHub-iOS/Tests/UITest-result.png)

> **注意**：测试结果截图保存在 `Tests/UITest-result.png` 文件中。如需查看最新测试结果，请运行测试套件并查看 Xcode 测试报告。测试报告中还包含了每个测试自动捕获的屏幕截图，可以帮助分析和验证 UI 行为。

## 如何运行 UI 测试

### 使用 Xcode 运行测试

1. 在 Xcode 中打开项目
2. 选择一个模拟器（推荐 iPhone 14 或更新的设备）
3. 使用快捷键 `Cmd+U` 运行所有测试，或者在测试导航器(⌘+6)中选择特定的 UI 测试类或方法

### 使用命令行运行测试

```bash
# 运行所有 UI 测试
xcodebuild test -project GitHub.xcodeproj -scheme GitHub -destination 'platform=iOS Simulator,name=iPhone 14' -testPlan UITests

# 运行特定 UI 测试类
xcodebuild test -project GitHub.xcodeproj -scheme GitHub -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:GitHubUITests/GitHubUITests
```

## 测试文件位置

UI 测试文件位于项目的 `GitHub/GitHubUITests` 目录中：

- `GitHubUITests.swift` - 全面 UI 功能测试（包含导航、搜索、个人资料等测试）
- `GitHubUITestsLaunchTests.swift` - 应用启动测试

> **注意**：所有 UI 测试已整合到 `GitHubUITests.swift` 文件中，提高了代码复用性和测试维护效率。

## UI 测试策略

本项目采用了以下 UI 测试策略：

1. **页面元素验证** - 确保关键 UI 元素存在并可交互
2. **用户流程测试** - 测试用户完成特定任务的流程
3. **深色模式适配** - 验证应用在不同外观模式下的表现
4. **性能测试** - 测量应用启动时间和关键操作的性能
5. **辅助方法复用** - 通过共享辅助方法减少代码重复
6. **视觉验证** - 通过截图捕获并验证界面外观

## UI 测试最佳实践

在编写和维护 UI 测试时，请遵循以下最佳实践：

1. **使用可靠的标识符**
   - 为关键 UI 元素设置 `accessibilityIdentifier`
   - 避免使用硬编码的文本字符串（除非是固定不变的标题）

2. **处理异步操作**
   - 使用 `waitForExistence` 或 `XCTNSPredicateExpectation` 等待异步操作完成
   - 避免使用固定的 `sleep` 时间（除非绝对必要）

3. **测试环境隔离**
   - UI 测试应该能在任何环境中运行，不依赖于特定的网络状态或账户
   - 考虑使用模拟数据或测试账户

4. **截图和附件**
   - 在关键步骤添加截图，便于调试和记录
   - 使用 `XCTAttachment` 记录测试环境信息

5. **通用辅助方法**
   - 创建通用的辅助方法以提高代码复用性
   - 例如 `findTabByName`、`waitForAnyElement` 等方法

## 常见问题与解决方案

### 1. 元素识别问题

**问题**：UI 测试无法找到特定元素。

**解决方案**：
- 确保元素有唯一的 `accessibilityIdentifier`
- 使用 Xcode 的录制功能识别元素
- 尝试使用不同的查询方法，如 `buttons.matching(NSPredicate(...))`
- 使用更灵活的查找方法，如 `findTabByName` 支持多种可能的名称

### 2. 测试稳定性问题

**问题**：UI 测试有时通过，有时失败。

**解决方案**：
- 添加适当的等待机制，确保 UI 元素加载完成
- 避免依赖特定的网络状态或外部服务
- 增加测试的健壮性，处理可能的异常情况
- 添加更多的调试信息，如 UI 层次结构的打印

### 3. 登录状态管理

**问题**：测试需要在登录和未登录状态下运行。

**解决方案**：
- 使用辅助方法模拟登录状态
- 考虑使用测试账户或模拟 API 响应
- 在测试之间清理应用状态

### 4. 设备方向和外观模式测试

**问题**：测试深色模式和设备旋转时可能遇到 API 限制。

**解决方案**：
- 使用合适的替代方法，如通过截图来检查界面变化
- 使用 `UIDevice.current.setValue` 代替直接的 `rotate` 方法
- 提供多种测试选项，确保至少一种方法能在当前环境中工作

## 注意事项

- UI 测试需要在模拟器或真机上运行，不能在 CI 环境中无头运行
- 某些测试（如深色模式测试）需要 iOS 13.0 或更高版本
- 应用图标测试可能需要特殊权限，在某些环境中可能不工作
- 运行 UI 测试前，请确保模拟器处于正常状态（无弹窗或其他干扰） 