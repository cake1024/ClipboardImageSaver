# Clipboard Image Saver

[![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)](https://swift.org)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue.svg)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A lightweight macOS app that saves clipboard images to files. Paste an image and a save dialog appears instantly.

<!-- 
To add a screenshot, take a screenshot of the app and place it in the repo:
![Screenshot](screenshot.png)
-->

## Features

- **Paste to save** -- Press `Cmd+V` to paste a clipboard image and immediately get a save dialog
- **Format selection** -- Save as PNG, JPEG, TIFF, or GIF via the file extension dropdown
- **Image preview** -- See the pasted image with dimensions before saving
- **Auto-filename** -- Default filename uses a timestamp (e.g. `clipboard-2026-02-27-143022.png`)
- **Remember last directory** -- The save dialog opens to the last location you saved to
- **Drag-and-drop** -- Drag images directly into the window as an alternative to pasting
- **No dependencies** -- Pure SwiftUI + AppKit, no third-party libraries

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+V`  | Paste image from clipboard and open save dialog |
| `Cmd+S`  | Re-open save dialog for the current image |
| `Cmd+Q`  | Quit |

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ (for building from source)

## Installation

### Option 1: Build from Source

```bash
# Clone the repository
git clone https://github.com/cake1024/ClipboardImageSaver.git
cd ClipboardImageSaver

# Build
xcodebuild -project ClipboardImageSaver.xcodeproj \
  -scheme ClipboardImageSaver \
  -configuration Release \
  build

# Copy to Applications
cp -R "$(xcodebuild -project ClipboardImageSaver.xcodeproj \
  -scheme ClipboardImageSaver \
  -configuration Release \
  -showBuildSettings 2>/dev/null \
  | grep ' BUILT_PRODUCTS_DIR' \
  | awk '{print $3}')/Clipboard Image Saver.app" /Applications/
```

Or open `ClipboardImageSaver.xcodeproj` in Xcode and press `Cmd+B` to build.

### Option 2: Download Release

Download the latest `.app` from the [Releases](../../releases) page and move it to `/Applications`.

## Usage

1. Copy an image to your clipboard (screenshot, browser, any app)
2. Open **Clipboard Image Saver**
3. Press `Cmd+V` -- the image preview appears and the save dialog opens automatically
4. Choose a format from the file extension dropdown and pick a save location
5. To save again, press `Cmd+S` to re-open the save dialog

## Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| PNG    | `.png`    | Default. Lossless compression. |
| JPEG   | `.jpg`    | Lossy, 90% quality. |
| TIFF   | `.tiff`   | Lossless. Large file size. |
| GIF    | `.gif`    | Limited to 256 colors. |

## Project Structure

```
ClipboardImageSaver/
├── ClipboardImageSaver.xcodeproj/       # Xcode project
├── ClipboardImageSaver/
│   ├── ClipboardImageSaverApp.swift     # App entry point, window configuration
│   ├── ContentView.swift                # Main UI: paste handling, image preview, drag-and-drop
│   └── ImageSaveHelper.swift            # Save dialog, format conversion, directory memory
├── .gitignore
├── LICENSE
├── README.md
└── CONTRIBUTING.md
```

## Troubleshooting

**macOS blocks the app from opening ("not notarized" / "unidentified developer")**
Because the app is not code-signed or notarized by Apple, macOS Gatekeeper will block it on first launch. To open it:

1. Try to open the app (it will be blocked).
2. Go to **System Settings > Privacy & Security**, scroll down, and click **Open Anyway**.
3. Confirm in the follow-up prompt.

After that, the app opens normally like any other app. See [Apple's official guide on opening unsigned apps](https://support.apple.com/en-us/102445) for more details.

**"No image found on clipboard"**
Make sure you copied an actual image (not a file). For example, use `Cmd+Shift+Ctrl+4` to capture a screen region to the clipboard, or right-click an image in a browser and select "Copy Image".

**Paste doesn't work / nothing happens**
Click inside the app window first to ensure it has focus, then press `Cmd+V`.

**Build fails with Swift concurrency errors**
Make sure you're using Xcode 15 or later. The project uses Swift 6 with `SWIFT_STRICT_CONCURRENCY` set to `minimal`.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
