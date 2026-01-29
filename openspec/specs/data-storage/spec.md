# data-storage Specification

## Purpose
TBD - created by archiving change add-macos-timeline-app. Update Purpose after archive.
## Requirements
### Requirement: Local Data Persistence
系统 SHALL 使用 SwiftData 在本地持久化存储所有数据。

#### Scenario: 保存记录
- **GIVEN** 用户创建新记录
- **WHEN** 记录提交
- **THEN** 数据立即持久化到本地数据库
- **AND** 应用重启后数据仍然存在

#### Scenario: 数据完整性
- **GIVEN** 应用正在写入数据
- **WHEN** 应用意外崩溃
- **THEN** 已保存的数据不受影响
- **AND** 未完成的写入操作不会损坏数据库

### Requirement: Tag System
系统 SHALL 支持标签系统，标签主要由 AI 自动生成。

#### Scenario: AI 自动创建标签
- **GIVEN** AI 处理记录时识别到新的项目/类型
- **WHEN** 不存在对应标签
- **THEN** 自动创建新标签并分配颜色
- **AND** 标签标记为"AI 生成"

#### Scenario: 查看标签列表
- **GIVEN** 用户打开时间轴或筛选面板
- **WHEN** 显示标签列表
- **THEN** 展示所有标签（包含 AI 生成和手动创建的）
- **AND** 显示每个标签关联的记录数

#### Scenario: 删除无用标签
- **GIVEN** 某标签不再需要
- **WHEN** 用户删除该标签
- **THEN** 标签被删除，关联的记录保留
- **AND** 记录中移除该标签的关联

### Requirement: Search and Filter
系统 SHALL 支持全文搜索和多维度筛选。

#### Scenario: 全文搜索
- **GIVEN** 用户在搜索框输入关键词
- **WHEN** 输入完成（防抖处理）
- **THEN** 实时显示匹配的记录列表

#### Scenario: 标签筛选
- **GIVEN** 用户点击某个标签
- **WHEN** 筛选生效
- **THEN** 时间轴仅显示包含该标签的记录

#### Scenario: 时间范围筛选
- **GIVEN** 用户选择时间范围（今天/本周/本月/自定义）
- **WHEN** 筛选生效
- **THEN** 时间轴仅显示该时间范围内的记录

#### Scenario: 组合筛选
- **GIVEN** 用户同时设置了标签和时间范围
- **WHEN** 筛选生效
- **THEN** 显示同时满足两个条件的记录

### Requirement: Data Export
系统 SHALL 支持数据导出和备份。

#### Scenario: 导出为 JSON
- **GIVEN** 用户想要备份数据
- **WHEN** 用户选择导出功能
- **THEN** 生成包含所有记录和标签的 JSON 文件

#### Scenario: 导出筛选结果
- **GIVEN** 用户已筛选特定时间段/标签的记录
- **WHEN** 用户选择导出当前视图
- **THEN** 仅导出筛选后的记录

#### Scenario: 导出为 Markdown
- **GIVEN** 用户想要可读的导出格式
- **WHEN** 用户选择导出为 Markdown
- **THEN** 生成格式化的 Markdown 文件，按日期分组

