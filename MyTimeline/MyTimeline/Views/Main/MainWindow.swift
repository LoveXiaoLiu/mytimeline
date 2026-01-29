//
//  MainWindow.swift
//  MyTimeline
//
//  主窗口视图 - 侧边栏 + 时间轴列表
//

import SwiftUI

struct MainWindow: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            TimelineView()
        }
        .sheet(isPresented: $appState.showQuickEntry) {
            QuickEntrySheet()
        }
        .sheet(isPresented: $appState.showReportGenerator) {
            ReportGeneratorView()
        }
    }
}

// MARK: - Sidebar View

struct SidebarView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var appState: AppState
    @State private var editingTag: Tag?
    @State private var showDeleteAlert = false
    @State private var tagToDelete: Tag?
    
    var body: some View {
        List(selection: Binding(
            get: { appState.selectedTag?.id },
            set: { id in appState.selectedTag = dataStore.allTags.first { $0.id == id } }
        )) {
            Section("时间范围") {
                ForEach([DateRange.all, .today, .thisWeek, .thisMonth], id: \.displayName) { range in
                    HStack {
                        Image(systemName: iconForRange(range))
                        Text(range.displayName)
                        Spacer()
                        let count = dataStore.entries(for: range).count
                        if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.5))
                                .clipShape(Capsule())
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.selectedDateRange = range
                        appState.selectedTag = nil
                    }
                    .padding(.vertical, 4)
                    .background(appState.selectedDateRange == range && appState.selectedTag == nil ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                }
            }
            
            Section("标签") {
                ForEach(dataStore.allTags) { tag in
                    HStack {
                        Circle()
                            .fill(tag.color)
                            .frame(width: 8, height: 8)
                        Text(tag.name)
                        Spacer()
                        let count = dataStore.tagCount(tag)
                        if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(tag.color.opacity(0.7))
                                .clipShape(Capsule())
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.selectedTag = tag
                        appState.selectedDateRange = .all
                    }
                    .padding(.vertical, 4)
                    .background(appState.selectedTag?.id == tag.id ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                    .contextMenu {
                        Button {
                            editingTag = tag
                        } label: {
                            Label("编辑标签", systemImage: "pencil")
                        }
                        Divider()
                        Button(role: .destructive) {
                            tagToDelete = tag
                            showDeleteAlert = true
                        } label: {
                            Label("删除标签", systemImage: "trash")
                        }
                    }
                }
            }
            
            Section {
                Button {
                    appState.showReportGenerator = true
                } label: {
                    Label("生成汇报", systemImage: "doc.text.magnifyingglass")
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
        .navigationTitle("MyTimeline")
        .sheet(item: $editingTag) { tag in
            EditTagSheet(tag: tag)
        }
        .alert("删除标签", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("仅删除标签") {
                if let tag = tagToDelete {
                    if appState.selectedTag?.id == tag.id {
                        appState.selectedTag = nil
                    }
                    dataStore.deleteTag(tag, deleteRelatedEntries: false)
                }
            }
            Button("删除标签和关联记录", role: .destructive) {
                if let tag = tagToDelete {
                    if appState.selectedTag?.id == tag.id {
                        appState.selectedTag = nil
                    }
                    dataStore.deleteTag(tag, deleteRelatedEntries: true)
                }
            }
        } message: {
            if let tag = tagToDelete {
                let count = dataStore.tagCount(tag)
                Text("标签「\(tag.name)」有 \(count) 条关联记录。\n\n• 仅删除标签：保留记录，移除标签\n• 删除标签和关联记录：同时删除所有关联记录")
            }
        }
    }
    
    private func iconForRange(_ range: DateRange) -> String {
        switch range {
        case .all: return "tray.full"
        case .today: return "sun.max"
        case .thisWeek: return "calendar"
        case .thisMonth: return "calendar.badge.clock"
        case .custom: return "calendar.badge.plus"
        }
    }
}

// MARK: - Preview

// MARK: - Edit Tag Sheet

struct EditTagSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: DataStore
    
    let tag: Tag
    @State private var tagName: String = ""
    @State private var selectedColor: Color = .blue
    
    private let colors: [Color] = [
        .blue, .purple, .pink, .red, .orange,
        .yellow, .green, .mint, .teal, .cyan,
        .indigo, .brown, .gray
    ]
    
    init(tag: Tag) {
        self.tag = tag
        _tagName = State(initialValue: tag.name)
        _selectedColor = State(initialValue: tag.color)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("编辑标签")
                .font(.headline)
            
            TextField("标签名称", text: $tagName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("颜色")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(28)), count: 7), spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("保存") {
                    let colorHex = selectedColor.toHex() ?? "#007AFF"
                    dataStore.updateTag(tag, newName: tagName.trimmingCharacters(in: .whitespaces), newColor: colorHex)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(tagName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 280)
    }
}

// MARK: - Color Extension

extension Color {
    func toHex() -> String? {
        guard let components = NSColor(self).usingColorSpace(.deviceRGB)?.cgColor.components else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

