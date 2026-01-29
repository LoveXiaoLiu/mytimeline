## ADDED Requirements

### Requirement: Quick Entry Input
用户 SHALL 能够通过极简界面快速记录工作事项，只需输入内容，无需任何分类操作。

#### Scenario: 通过快捷键快速记录
- **GIVEN** 用户在任意应用中工作
- **WHEN** 用户按下全局快捷键（默认 ⌘+Shift+N）
- **THEN** 系统显示极简悬浮输入窗口（仅一个输入框）
- **AND** 输入框自动获得焦点

#### Scenario: 提交记录
- **GIVEN** 用户在输入框中输入内容
- **WHEN** 用户按下 ⌘+Enter 或点击提交按钮
- **THEN** 记录立即保存到本地数据库
- **AND** 输入窗口关闭
- **AND** AI 在后台异步处理（提取信息、生成标签）

#### Scenario: Markdown 格式输入
- **GIVEN** 用户在输入框中输入内容
- **WHEN** 用户使用 Markdown 语法（如 **粗体**、`代码`、- 列表）
- **THEN** 系统保存原始 Markdown 文本
- **AND** 在时间轴视图中渲染为格式化内容

#### Scenario: 可选的手动标签（#语法）
- **GIVEN** 用户在输入框中输入内容
- **WHEN** 用户输入 #标签名（可选，非必须）
- **THEN** 系统识别并关联对应标签
- **AND** 该标签优先级高于 AI 自动生成的标签

### Requirement: Menu Bar Access
应用 SHALL 作为菜单栏应用运行，提供快速访问入口。

#### Scenario: 菜单栏图标显示
- **GIVEN** 应用已启动
- **WHEN** 应用运行时
- **THEN** 菜单栏显示应用图标

#### Scenario: 点击菜单栏打开主面板
- **GIVEN** 应用图标显示在菜单栏
- **WHEN** 用户点击菜单栏图标
- **THEN** 显示应用主面板（包含时间轴视图）

#### Scenario: 菜单栏快捷操作
- **GIVEN** 用户右键点击菜单栏图标
- **WHEN** 显示上下文菜单
- **THEN** 提供"新建记录"、"设置"、"退出"等选项

### Requirement: Global Hotkey
应用 SHALL 支持全局快捷键，用户可在任意应用中唤起输入窗口。

#### Scenario: 注册全局快捷键
- **GIVEN** 应用首次启动
- **WHEN** 应用请求 Accessibility 权限
- **THEN** 用户授权后注册全局快捷键

#### Scenario: 快捷键冲突处理
- **GIVEN** 默认快捷键与其他应用冲突
- **WHEN** 用户在设置中修改快捷键
- **THEN** 系统使用新的快捷键组合

#### Scenario: 无权限时的降级处理
- **GIVEN** 用户未授予 Accessibility 权限
- **WHEN** 用户尝试使用全局快捷键
- **THEN** 系统提示用户授权
- **AND** 用户仍可通过菜单栏访问功能
