//
//  TimelineView.swift
//  MyTimeline
//
//  时间轴视图 - 现代简约设计
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var appState: AppState
    
    var filteredEntries: [Entry] {
        var result: [Entry]
        
        if let tag = appState.selectedTag {
            result = dataStore.entries(withTag: tag)
        } else {
            result = dataStore.entries(for: appState.selectedDateRange)
        }
        
        if !appState.searchQuery.isEmpty {
            result = result.filter {
                $0.content.localizedCaseInsensitiveContains(appState.searchQuery) ||
                $0.tags.contains(where: { $0.name.localizedCaseInsensitiveContains(appState.searchQuery) })
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("搜索记录...", text: $appState.searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                
                Spacer()
                
                Button {
                    appState.showQuickEntry = true
                } label: {
                    Label("新建记录", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut("n", modifiers: .command)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // 时间轴内容
            if filteredEntries.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        let totalCount = filteredEntries.count
                        let lineColor = appState.selectedTag?.color ?? Color.accentColor
                        ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                            TimelineRow(
                                entry: entry,
                                isFirst: index == 0,
                                isLast: index == filteredEntries.count - 1,
                                progress: totalCount > 1 ? Double(index) / Double(totalCount - 1) : 0,
                                timelineColor: lineColor
                            )
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.leading, 20)
                }
            }
        }
        .navigationTitle(navigationTitle)
    }
    
    private var navigationTitle: String {
        if let tag = appState.selectedTag {
            return "#\(tag.name)"
        }
        return appState.selectedDateRange.displayName
    }
}

// MARK: - Timeline Row

struct TimelineRow: View {
    let entry: Entry
    let isFirst: Bool
    let isLast: Bool
    let progress: Double  // 0.0 = 顶部, 1.0 = 底部
    var timelineColor: Color = .accentColor  // 时间线颜色，可由外部传入
    
    @EnvironmentObject var dataStore: DataStore
    @State private var isHovered = false
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    // 根据位置计算颜色深浅
    private var lineOpacity: Double {
        0.6 - progress * 0.4  // 0.6 -> 0.2
    }
    
    private var dotOpacity: Double {
        1.0 - progress * 0.5  // 1.0 -> 0.5
    }
    
    private var contentOpacity: Double {
        1.0 - progress * 0.3  // 1.0 -> 0.7
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 左侧：时间线
            timelineIndicator
            
            // 右侧：内容卡片
            contentCard
                .padding(.trailing, 20)
                .padding(.bottom, 12)
        }
    }
    
    // MARK: - 时间线指示器（简约设计）
    
    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            // 上方连接线
            if !isFirst {
                Rectangle()
                    .fill(timelineColor.opacity(lineOpacity))
                    .frame(width: 2, height: 12)
            } else {
                Spacer().frame(height: 12)
            }
            
            // 圆点
            Circle()
                .fill(timelineColor.opacity(dotOpacity))
                .frame(width: 8, height: 8)
            
            // 下方连接线
            if !isLast {
                Rectangle()
                    .fill(timelineColor.opacity(lineOpacity * 0.7))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 8)
    }
    
    // MARK: - 内容卡片
    
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 时间标签
            Text(formattedTime)
                .font(.caption)
                .foregroundColor(.secondary.opacity(contentOpacity))
            
            // 内容
            Text(entry.content)
                .font(.body)
                .lineLimit(5)
                .textSelection(.enabled)
                .foregroundColor(.primary.opacity(contentOpacity))
            
            // 标签
            if !entry.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.tags.prefix(4)) { tag in
                        Text(tag.name)
                            .font(.caption)
                            .foregroundColor(tag.color.opacity(contentOpacity))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(tag.color.opacity(0.1 * contentOpacity))
                            )
                    }
                    
                    if entry.tags.count > 4 {
                        Text("+\(entry.tags.count - 4)")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(contentOpacity * 0.7))
                    }
                    
                    if entry.aiProcessed {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundColor(.purple.opacity(contentOpacity * 0.8))
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6 + contentOpacity * 0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(timelineColor.opacity(isHovered ? 0.3 : 0), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
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
    
    // MARK: - Helpers
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(entry.createdAt) {
            formatter.dateFormat = "今天 HH:mm"
        } else if calendar.isDateInYesterday(entry.createdAt) {
            formatter.dateFormat = "昨天 HH:mm"
        } else if calendar.isDate(entry.createdAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "M月d日 HH:mm"
        } else {
            formatter.dateFormat = "yyyy年M月d日 HH:mm"
        }
        
        return formatter.string(from: entry.createdAt)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("暂无记录")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("点击右上角的「新建记录」或按 ⌘+N 开始记录")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button {
                appState.showQuickEntry = true
            } label: {
                Label("创建第一条记录", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
