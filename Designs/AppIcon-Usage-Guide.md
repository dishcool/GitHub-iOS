# GitHub iOS App Icon Usage Guide

This document provides detailed instructions on how to use the GitHub iOS app icon in an Xcode project.

## Icon Files

The design folder contains the following icon resources:

- `AppIcon.svg` - Vector format app icon with 1024x1024 resolution
- `AppIcon.png` - PNG format app icon with 1024x1024 resolution (needs to be generated from SVG)

## Using the Icon in Xcode

### Method 1: Using Asset Catalog

1. Open your Xcode project
2. Select Assets.xcassets
3. Right-click and select "New App Icon" (if there's no existing App Icon set)
4. Drag and drop the 1024x1024 PNG icon to the "App Icon - App Store" slot
5. Xcode will automatically generate other required sizes

### Method 2: Using AppIcon Generator

1. Use online tools like [AppIcon Generator](https://appicon.co/) or [MakeAppIcon](https://makeappicon.com/)
2. Upload the 1024x1024 PNG icon
3. Download the generated icon set
4. Replace the AppIcon set in your project's Assets.xcassets with the downloaded set

## Size Requirements

iOS app icons require the following sizes:

| Device | Size (pixels) |
|------|------------|
| iPhone Notification | 20pt (@2x, @3x): 40x40, 60x60 |
| iPhone Settings | 29pt (@2x, @3x): 58x58, 87x87 |
| iPhone Spotlight | 40pt (@2x, @3x): 80x80, 120x120 |
| iPhone App | 60pt (@2x, @3x): 120x120, 180x180 |
| iPad Notification | 20pt (@1x, @2x): 20x20, 40x40 |
| iPad Settings | 29pt (@1x, @2x): 29x29, 58x58 |
| iPad Spotlight | 40pt (@1x, @2x): 40x40, 80x80 |
| iPad App | 76pt (@1x, @2x): 76x76, 152x152 |
| iPad Pro App | 83.5pt (@2x): 167x167 |
| App Store | 1024x1024 |

## Design Guidelines

The design follows these guidelines:

- Uses GitHub's brand elements (Octocat)
- Dark gradient background, consistent with modern iOS design trends
- Rounded rectangle shape, aligning with iOS icon style
- Includes mobile device elements, indicating it's an iOS app
- Uses code symbols `{}` to represent developer tool attributes

## Updating the Icon

To update the icon:

1. Modify the `AppIcon.svg` source file
2. Regenerate the PNG version
3. Update the icon resources in Xcode following the steps above

## Notes

- Ensure the icon is visible on various backgrounds
- Don't include transparent areas in the icon
- The icon should be clearly recognizable even at smaller sizes
- Avoid overly complex designs to ensure clarity at small sizes 