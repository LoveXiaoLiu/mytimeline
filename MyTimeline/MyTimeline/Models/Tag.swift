//
//  Tag.swift
//  MyTimeline
//
//  标签数据模型
//

import Foundation
import SwiftUI

struct Tag: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var colorHex: String
    
    init(id: UUID = UUID(), name: String, colorHex: String = "007AFF") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .accentColor
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Default Tags

extension Tag {
    static let defaultTags: [Tag] = [
        Tag(name: "开发", colorHex: "007AFF"),
        Tag(name: "会议", colorHex: "FF9500"),
        Tag(name: "文档", colorHex: "34C759"),
        Tag(name: "Bug修复", colorHex: "FF3B30"),
        Tag(name: "学习", colorHex: "AF52DE"),
        Tag(name: "沟通", colorHex: "5AC8FA"),
    ]
}
