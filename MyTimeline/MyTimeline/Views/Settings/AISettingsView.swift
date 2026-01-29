//
//  AISettingsView.swift
//  MyTimeline
//
//  AI 大模型配置界面
//

import SwiftUI

struct AISettingsView: View {
    @AppStorage("aiBaseURL") private var baseURL = ""
    @AppStorage("aiApiKey") private var apiKey = ""
    @AppStorage("aiModelName") private var modelName = ""
    @AppStorage("aiAutoClassify") private var autoClassify = true
    
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var testSuccess = false
    @State private var showApiKey = false
    
    private let labelWidth: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 模型配置
            GroupBox("模型配置") {
                VStack(spacing: 12) {
                    HStack {
                        Text("API 地址")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("https://api.openai.com", text: $baseURL)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("API 密钥")
                            .frame(width: labelWidth, alignment: .trailing)
                        if showApiKey {
                            TextField("sk-... (可选)", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("sk-... (可选)", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        }
                        Button {
                            showApiKey.toggle()
                        } label: {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    HStack {
                        Text("模型名称")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("gpt-4o-mini", text: $modelName)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(8)
            }
            
            // 功能设置
            GroupBox("功能设置") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("自动分类", isOn: $autoClassify)
                    Text("新建记录时自动调用 AI 识别标签")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }
            
            // 测试连接
            HStack {
                Button {
                    testConnection()
                } label: {
                    HStack(spacing: 4) {
                        if isTesting {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        Text(isTesting ? "测试中..." : "测试连接")
                    }
                }
                .disabled(isTesting || baseURL.isEmpty || modelName.isEmpty)
                
                if let result = testResult {
                    HStack(spacing: 4) {
                        Image(systemName: testSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(testSuccess ? .green : .red)
                        Text(result)
                            .font(.caption)
                            .foregroundColor(testSuccess ? .green : .red)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 280)
    }
    
    private func testConnection() {
        isTesting = true
        testResult = nil
        
        Task {
            do {
                AIService.shared.saveConfig(AIService.AIConfig(
                    baseURL: baseURL,
                    apiKey: apiKey,
                    modelName: modelName
                ))
                
                let response = try await AIService.shared.testConnection()
                await MainActor.run {
                    testResult = "成功"
                    testSuccess = true
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = error.localizedDescription.prefix(30) + "..."
                    testSuccess = false
                    isTesting = false
                }
            }
        }
    }
}
