//
//  QuickEntrySheet.swift
//  MyTimeline
//
//  快速记录输入界面
//

import SwiftUI

struct QuickEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var appState: AppState
    
    @State private var content = ""
    @State private var selectedTags: Set<Tag> = []
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题栏
            HStack {
                Text("快速记录")
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // 输入区域
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $content)
                    .font(.body)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(nsColor: .textBackgroundColor))
                    )
                    .focused($isFocused)
                
                Text("支持 #标签 语法，AI 将在后台自动分析并添加标签")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 已有标签
            if !dataStore.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dataStore.allTags) { tag in
                            Button {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 6, height: 6)
                                    Text(tag.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedTags.contains(tag) ? tag.color.opacity(0.3) : Color(nsColor: .controlBackgroundColor))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedTags.contains(tag) ? tag.color : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // 操作按钮
            HStack {
                Spacer()
                
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("保存") {
                    saveEntry()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 320)
        .onAppear {
            isFocused = true
        }
    }
    
    private func saveEntry() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        // 解析内容中的 #标签
        var tags = Array(selectedTags)
        let tagPattern = "#([\\w\\u4e00-\\u9fa5]+)"
        if let regex = try? NSRegularExpression(pattern: tagPattern, options: []) {
            let nsContent = trimmedContent as NSString
            let matches = regex.matches(in: trimmedContent, options: [], range: NSRange(location: 0, length: nsContent.length))
            for match in matches {
                if match.numberOfRanges > 1 {
                    let tagName = nsContent.substring(with: match.range(at: 1))
                    if !tags.contains(where: { $0.name == tagName }) {
                        let newTag = Tag(name: tagName, colorHex: randomColorHex())
                        tags.append(newTag)
                        dataStore.addTag(newTag)
                    }
                }
            }
        }
        
        // 先立即保存 entry（无标签或已有标签）
        let entry = Entry(
            content: trimmedContent,
            tags: tags
        )
        dataStore.addEntry(entry)
        
        // 立即关闭窗口，不等待 AI
        dismiss()
        
        // 如果没有手动选择标签，且启用了自动分类，则在后台调用 AI
        let defaults = UserDefaults.standard
        let autoClassify = defaults.object(forKey: "aiAutoClassify") == nil ? true : defaults.bool(forKey: "aiAutoClassify")
        let config = AIService.shared.getConfig()
        
        if tags.isEmpty && autoClassify && config.isValid {
            // 后台异步处理 AI 分类
            let entryId = entry.id
            let allTags = dataStore.allTags
            
            Task.detached {
                do {
                    print("[AI] 后台开始分析: \(trimmedContent.prefix(30))...")
                    let suggestedTagNames = try await AIService.shared.classifyContent(trimmedContent, existingTags: allTags)
                    
                    await MainActor.run { [dataStore] in
                        var newTags: [Tag] = []
                        for tagName in suggestedTagNames {
                            // 模糊匹配已有标签
                            let normalizedName = tagName.lowercased().replacingOccurrences(of: " ", with: "")
                            if let existingTag = dataStore.allTags.first(where: { 
                                $0.name.lowercased().replacingOccurrences(of: " ", with: "") == normalizedName ||
                                $0.name.contains(tagName) ||
                                tagName.contains($0.name)
                            }) {
                                if !newTags.contains(where: { $0.id == existingTag.id }) {
                                    newTags.append(existingTag)
                                    print("[AI] 复用已有标签: \(existingTag.name)")
                                }
                            } else {
                                let colors = ["007AFF", "34C759", "FF9500", "FF3B30", "AF52DE", "5AC8FA", "FFCC00", "FF2D55"]
                                let newTag = Tag(name: tagName, colorHex: colors.randomElement() ?? "007AFF")
                                newTags.append(newTag)
                                dataStore.addTag(newTag)
                                print("[AI] 创建新标签: \(tagName)")
                            }
                        }
                        
                        // 更新 entry 的标签
                        if !newTags.isEmpty {
                            dataStore.updateEntryTags(entryId: entryId, tags: newTags)
                            print("[AI] 已更新记录标签: \(newTags.map { $0.name })")
                        }
                    }
                } catch {
                    print("[AI] 后台分析错误: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func randomColorHex() -> String {
        let colors = ["007AFF", "34C759", "FF9500", "FF3B30", "AF52DE", "5AC8FA", "FFCC00", "FF2D55"]
        return colors.randomElement() ?? "007AFF"
    }
}

// MARK: - Preview

