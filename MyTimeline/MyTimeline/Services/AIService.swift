//
//  AIService.swift
//  MyTimeline
//
//  AI 大模型服务 - 支持 OpenAI 兼容接口
//

import Foundation

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    // AI 配置
    struct AIConfig {
        var baseURL: String
        var apiKey: String
        var modelName: String
        
        var isValid: Bool {
            !baseURL.isEmpty && !modelName.isEmpty
        }
    }
    
    // 获取当前配置
    func getConfig() -> AIConfig {
        let defaults = UserDefaults.standard
        return AIConfig(
            baseURL: defaults.string(forKey: "aiBaseURL") ?? "",
            apiKey: defaults.string(forKey: "aiApiKey") ?? "",
            modelName: defaults.string(forKey: "aiModelName") ?? ""
        )
    }
    
    // 保存配置
    func saveConfig(_ config: AIConfig) {
        let defaults = UserDefaults.standard
        defaults.set(config.baseURL, forKey: "aiBaseURL")
        defaults.set(config.apiKey, forKey: "aiApiKey")
        defaults.set(config.modelName, forKey: "aiModelName")
    }
    
    // 自动分类内容
    func classifyContent(_ content: String, existingTags: [Tag]) async throws -> [String] {
        let config = getConfig()
        
        guard config.isValid else {
            throw AIError.invalidConfig
        }
        
        let tagNames = existingTags.map { $0.name }.joined(separator: "、")
        
        let prompt = """
        你是一个工作记录标签提取助手。请从内容中提取**具体的项目名称或需求名称**作为标签。

        【核心规则 - 必须严格遵守】
        1. **精确匹配原则**：只有当内容中**明确出现**已有标签的完整名称时，才使用该已有标签
        2. **不同项目必须分开**：不同的项目/需求名称必须创建不同的标签，例如：
           - "可视化装箱" 和 "新装箱" 是两个不同的项目，必须是两个独立标签
           - "用户系统" 和 "用户认证" 是两个不同的需求，必须是两个独立标签
        3. 禁止模糊关联：不要因为有相似的字就归为同一标签
        4. 提取内容中明确提到的项目/需求名称，保持原文
        5. 禁止使用笼统词：开发、会议、文档、测试、沟通、学习、设计、需求、讨论、功能、增加、私有化、拆分
        6. 标签应是2-8个字的名词短语
        7. 最多返回1-2个标签

        【已有标签供参考】\(tagNames.isEmpty ? "无" : tagNames)

        【待分析内容】\(content)

        请只返回标签名称，用逗号分隔。只有内容中明确出现已有标签原文时才复用，否则创建新标签。
        """
        
        let response = try await callAPI(prompt: prompt, config: config)
        
        // 解析返回的标签
        let tags = response
            .components(separatedBy: CharacterSet(charactersIn: ",，、"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count <= 10 }
        
        return tags
    }
    
    // 调用 API
    private func callAPI(prompt: String, config: AIConfig) async throws -> String {
        var urlString = config.baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 确保 URL 以 /chat/completions 结尾
        if !urlString.hasSuffix("/chat/completions") {
            if urlString.hasSuffix("/v1") {
                urlString += "/chat/completions"
            } else if urlString.hasSuffix("/v1/") {
                urlString += "chat/completions"
            } else if urlString.hasSuffix("/") {
                urlString += "v1/chat/completions"
            } else {
                urlString += "/v1/chat/completions"
            }
        }
        
        guard let url = URL(string: urlString) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !config.apiKey.isEmpty {
            request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "model": config.modelName,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 100,
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError(httpResponse.statusCode, errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parseError
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // 测试连接
    func testConnection() async throws -> String {
        let config = getConfig()
        
        guard config.isValid else {
            throw AIError.invalidConfig
        }
        
        let response = try await callAPI(prompt: "请回复：连接成功", config: config)
        return response
    }
}

// MARK: - Errors

enum AIError: LocalizedError {
    case invalidConfig
    case invalidURL
    case networkError(String)
    case apiError(Int, String)
    case parseError
    
    var errorDescription: String? {
        switch self {
        case .invalidConfig:
            return "AI 配置无效，请检查 URL 和模型名称"
        case .invalidURL:
            return "API URL 格式无效"
        case .networkError(let msg):
            return "网络错误: \(msg)"
        case .apiError(let code, let msg):
            return "API 错误 (\(code)): \(msg)"
        case .parseError:
            return "解析响应失败"
        }
    }
}
