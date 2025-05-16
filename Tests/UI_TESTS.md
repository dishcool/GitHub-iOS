# GitHub iOS App UI Tests

## Test Overview

This project contains the following main UI test suites:

1. **GitHubUITests** - Comprehensive UI functionality tests
   - Tests login interface elements and flows
   - Tests home page access without login
   - Tests search functionality
   - Tests repository details page
   - Tests dark mode switching
   - Tests profile page and login navigation
   - Tests screen rotation and screenshot features

2. **GitHubUITestsLaunchTests** - Application launch tests
   - Tests application launch performance and interface
   - Tests application icon

## Test Results

All UI tests have passed successfully, test results screenshot below:

![UI Test Results](/Users/dishcool/workspace/GitHub/GitHub-iOS/Tests/UITest-result.png)

> **Note**: Test results screenshots are saved in the `Tests/UITest-result.png` file. To view the latest test results, please run the test suite and check the Xcode test report. The test report also includes screenshots automatically captured by each test, which can help analyze and verify UI behavior.

## How to Run UI Tests

### Running Tests with Xcode

1. Open the project in Xcode
2. Select a simulator (iPhone 14 or newer device recommended)
3. Use the shortcut `Cmd+U` to run all tests, or select specific UI test classes or methods in the test navigator (⌘+6)

### Running Tests with Command Line

```bash
# Run all UI tests
xcodebuild test -project GitHub.xcodeproj -scheme GitHub -destination 'platform=iOS Simulator,name=iPhone 14' -testPlan UITests

# Run specific UI test class
xcodebuild test -project GitHub.xcodeproj -scheme GitHub -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:GitHubUITests/GitHubUITests
```

## Test File Locations

UI test files are located in the project's `GitHub/GitHubUITests` directory:

- `GitHubUITests.swift` - Comprehensive UI functionality tests (includes navigation, search, profile tests, etc.)
- `GitHubUITestsLaunchTests.swift` - Application launch tests

> **Note**: All UI tests have been integrated into the `GitHubUITests.swift` file, improving code reuse and test maintenance efficiency.

## UI Testing Strategy

This project employs the following UI testing strategies:

1. **Page Element Validation** - Ensuring key UI elements exist and are interactive
2. **User Flow Testing** - Testing user flows for completing specific tasks
3. **Dark Mode Adaptation** - Verifying application appearance in different appearance modes
4. **Performance Testing** - Measuring application launch time and performance of key operations
5. **Helper Method Reuse** - Reducing code duplication through shared helper methods
6. **Visual Verification** - Capturing and verifying interface appearance through screenshots

## UI Testing Best Practices

When writing and maintaining UI tests, follow these best practices:

1. **Use Reliable Identifiers**
   - Set `accessibilityIdentifier` for key UI elements
   - Avoid hardcoded text strings (unless they are fixed titles)

2. **Handle Asynchronous Operations**
   - Use `waitForExistence` or `XCTNSPredicateExpectation` to wait for asynchronous operations to complete
   - Avoid fixed `sleep` times (unless absolutely necessary)

3. **Test Environment Isolation**
   - UI tests should run in any environment, not dependent on specific network states or accounts
   - Consider using mock data or test accounts

4. **Screenshots and Attachments**
   - Add screenshots at key steps for debugging and documentation
   - Use `XCTAttachment` to record test environment information

5. **Common Helper Methods**
   - Create common helper methods to improve code reusability
   - Examples include `findTabByName`, `waitForAnyElement`, etc.

## Common Issues and Solutions

### 1. Element Recognition Issues

**Problem**: UI tests cannot find specific elements.

**Solution**:
- Ensure elements have unique `accessibilityIdentifier`
- Use Xcode's recording feature to identify elements
- Try different query methods, such as `buttons.matching(NSPredicate(...))`
- Use more flexible finding methods, such as `findTabByName` supporting multiple possible names

### 2. Test Stability Issues

**Problem**: UI tests sometimes pass, sometimes fail.

**Solution**:
- Add appropriate waiting mechanisms to ensure UI elements are loaded
- Avoid depending on specific network states or external services
- Increase test robustness by handling possible exception cases
- Add more debugging information, such as printing UI hierarchy

### 3. Login State Management

**Problem**: Tests need to run in both logged-in and logged-out states.

**Solution**:
- Use helper methods to simulate login state
- Consider using test accounts or mock API responses
- Clean application state between tests

### 4. Device Orientation and Appearance Mode Testing

**Problem**: Testing dark mode and device rotation may encounter API limitations.

**Solution**:
- Use suitable alternatives, such as checking interface changes through screenshots
- Use `UIDevice.current.setValue` instead of direct `rotate` methods
- Provide multiple testing options to ensure at least one method works in the current environment

## Notes

- UI tests need to run on simulators or physical devices, cannot run headless in CI environments
- Some tests (such as dark mode tests) require iOS 13.0 or higher
- App icon tests may require special permissions and might not work in some environments
- Before running UI tests, ensure the simulator is in normal state (no pop-ups or other interference) 