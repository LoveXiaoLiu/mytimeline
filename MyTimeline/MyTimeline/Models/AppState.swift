//
//  AppState.swift
//  MyTimeline
//
//  全局应用状态管理
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var showQuickEntry = false
    @Published var selectedDateRange: DateRange = .all
    @Published var selectedTag: Tag? = nil
    @Published var searchQuery = ""
    @Published var showReportGenerator = false
    
    // AI 设置
    @AppStorage("aiProvider") var aiProvider: String = "ollama"
    @AppStorage("openaiApiKey") var openaiApiKey: String = ""
    @AppStorage("ollamaEndpoint") var ollamaEndpoint: String = "http://localhost:11434"
    @AppStorage("ollamaModel") var ollamaModel: String = "llama3.2"
    @AppStorage("autoProcess") var autoProcess: Bool = true
    
    private init() {}
}
