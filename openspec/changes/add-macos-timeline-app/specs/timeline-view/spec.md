## ADDED Requirements

### Requirement: Main Window Layout
应用 SHALL 提供完整的桌面窗口界面，包含侧边栏、主视图和快速输入区域。

#### Scenario: 打开应用
- **GIVEN** 用户启动应用
- **WHEN** 主窗口加载完成
- **THEN** 显示标准 macOS 桌面窗口
- **AND** 应用图标显示在 Dock 中
- **AND** 主窗口包含侧边栏和时间轴主视图

#### Scenario: 窗口布局
- **GIVEN** 用户查看主窗口
- **WHEN** 窗口显示
- **THEN** 左侧显示侧边栏（时间筛选、标签列表、AI 汇报入口）
- **AND** 右侧显示时间轴记录列表
- **AND** 顶部显示搜索栏和新建按钮
- **AND** 底部或顶部提供快速输入入口

#### Scenario: 窗口大小调整
- **GIVEN** 用户调整窗口大小
- **WHEN** 窗口尺寸变化
- **THEN** 界面自适应布局
- **AND** 侧边栏可折叠以获得更多空间

### Requirement: Sidebar Navigation
侧边栏 SHALL 提供时间筛选、标签筛选和功能入口。

#### Scenario: 时间范围筛选
- **GIVEN** 用户在侧边栏
- **WHEN** 用户选择时间范围（今天、本周、本月、自定义）
- **THEN** 时间轴只显示该范围内的记录

#### Scenario: 标签筛选
- **GIVEN** 侧边栏显示标签列表
- **WHEN** 用户点击某个标签
- **THEN** 时间轴只显示包含该标签的记录

#### Scenario: AI 汇报入口
- **GIVEN** 用户在侧边栏
- **WHEN** 用户点击"生成汇报"
- **THEN** 打开 AI 汇报生成面板

### Requirement: Timeline Display
系统 SHALL 以时间轴形式展示所有记录，按时间倒序排列。

#### Scenario: 查看时间轴
- **GIVEN** 用户打开主窗口
- **WHEN** 时间轴视图加载
- **THEN** 显示所有记录，最新的在最上方
- **AND** 记录按日期分组显示

#### Scenario: 空状态展示
- **GIVEN** 用户没有任何记录
- **WHEN** 打开时间轴视图
- **THEN** 显示引导提示，鼓励用户创建第一条记录

#### Scenario: 滚动加载
- **GIVEN** 用户有大量记录（>100条）
- **WHEN** 用户滚动到列表底部
- **THEN** 自动加载更多历史记录

### Requirement: Entry Card Display
每条记录 SHALL 以卡片形式展示，支持 Markdown 渲染，包含内容、标签、时间等信息。

#### Scenario: 记录卡片内容
- **GIVEN** 时间轴中有记录
- **WHEN** 显示记录卡片
- **THEN** 展示记录内容（Markdown 渲染）、关联标签、创建时间
- **AND** 长内容支持展开/收起

#### Scenario: Markdown 渲染
- **GIVEN** 记录内容包含 Markdown 格式
- **WHEN** 显示记录卡片
- **THEN** 渲染标题、列表、粗体、斜体、代码块等格式
- **AND** 保持良好的可读性

#### Scenario: 编辑记录
- **GIVEN** 用户查看某条记录
- **WHEN** 用户点击编辑按钮或双击卡片
- **THEN** 进入编辑模式，显示原始 Markdown 文本
- **AND** 可修改内容和标签

#### Scenario: 删除记录
- **GIVEN** 用户查看某条记录
- **WHEN** 用户点击删除按钮
- **THEN** 显示确认对话框
- **AND** 确认后删除记录

### Requirement: Date Group Navigation
系统 SHALL 支持按日期快速导航。

#### Scenario: 日期分组标题
- **GIVEN** 时间轴显示多天的记录
- **WHEN** 滚动浏览时
- **THEN** 显示日期分组标题（如"今天"、"昨天"、"2024年1月15日"）

#### Scenario: 跳转到指定日期
- **GIVEN** 用户想查看特定日期的记录
- **WHEN** 用户点击日期选择器并选择日期
- **THEN** 时间轴滚动到该日期的记录位置
