//
//  DataStore.swift
//  MyTimeline
//
//  数据存储服务 - 使用 JSON 文件持久化
//

import Foundation
import Combine

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var entries: [Entry] = []
    @Published var tags: [Tag] = []
    
    private let entriesFileName = "entries.json"
    private let tagsFileName = "tags.json"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var dataDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("MyTimeline", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: appFolder.path) {
            try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }
        
        return appFolder
    }
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        loadData()
    }
    
    // MARK: - Load Data
    
    func loadData() {
        loadEntries()
        loadTags()
    }
    
    private func loadEntries() {
        let fileURL = dataDirectory.appendingPathComponent(entriesFileName)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let loadedEntries = try? decoder.decode([Entry].self, from: data) else {
            entries = []
            return
        }
        entries = loadedEntries.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func loadTags() {
        let fileURL = dataDirectory.appendingPathComponent(tagsFileName)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let loadedTags = try? decoder.decode([Tag].self, from: data) else {
            tags = Tag.defaultTags
            saveTags()
            return
        }
        tags = loadedTags
    }
    
    // MARK: - Save Data
    
    func saveEntries() {
        let fileURL = dataDirectory.appendingPathComponent(entriesFileName)
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: fileURL)
    }
    
    func saveTags() {
        let fileURL = dataDirectory.appendingPathComponent(tagsFileName)
        guard let data = try? encoder.encode(tags) else { return }
        try? data.write(to: fileURL)
    }
    
    // MARK: - Entry Operations
    
    func addEntry(_ entry: Entry) {
        entries.insert(entry, at: 0)
        saveEntries()
    }
    
    func updateEntry(_ entry: Entry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }
    
    func updateEntryTags(entryId: UUID, tags: [Tag]) {
        if let entry = entries.first(where: { $0.id == entryId }) {
            entry.tags = tags
            entry.aiProcessed = true
            saveEntries()
            // 触发 UI 更新
            objectWillChange.send()
        }
    }
    
    func deleteEntry(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }
    
    // MARK: - Tag Operations
    
    func addTag(_ tag: Tag) {
        if !tags.contains(where: { $0.name == tag.name }) {
            tags.append(tag)
            saveTags()
        }
    }
    
    func updateTag(_ tag: Tag, newName: String, newColor: String) {
        // 更新所有 entry 中的标签
        for entry in entries {
            if let index = entry.tags.firstIndex(where: { $0.id == tag.id }) {
                entry.tags[index].name = newName
                entry.tags[index].colorHex = newColor
            }
        }
        saveEntries()
        objectWillChange.send()
    }
    
    func deleteTag(_ tag: Tag, deleteRelatedEntries: Bool = false) {
        if deleteRelatedEntries {
            // 删除所有包含该标签的记录
            entries.removeAll { $0.tags.contains(where: { $0.id == tag.id }) }
        } else {
            // 仅从所有 entry 中移除该标签
            for entry in entries {
                entry.tags.removeAll { $0.id == tag.id }
            }
        }
        tags.removeAll { $0.id == tag.id }
        saveEntries()
        saveTags()
        objectWillChange.send()
    }
    
    // MARK: - Query
    
    func entries(for dateRange: DateRange) -> [Entry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch dateRange {
        case .all:
            return entries
        case .today:
            return entries.filter { calendar.isDateInToday($0.createdAt) }
        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return entries.filter { $0.createdAt >= startOfWeek }
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return entries.filter { $0.createdAt >= startOfMonth }
        case .custom(let start, let end):
            return entries.filter { $0.createdAt >= start && $0.createdAt <= end }
        }
    }
    
    func entries(withTag tag: Tag) -> [Entry] {
        entries.filter { $0.tags.contains(where: { $0.id == tag.id }) }
    }
    
    func search(_ query: String) -> [Entry] {
        guard !query.isEmpty else { return entries }
        let lowercasedQuery = query.lowercased()
        return entries.filter {
            $0.content.lowercased().contains(lowercasedQuery) ||
            $0.tags.contains(where: { $0.name.lowercased().contains(lowercasedQuery) })
        }
    }
    
    // MARK: - Statistics
    
    var allTags: [Tag] {
        var tagSet = Set<Tag>()
        for entry in entries {
            for tag in entry.tags {
                tagSet.insert(tag)
            }
        }
        return Array(tagSet).sorted { $0.name < $1.name }
    }
    
    func tagCount(_ tag: Tag) -> Int {
        entries.filter { $0.tags.contains(where: { $0.id == tag.id }) }.count
    }
}

// MARK: - Date Range

enum DateRange: Equatable {
    case all
    case today
    case thisWeek
    case thisMonth
    case custom(start: Date, end: Date)
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .today: return "今天"
        case .thisWeek: return "本周"
        case .thisMonth: return "本月"
        case .custom: return "自定义"
        }
    }
}
