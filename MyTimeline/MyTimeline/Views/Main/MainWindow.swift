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

