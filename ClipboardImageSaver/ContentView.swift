// ContentView.swift
// ClipboardImageSaver
//
// SPDX-License-Identifier: MIT

import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// The main view of the application.
///
/// Displays either a placeholder prompting the user to paste, or a preview of the
/// pasted image with its dimensions and a save button. Supports both `Cmd+V` paste
/// and drag-and-drop of images.
struct ContentView: View {
    @State private var pastedImage: NSImage? = nil
    @State private var statusMessage: String = "Press ⌘V to paste an image from clipboard"
    @State private var showingSaveError: Bool = false
    @State private var saveErrorMessage: String = ""

    var body: some View {
        VStack(spacing: 16) {
            if let image = pastedImage {
                // Image preview
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal)

                // Image info
                HStack {
                    Text("\(Int(image.size.width)) × \(Int(image.size.height)) px")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Save As...") {
                        saveImage()
                    }
                    .keyboardShortcut("s", modifiers: .command)
                    .controlSize(.large)
                }
                .padding(.horizontal)
            } else {
                // Placeholder
                VStack(spacing: 12) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text(statusMessage)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Supported: PNG, JPEG, TIFF, GIF")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .background(pasteHandler())
        .onDrop(of: [.image], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
        .alert("Save Error", isPresented: $showingSaveError) {
            Button("OK") {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    // MARK: - Paste Handler

    /// Invisible view that captures Cmd+V paste events
    private func pasteHandler() -> some View {
        PasteHandlerView {
            readImageFromClipboard()
        }
        .frame(width: 0, height: 0)
    }

    private func readImageFromClipboard() {
        let pasteboard = NSPasteboard.general

        // Try to read an image from the pasteboard
        guard let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil),
              let image = images.first as? NSImage else {
            statusMessage = "No image found on clipboard.\nCopy an image first, then press ⌘V."
            return
        }

        pastedImage = image
        // Automatically show save dialog after pasting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            saveImage()
        }
    }

    // MARK: - Drop Handler

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { nsObject, _ in
                    guard let loadedImage = nsObject as? NSImage else { return }
                    // Create a sendable data representation to cross isolation boundary
                    guard let tiffData = loadedImage.tiffRepresentation else { return }
                    DispatchQueue.main.async {
                        let image = NSImage(data: tiffData)
                        self.pastedImage = image
                        if image != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.saveImage()
                            }
                        }
                    }
                }
                break
            }
        }
    }

    // MARK: - Save

    private func saveImage() {
        guard let image = pastedImage else { return }

        do {
            try ImageSaveHelper.showSaveDialog(for: image)
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

// MARK: - PasteHandlerView

/// An NSView-backed SwiftUI view that captures paste commands.
///
/// SwiftUI doesn't natively expose `Cmd+V` paste events for arbitrary content,
/// so this wraps an `NSView` subclass that becomes first responder and intercepts
/// the keyboard shortcut.
struct PasteHandlerView: NSViewRepresentable {
    let onPaste: () -> Void

    func makeNSView(context: Context) -> PasteReceivingView {
        let view = PasteReceivingView()
        view.onPaste = onPaste
        return view
    }

    func updateNSView(_ nsView: PasteReceivingView, context: Context) {
        nsView.onPaste = onPaste
    }
}

/// A custom `NSView` that accepts first responder status and forwards
/// `Cmd+V` key events to a closure.
class PasteReceivingView: NSView {
    var onPaste: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Become first responder to receive paste commands
        DispatchQueue.main.async {
            self.window?.makeFirstResponder(self)
        }
    }

    // Handle keyDown for Cmd+V
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
            onPaste?()
        } else {
            super.keyDown(with: event)
        }
    }

    // Handle Edit > Paste menu action
    @objc func pasteAction(_ sender: Any?) {
        onPaste?()
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(pasteAction(_:)) {
            return true
        }
        return super.responds(to: aSelector)
    }
}

#Preview {
    ContentView()
}
