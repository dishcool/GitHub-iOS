# GitHub iOS App - Setup Guide

This document provides detailed steps for setting up the GitHub iOS application, including adding dependencies, configuring OAuth, and completing project setup.

## Adding Swift Package Manager Dependencies

1. Open the Xcode project
2. Select File > Add Packages...
3. Add the following packages in the search bar (add one by one):

### Alamofire
- URL: https://github.com/Alamofire/Alamofire.git
- Version: Up to Next Major (5.0.0)
- Dependency Rule: 5.6.0 <= version < 6.0.0

### Kingfisher
- URL: https://github.com/onevcat/Kingfisher.git
- Version: Up to Next Major (7.0.0) 
- Dependency Rule: 7.0.0 <= version < 8.0.0

### SwiftyJSON
- URL: https://github.com/SwiftyJSON/SwiftyJSON.git
- Version: Up to Next Major (5.0.0)
- Dependency Rule: 5.0.0 <= version < 6.0.0

### KeychainSwift
- URL: https://github.com/evgenyneu/keychain-swift.git
- Version: Up to Next Major (20.0.0)
- Dependency Rule: 20.0.0 <= version < 21.0.0

### OAuthSwift
- URL: https://github.com/OAuthSwift/OAuthSwift.git
- Version: Up to Next Major (2.0.0)
- Dependency Rule: 2.2.0 <= version < 3.0.0

## Project Setup

### Update iOS Deployment Target
1. Select the project in the project navigator
2. Select the GitHub target
3. In the "General" tab, set "iOS Deployment Target" under "Deployment Info" to 14.0

### Add Face ID Permission
1. Open the Info.plist file
2. Add a new key: NSFaceIDUsageDescription
3. Set the value to: "Use Face ID to log in to your GitHub account"

### Configure URL Scheme for OAuth Callback
1. Select the project in the project navigator
2. Select the GitHub target
3. Select the "Info" tab
4. Expand the "URL Types" section
5. Click the "+" button to add a new URL Type
6. Set the Identifier to "com.yourcompany.github"
7. Set URL Schemes to "github"

### Create Missing Directory Structure
Ensure that the following directory structure is created in your project:

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

## GitHub OAuth Configuration

To use the GitHub OAuth functionality, you need to:

1. Register a new OAuth application on GitHub:
   - Visit https://github.com/settings/applications/new
   - Fill in the application name, homepage URL (can be any URL)
   - Set the callback URL to `github://callback`
   - Click Register Application

2. After obtaining the Client ID and Client Secret, update the values in AuthenticationService.swift:

```swift
private let clientID = "YOUR_GITHUB_CLIENT_ID"
private let clientSecret = "YOUR_GITHUB_CLIENT_SECRET"
```

## Views to Implement

To complete the application, you still need to implement the following SwiftUI views:

1. HomeView.swift - Display popular repositories
2. SearchView.swift - Search for repositories, users, and organizations
3. ProfileView.swift - Display user profile and repositories
4. LoginView.swift - GitHub login interface
5. RepositoryDetailView.swift - Repository details page

## Localization Support

To add Chinese localization support:

1. Select the project in the project navigator
2. Select the GitHub target
3. Click the "+" button, select "New File..."
4. Select "Strings File", name it "Localizable"
5. After creation, select this file in the project navigator
6. Click the "Localize..." button in the right inspector
7. Select "Chinese (Simplified)"

## Testing

After implementing the UI, create unit tests and UI tests:

1. Create unit tests for the service layer
2. Create unit tests for view models
3. Create UI tests for major user flows

## Final Steps

1. Clean up the project, ensure all files are added to the correct target
2. Build and run the project, ensure there are no compilation errors
3. Test the main functionality, ensure everything works correctly

Good luck with your development!