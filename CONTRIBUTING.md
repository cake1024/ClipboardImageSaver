# Contributing to Clipboard Image Saver

Thanks for your interest in contributing! This is a small project and contributions of all kinds are welcome.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Open `ClipboardImageSaver.xcodeproj` in Xcode, or build from the command line:
   ```bash
   xcodebuild -project ClipboardImageSaver.xcodeproj \
     -scheme ClipboardImageSaver \
     -configuration Debug \
     build
   ```

## Making Changes

1. Create a branch for your change:
   ```bash
   git checkout -b my-feature
   ```
2. Make your changes
3. Test the app manually -- copy an image, paste it, verify the save dialog works
4. Commit with a clear message describing **what** and **why**

## Submitting a Pull Request

1. Push your branch to your fork
2. Open a pull request against `main`
3. Describe what your change does and why

## Code Style

- Follow standard Swift conventions
- Use `// MARK: -` sections to organize code within files
- Add doc comments (`///`) for public types and methods
- Keep functions focused and short

## Reporting Issues

If you find a bug or have a feature request, please [open an issue](../../issues) with:

- **Bug reports**: Steps to reproduce, expected behavior, actual behavior, macOS version
- **Feature requests**: What you'd like and why it would be useful

## Project Notes

- The app targets macOS 14.0+ and uses Swift 6 with SwiftUI
- No third-party dependencies
