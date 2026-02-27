// ClipboardImageSaverApp.swift
// ClipboardImageSaver
//
// SPDX-License-Identifier: MIT

import SwiftUI

/// The main entry point for the Clipboard Image Saver application.
@main
struct ClipboardImageSaverApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 500)
    }
}
