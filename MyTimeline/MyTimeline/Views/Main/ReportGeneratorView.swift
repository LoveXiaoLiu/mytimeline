//
//  ReportGeneratorView.swift
//  MyTimeline
//
//  AI 汇报生成视图
//

import SwiftUI

struct ReportGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var appState: AppState
    
    @State private var selectedRange: ReportRange = .thisWeek
    @State private var selectedTags: Set<Tag> = []
    @State private var reportFormat: ReportFormat = .summary
    @State private var generatedReport = ""
    @State private var isGenerating = false
    
    enum ReportRange: String, CaseIterable {
        case today = "今天"
        case thisWeek = "本周"
        case thisMonth = "本月"
        case custom = "自定义"
    }
    
    enum ReportFormat: String, CaseIterable {
        case summary = "工作摘要"
        case detailed = "详细报告"
        case bullet = "要点列表"
    }
    
    var filteredEntries: [Entry] {
        let dateRange: DateRange
        switch selectedRange {
        case .today: dateRange = .today
        case .thisWeek: dateRange = .thisWeek
        case .thisMonth: dateRange = .thisMonth
        case .custom: dateRange = .all
        }
        
        var entries = dataStore.entries(for: dateRange)
        
        if !selectedTags.isEmpty {
            entries = entries.filter { entry in
                entry.tags.contains { selectedTags.contains($0) }
            }
        }
        
        return entries
    }
    
    var body: some View {
        HSplitView {
            // 左侧配置面板
            VStack(alignment: .leading, spacing: 20) {
                Text("生成汇报")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // 时间范围
                VStack(alignment: .leading, spacing: 8) {
                    Text("时间范围")
                        .font(.headline)
                    
                    Picker("", selection: $selectedRange) {
                        ForEach(ReportRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 标签筛选
                VStack(alignment: .leading, spacing: 8) {
                    Text("标签筛选（可选）")
                        .font(.headline)
                    
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
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // 报告格式
                VStack(alignment: .leading, spacing: 8) {
                    Text("报告格式")
                        .font(.headline)
                    
                    Picker("", selection: $reportFormat) {
                        ForEach(ReportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 统计信息
                VStack(alignment: .leading, spacing: 4) {
                    Text("将处理 \(filteredEntries.count) 条记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 操作按钮
                HStack {
                    Button("取消") {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    Button {
                        generateReport()
                    } label: {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Label("生成汇报", systemImage: "sparkles")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(filteredEntries.isEmpty || isGenerating)
                }
            }
            .padding()
            .frame(minWidth: 300, maxWidth: 350)
            
            // 右侧预览面板
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("汇报预览")
                        .font(.headline)
                    
                    Spacer()
                    
                    if !generatedReport.isEmpty {
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(generatedReport, forType: .string)
                        } label: {
                            Label("复制", systemImage: "doc.on.doc")
                        }
                    }
                }
                
                if generatedReport.isEmpty {
                    VStack {
                        Spacer()
                        Text("点击「生成汇报」查看结果")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        Text(generatedReport)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(nsColor: .textBackgroundColor))
                    )
                }
            }
            .padding()
            .frame(minWidth: 400)
        }
        .frame(width: 800, height: 500)
    }
    
    private func generateReport() {
        isGenerating = true
        
        // 生成简单的本地汇报（不调用 AI）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generatedReport = generateLocalReport()
            isGenerating = false
        }
    }
    
    private func generateLocalReport() -> String {
        let entries = filteredEntries
        guard !entries.isEmpty else { return "没有找到符合条件的记录。" }
        
        var report = ""
        
        switch reportFormat {
        case .summary:
            report = "## \(selectedRange.rawValue)工作汇报\n\n"
            report += "共完成 \(entries.count) 项工作记录。\n\n"
            
            // 按标签分组统计
            let tagGroups = Dictionary(grouping: entries.flatMap { $0.tags }) { $0.name }
            if !tagGroups.isEmpty {
                report += "### 工作分类\n"
                for (tagName, tags) in tagGroups.sorted(by: { $0.value.count > $1.value.count }) {
                    report += "- \(tagName): \(tags.count) 项\n"
                }
                report += "\n"
            }
            
            report += "### 主要内容\n"
            for entry in entries.prefix(5) {
                report += "- \(entry.summary)\n"
            }
            if entries.count > 5 {
                report += "- ...等 \(entries.count - 5) 项\n"
            }
            
        case .detailed:
            report = "## \(selectedRange.rawValue)详细工作报告\n\n"
            
            let grouped = Dictionary(grouping: entries) { entry -> String in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: entry.createdAt)
            }
            
            for (date, dayEntries) in grouped.sorted(by: { $0.key > $1.key }) {
                report += "### \(date)\n\n"
                for entry in dayEntries {
                    report += "- \(entry.content)\n"
                    if !entry.tags.isEmpty {
                        report += "  标签: \(entry.tags.map { $0.name }.joined(separator: ", "))\n"
                    }
                    report += "\n"
                }
            }
            
        case .bullet:
            report = "## \(selectedRange.rawValue)工作要点\n\n"
            for entry in entries {
                report += "• \(entry.summary)\n"
            }
        }
        
        return report
    }
}

// MARK: - Preview

