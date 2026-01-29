//
//  SettingsView.swift
//  MyTimeline
//
//  设置视图
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }
            
            AIConfigView()
                .tabItem {
                    Label("AI 模型", systemImage: "brain")
                }
            
            DataSettingsView()
                .tabItem {
                    Label("数据", systemImage: "externaldrive")
                }
        }
        .frame(width: 520, height: 550)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    
    var body: some View {
        Form {
            Section {
                Toggle("登录时启动", isOn: $launchAtLogin)
                Toggle("显示菜单栏图标", isOn: $showMenuBarIcon)
            }
            
            Section("快捷键") {
                HStack {
                    Text("快速记录")
                    Spacer()
                    Text("⌘ + Shift + N")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - AI Config View (使用独立文件中的 AISettingsView)

struct AIConfigView: View {
    var body: some View {
        AISettingsView()
    }
}

// MARK: - Data Settings

struct DataSettingsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showExportAlert = false
    @State private var showClearAlert = false
    
    var body: some View {
        Form {
            Section("数据统计") {
                HStack {
                    Text("记录总数")
                    Spacer()
                    Text("\(dataStore.entries.count)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("标签总数")
                    Spacer()
                    Text("\(dataStore.allTags.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("数据管理") {
                Button("导出数据") {
                    exportData()
                }
                
                Button("清除所有数据", role: .destructive) {
                    showClearAlert = true
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .alert("确认清除", isPresented: $showClearAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("此操作将删除所有记录和标签，且无法恢复。")
        }
    }
    
    private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "mytimeline_export.json"
        
        if panel.runModal() == .OK, let url = panel.url {
            let exportData = ExportData(entries: dataStore.entries, tags: dataStore.tags)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            if let data = try? encoder.encode(exportData) {
                try? data.write(to: url)
            }
        }
    }
    
    private func clearAllData() {
        dataStore.entries.removeAll()
        dataStore.tags = Tag.defaultTags
        dataStore.saveEntries()
        dataStore.saveTags()
    }
}

struct ExportData: Codable {
    let entries: [Entry]
    let tags: [Tag]
}

// MARK: - Preview

