//
//  Entry.swift
//  MyTimeline
//
//  记录条目数据模型 - 使用 Codable 进行 JSON 存储
//

import Foundation
import SwiftUI

// MARK: - Entry Model

class Entry: Identifiable, Codable, ObservableObject {
    var id: UUID
    @Published var content: String
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var tags: [Tag]
    @Published var aiProcessed: Bool
    @Published var extractedData: ExtractedData?
    
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, updatedAt, tags, aiProcessed, extractedData
    }
    
    init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [Tag] = [],
        aiProcessed: Bool = false,
        extractedData: ExtractedData? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.aiProcessed = aiProcessed
        self.extractedData = extractedData
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
        aiProcessed = try container.decodeIfPresent(Bool.self, forKey: .aiProcessed) ?? false
        extractedData = try container.decodeIfPresent(ExtractedData.self, forKey: .extractedData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(tags, forKey: .tags)
        try container.encode(aiProcessed, forKey: .aiProcessed)
        try container.encodeIfPresent(extractedData, forKey: .extractedData)
    }
}

// MARK: - Computed Properties

extension Entry {
    var summary: String {
        let firstLine = content.components(separatedBy: .newlines).first ?? content
        if firstLine.count > 100 {
            return String(firstLine.prefix(100)) + "..."
        }
        return firstLine
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(createdAt) {
            formatter.dateFormat = "HH:mm"
            return "今天 " + formatter.string(from: createdAt)
        } else if calendar.isDateInYesterday(createdAt) {
            formatter.dateFormat = "HH:mm"
            return "昨天 " + formatter.string(from: createdAt)
        } else if calendar.isDate(createdAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        
        return formatter.string(from: createdAt)
    }
}

// MARK: - Extracted Data

struct ExtractedData: Codable, Equatable {
    var metrics: [Metric]?
    var dates: [String]?
    var projects: [String]?
    var summary: String?
    
    struct Metric: Codable, Equatable {
        var name: String
        var value: String
        var trend: String?
    }
}

// MARK: - Sample Data

extension Entry {
    static var sampleEntries: [Entry] {
        [
            Entry(
                content: "完成了用户认证模块的开发，使用 JWT 实现登录功能，性能测试显示响应时间 < 100ms",
                createdAt: Date(),
                tags: [Tag(name: "开发", colorHex: "007AFF"), Tag(name: "后端", colorHex: "34C759")],
                aiProcessed: true,
                extractedData: ExtractedData(
                    metrics: [ExtractedData.Metric(name: "响应时间", value: "< 100ms", trend: "提升")],
                    projects: ["用户认证模块"]
                )
            ),
            Entry(
                content: "参加产品评审会议，讨论 Q1 需求优先级，确定首批上线 5 个核心功能",
                createdAt: Date().addingTimeInterval(-86400),
                tags: [Tag(name: "会议", colorHex: "FF9500")],
                aiProcessed: true
            ),
            Entry(
                content: "修复线上 Bug #1234，用户反馈的支付失败问题，根因是第三方接口超时",
                createdAt: Date().addingTimeInterval(-172800),
                tags: [Tag(name: "Bug修复", colorHex: "FF3B30")],
                aiProcessed: true
            )
        ]
    }
}
