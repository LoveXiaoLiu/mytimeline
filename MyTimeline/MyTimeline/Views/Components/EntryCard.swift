//
//  EntryCard.swift
//  MyTimeline
//
//  记录卡片组件 - 展示单条记录
//

import SwiftUI

struct EntryCard: View {
    let entry: Entry
    @EnvironmentObject var dataStore: DataStore
    @State private var isHovered = false
    @State private var isExpanded = false
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    private let maxCollapsedLines = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 内容区域
            contentView
            
            // 标签和时间
            HStack {
                // 标签
                if !entry.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.tags.prefix(3)) { tag in
                            TagBadge(tag: tag)
                        }
                        if entry.tags.count > 3 {
                            Text("+\(entry.tags.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // 时间
                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // AI 处理状态
                if entry.aiProcessed {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .help("AI 已处理")
                }
            }
            
            // AI 提取的关键信息
            if let extractedData = entry.extractedData {
                ExtractedDataView(data: extractedData)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(isHovered ? 0.1 : 0.05), radius: isHovered ? 8 : 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor.opacity(isHovered ? 0.3 : 0), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button("编辑") { showEditSheet = true }
            Button("复制内容") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(entry.content, forType: .string)
            }
            Divider()
            Button("删除", role: .destructive) { showDeleteAlert = true }
        }
        .sheet(isPresented: $showEditSheet) {
            EditEntrySheet(entry: entry)
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                dataStore.deleteEntry(entry)
            }
        } message: {
            Text("删除后无法恢复，确定要删除这条记录吗？")
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        let lines = entry.content.components(separatedBy: .newlines)
        let needsExpansion = lines.count > maxCollapsedLines
        
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.content)
                .lineLimit(isExpanded ? nil : maxCollapsedLines)
                .textSelection(.enabled)
            
            if needsExpansion {
                Button(isExpanded ? "收起" : "展开") {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
    }
}

// MARK: - Tag Badge

struct TagBadge: View {
    let tag: Tag
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(tag.color)
                .frame(width: 6, height: 6)
            Text(tag.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(tag.color.opacity(0.15))
        )
    }
}

// MARK: - Extracted Data View

struct ExtractedDataView: View {
    let data: ExtractedData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 关键指标
            if let metrics = data.metrics, !metrics.isEmpty {
                HStack(spacing: 8) {
                    ForEach(metrics.prefix(3), id: \.name) { metric in
                        HStack(spacing: 4) {
                            if let trend = metric.trend {
                                Image(systemName: trend == "提升" ? "arrow.up.right" : "arrow.down.right")
                                    .font(.caption)
                                    .foregroundColor(trend == "提升" ? .green : .red)
                            }
                            Text("\(metric.name): \(metric.value)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Edit Entry Sheet

struct EditEntrySheet: View {
    let entry: Entry
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: DataStore
    @State private var content: String
    @State private var selectedTags: Set<UUID>
    
    private let colors: [Color] = [
        .blue, .purple, .pink, .red, .orange,
        .yellow, .green, .mint, .teal, .cyan,
        .indigo, .brown, .gray
    ]
    
    init(entry: Entry) {
        self.entry = entry
        self._content = State(initialValue: entry.content)
        self._selectedTags = State(initialValue: Set(entry.tags.map { $0.id }))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("编辑记录")
                .font(.headline)
            
            TextEditor(text: $content)
                .font(.body)
                .frame(minHeight: 150)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
            
            // 标签选择区域
            VStack(alignment: .leading, spacing: 8) {
                Text("标签")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dataStore.allTags) { tag in
                            TagChip(
                                tag: tag,
                                isSelected: selectedTags.contains(tag.id),
                                onTap: {
                                    if selectedTags.contains(tag.id) {
                                        selectedTags.remove(tag.id)
                                    } else {
                                        selectedTags.insert(tag.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("保存") {
                    entry.content = content
                    entry.updatedAt = Date()
                    // 更新标签
                    entry.tags = dataStore.allTags.filter { selectedTags.contains($0.id) }
                    dataStore.updateEntry(entry)
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(tag.color)
                .frame(width: 8, height: 8)
            Text(tag.name)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? tag.color.opacity(0.2) : Color.secondary.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? tag.color : Color.clear, lineWidth: 1.5)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

