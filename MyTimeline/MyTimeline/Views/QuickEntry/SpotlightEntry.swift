//
//  SpotlightEntry.swift
//  MyTimeline
//
//  类似 Spotlight 的快速输入框
//

import SwiftUI
import AppKit

// MARK: - Spotlight 样式输入窗口

class SpotlightWindowController: NSWindowController {
    static let shared = SpotlightWindowController()
    
    private init() {
        let window = SpotlightWindow()
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        guard let window = window as? SpotlightWindow else { return }
        window.showCentered()
    }
    
    func hide() {
        window?.orderOut(nil)
    }
}

// MARK: - Spotlight Window

class SpotlightWindow: NSPanel {
    private var hostingView: NSHostingView<SpotlightEntryView>?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 54),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        
        // 点击外部关闭
        hidesOnDeactivate = true
        
        let entryView = SpotlightEntryView { [weak self] in
            self?.orderOut(nil)
        }
        
        hostingView = NSHostingView(rootView: entryView)
        contentView = hostingView
    }
    
    func showCentered() {
        // 居中显示在屏幕上方
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowWidth: CGFloat = 680
            let windowHeight: CGFloat = 54
            let x = screenFrame.midX - windowWidth / 2
            let y = screenFrame.maxY - 200
            
            setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
        }
        
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - Spotlight Entry View

struct SpotlightEntryView: View {
    @State private var content = ""
    @FocusState private var isFocused: Bool
    
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pencil.line")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.secondary)
            
            TextField("记录一下...", text: $content)
                .textFieldStyle(.plain)
                .font(.system(size: 22, weight: .light))
                .focused($isFocused)
                .onSubmit {
                    saveAndDismiss()
                }
                .onExitCommand {
                    onDismiss()
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            VisualEffectBlur(material: .popover, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 20, y: 5)
        .onAppear {
            isFocused = true
            content = ""
        }
    }
    
    private func saveAndDismiss() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            onDismiss()
            return
        }
        
        // 解析 #标签
        var tags: [Tag] = []
        let tagPattern = "#([\\w\\u4e00-\\u9fa5]+)"
        if let regex = try? NSRegularExpression(pattern: tagPattern, options: []) {
            let nsContent = trimmed as NSString
            let matches = regex.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsContent.length))
            for match in matches {
                if match.numberOfRanges > 1 {
                    let tagName = nsContent.substring(with: match.range(at: 1))
                    if !tags.contains(where: { $0.name == tagName }) {
                        // 查找已有标签或创建新标签
                        if let existingTag = DataStore.shared.allTags.first(where: { $0.name == tagName }) {
                            tags.append(existingTag)
                        } else {
                            let colors = ["007AFF", "34C759", "FF9500", "FF3B30", "AF52DE", "5AC8FA"]
                            let newTag = Tag(name: tagName, colorHex: colors.randomElement() ?? "007AFF")
                            tags.append(newTag)
                            DataStore.shared.addTag(newTag)
                        }
                    }
                }
            }
        }
        
        // 保存
        let entry = Entry(content: trimmed, tags: tags)
        DataStore.shared.addEntry(entry)
        
        // 后台 AI 分析
        if tags.isEmpty {
            let defaults = UserDefaults.standard
            let autoClassify = defaults.object(forKey: "aiAutoClassify") == nil ? true : defaults.bool(forKey: "aiAutoClassify")
            let config = AIService.shared.getConfig()
            
            if autoClassify && config.isValid {
                let entryId = entry.id
                let allTags = DataStore.shared.allTags
                
                Task.detached {
                    do {
                        let suggestedTagNames = try await AIService.shared.classifyContent(trimmed, existingTags: allTags)
                        await MainActor.run {
                            var newTags: [Tag] = []
                            for tagName in suggestedTagNames {
                                let normalizedName = tagName.lowercased().replacingOccurrences(of: " ", with: "")
                                if let existingTag = DataStore.shared.allTags.first(where: {
                                    $0.name.lowercased().replacingOccurrences(of: " ", with: "") == normalizedName ||
                                    $0.name.contains(tagName) ||
                                    tagName.contains($0.name)
                                }) {
                                    if !newTags.contains(where: { $0.id == existingTag.id }) {
                                        newTags.append(existingTag)
                                    }
                                } else {
                                    let colors = ["007AFF", "34C759", "FF9500", "FF3B30", "AF52DE", "5AC8FA"]
                                    let newTag = Tag(name: tagName, colorHex: colors.randomElement() ?? "007AFF")
                                    newTags.append(newTag)
                                    DataStore.shared.addTag(newTag)
                                }
                            }
                            if !newTags.isEmpty {
                                DataStore.shared.updateEntryTags(entryId: entryId, tags: newTags)
                            }
                        }
                    } catch {
                        print("[AI] 分析错误: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        onDismiss()
    }
}

// MARK: - Visual Effect Blur

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
