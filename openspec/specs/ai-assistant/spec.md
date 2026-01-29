# ai-assistant Specification

## Purpose
TBD - created by archiving change add-macos-timeline-app. Update Purpose after archive.
## Requirements
### Requirement: AI Auto Processing
系统 SHALL 在用户保存记录后自动进行 AI 处理，用户无需任何操作。

#### Scenario: 后台自动处理
- **GIVEN** 用户提交了一条记录
- **WHEN** 记录保存成功后
- **THEN** AI 在后台异步处理（不阻塞用户操作）
- **AND** 自动提取关键信息
- **AND** 自动生成标签
- **AND** 生成一句话摘要

#### Scenario: 处理失败不影响记录
- **GIVEN** AI 服务暂时不可用
- **WHEN** 用户提交记录
- **THEN** 记录正常保存
- **AND** AI 处理标记为待处理
- **AND** 服务恢复后自动重试

### Requirement: AI Auto Tagging
系统 SHALL 自动为记录生成标签，用户无需手动分类。

#### Scenario: 自动生成项目标签
- **GIVEN** 用户输入"完成支付模块重构"
- **WHEN** AI 处理完成
- **THEN** 自动生成"支付模块"标签
- **AND** 标签标记为 AI 生成

#### Scenario: 自动生成类型标签
- **GIVEN** 用户输入不同类型的工作内容
- **WHEN** AI 处理完成
- **THEN** 自动识别工作类型（如"开发"、"会议"、"文档"、"上线"）
- **AND** 生成对应的类型标签

#### Scenario: 智能合并相似标签
- **GIVEN** 已存在"支付"标签
- **WHEN** AI 识别到"支付模块"、"支付系统"等相似内容
- **THEN** 智能关联到已有的"支付"标签
- **AND** 避免生成大量相似标签

### Requirement: AI Content Extraction
系统 SHALL 自动从记录中提取关键信息，便于汇报时使用。

#### Scenario: 提取关键数据指标
- **GIVEN** 用户输入包含数字的记录（如"DAU提升20%"、"响应时间从800ms降到200ms"）
- **WHEN** AI 处理完成
- **THEN** 自动提取指标数据（指标名、数值、趋势）
- **AND** 存储为结构化格式

#### Scenario: 提取时间节点
- **GIVEN** 用户输入包含时间的记录（如"3月15日完成上线"）
- **WHEN** AI 处理完成
- **THEN** 自动标记关键时间节点
- **AND** 存储日期和对应事件描述

#### Scenario: 生成一句话摘要
- **GIVEN** 用户输入较长的记录
- **WHEN** AI 处理完成
- **THEN** 生成简洁的一句话摘要
- **AND** 便于汇报时快速浏览

### Requirement: AI Report Generation
系统 SHALL 支持一键生成结构化工作汇报。

#### Scenario: 生成时间段汇报
- **GIVEN** 用户选择了时间范围（如本周、本月、本季度）
- **WHEN** 用户点击"生成汇报"按钮
- **THEN** AI 分析该时间段内的所有记录
- **AND** 按项目/类型自动分组
- **AND** 汇总关键指标和里程碑
- **AND** 生成结构化的工作汇报

#### Scenario: 按项目生成汇报
- **GIVEN** 用户选择了特定项目标签
- **WHEN** 用户点击"生成汇报"按钮
- **THEN** AI 仅分析该项目的记录
- **AND** 生成项目维度的汇报（时间线、成果、数据）

#### Scenario: 多种汇报模板
- **GIVEN** 用户生成汇报
- **WHEN** 汇报生成完成
- **THEN** 用户可以选择不同模板（周报、月报、项目总结、答辩材料）
- **AND** 支持复制到剪贴板
- **AND** 支持导出为 Markdown 文件

### Requirement: AI Backend Configuration
系统 SHALL 支持多种 AI 后端配置。

#### Scenario: 配置 OpenAI API
- **GIVEN** 用户选择使用 OpenAI
- **WHEN** 在设置中输入 API Key
- **THEN** 系统验证 Key 有效性
- **AND** 使用 OpenAI 作为 AI 后端

#### Scenario: 配置本地 Ollama
- **GIVEN** 用户本地运行了 Ollama
- **WHEN** 用户在设置中选择本地模式
- **THEN** 系统连接本地 Ollama 服务
- **AND** 使用本地模型处理 AI 请求

#### Scenario: AI 服务不可用时的处理
- **GIVEN** AI 服务未配置或不可用
- **WHEN** 用户尝试使用 AI 功能
- **THEN** 显示友好提示引导用户配置
- **AND** 核心记录功能不受影响（记录可保存，AI 处理延后）

