# GitHub iOS App Unit Tests

## 测试概述

本项目包含以下几个主要测试套件：

1. **AuthViewModelTests** - 测试认证视图模型的功能
   - 测试登录成功和失败流程
   - 测试令牌检查和验证
   - 测试注销功能
   - 测试重置状态功能

2. **NetworkServiceTests** - 测试网络服务层
   - 测试成功和失败的网络请求
   - 测试缓存功能
   - 测试各种错误情况

3. **RepositoryServiceTests** - 测试仓库相关功能
   - 测试热门仓库获取
   - 测试搜索仓库
   - 测试获取仓库详情
   - 测试获取用户仓库
   - 测试获取 README 内容

4. **GitHubTests** - 基础模型测试
   - 测试 Repository 模型的基本属性

## 测试结果

所有单元测试均成功通过，测试结果截图如下：

![单元测试结果](/Users/dishcool/workspace/GitHub/GitHub-iOS/Tests/UnitTest-result.png)

> **注意**：测试结果截图保存在 `Tests/UnitTest-result.png` 文件中。如需查看最新测试结果，请运行测试套件并查看 Xcode 测试报告。

## 如何运行测试

### 使用 Xcode 运行测试

1. 在 Xcode 中打开项目
2. 使用快捷键 `Cmd+U` 运行所有测试
3. 或者在测试导航器(⌘+6)中选择单个测试文件或测试方法运行

### 使用命令行运行测试

```bash
# 运行所有测试
xcodebuild test -project GitHub.xcodeproj -scheme GitHub -destination 'platform=iOS Simulator,name=iPhone 14'

# 运行特定测试类
xcodebuild test -project GitHub.xcodeproj -scheme GitHub -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:GitHubTests/AuthViewModelTests
```

## 测试文件位置

测试文件位于项目的 `GitHub/GitHubTests` 目录中，按照功能模块组织：

- `GitHubTests.swift` - 基础模型测试
- `AuthViewModelTests.swift` - 认证视图模型测试
- `NetworkServiceTests.swift` - 网络服务测试
- `RepositoryServiceTests.swift` - 仓库服务测试

## 测试统计

- 测试类数量：4
- 总测试用例数量：20+
- 代码覆盖率目标：80%+

## 测试策略

本项目采用了以下测试策略：

1. **单元测试** - 测试单个组件的独立功能
2. **模拟对象(Mocks)** - 使用模拟对象隔离外部依赖
3. **行为验证** - 验证组件在不同条件下的行为

## 增加新测试

如需添加新测试，请遵循以下原则：

1. 测试类命名为 `{ComponentName}Tests`
2. 测试方法命名为 `test{Functionality}`
3. 使用 Given-When-Then 结构组织测试代码
4. 尽量模拟外部依赖以确保测试的独立性

## 常见问题与解决方案

在开发测试过程中，我们遇到并解决了以下问题，记录在此以供参考：

### 1. 异步测试中的等待机制

**问题**：异步测试中，如果不正确使用等待机制，可能导致测试在断言执行前就结束，或者 `sut` (System Under Test) 对象被过早释放。

**解决方案**：
- 使用 `XCTestExpectation` 和 `wait(for:timeout:)` 确保异步操作完成
- 在异步回调中调用 `expectation.fulfill()`
- 示例：
  ```swift
  let expectation = XCTestExpectation(description: "Async operation")
  // 执行异步操作
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // 断言
      XCTAssertTrue(condition)
      expectation.fulfill()
  }
  wait(for: [expectation], timeout: 1.0)
  ```

### 2. 模拟网络服务中的缓存实现

**问题**：在 `NetworkServiceTests` 中，缓存测试失败，因为模拟服务没有正确实现缓存逻辑。

**解决方案**：
- 在 `MockNetworkService` 中添加 `cachedEndpoints` 集合跟踪已缓存的端点
- 创建缓存键，结合端点 URL 和 HTTP 方法
- 检查请求是否可以使用缓存，并相应地更新请求计数
- 实现缓存清除方法

### 3. 模型 placeholder 属性与测试断言的一致性

**问题**：测试断言与模型的 placeholder 属性值不匹配，导致测试失败。

**解决方案**：
- 确保测试断言与模型的实际 placeholder 值匹配
- 或者修改模型的 placeholder 值以匹配测试期望
- 在我们的例子中，我们更新了测试断言以匹配 `Repository.placeholder` 和 `User.placeholder` 的实际值

### 4. 枚举类型的 Equatable 实现

**问题**：在测试中使用 `case .errorType = error` 模式匹配时，如果枚举类型没有遵循 `Equatable` 协议，会导致编译错误。

**解决方案**：
- 让枚举类型遵循 `Equatable` 协议
- 实现 `==` 操作符，比较枚举值
- 或者使用更简单的方式进行比较，如直接使用 `==` 操作符

## 注意事项

- 运行测试前请确保已安装所有所需的依赖包
- 测试可能会使用模拟数据而非实际 API 调用
- 部分测试需要模拟器支持（特别是生物识别相关测试）
- 确保模型的 placeholder 值与测试断言一致
- 异步测试必须使用适当的等待机制
- 模拟对象应该准确反映实际对象的行为，包括缓存等功能 