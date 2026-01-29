# MyTimeline

[![Build](https://github.com/LoveXiaoLiu/mytimeline/actions/workflows/build.yml/badge.svg)](https://github.com/LoveXiaoLiu/mytimeline/actions/workflows/build.yml)

一款现代简约的 macOS 桌面时间轴记录应用，帮助你快速记录和回顾工作事项。

## 功能特性

- **快速记录**：全局快捷键 `⌘+Shift+N` 随时呼出 Spotlight 风格输入框，回车即保存
- **AI 智能标签**：自动识别内容中的项目/需求名称，生成精准标签
- **时间轴视图**：从上到下渐变显示，最新记录最醒目
- **智能时间显示**：今天、昨天、具体日期自动切换
- **标签管理**：支持 `#标签` 语法，可手动选择或 AI 自动生成
- **数据导出**：支持 JSON 格式导出，方便备份和迁移
- **菜单栏图标**：常驻菜单栏，快速访问

## 截图

<!-- 可添加应用截图 -->

## 安装

### 下载安装

从 [Releases](https://github.com/LoveXiaoLiu/mytimeline/releases) 下载最新的 DMG 文件，打开后将应用拖到 Applications 文件夹。

### 从源码编译

```bash
git clone https://github.com/LoveXiaoLiu/mytimeline.git
cd mytimeline/MyTimeline
./build.sh
```

编译完成后，应用位于 `build/MyTimeline.app`。

## 系统要求

- macOS 13.0+
- 支持 Apple Silicon 和 Intel 芯片

## AI 配置

支持 OpenAI 兼容接口，在设置中配置：

- **API 地址**：如 `https://api.openai.com` 或其他兼容服务
- **API Key**：可选
- **模型名称**：如 `gpt-4o-mini`

## 快捷键

| 快捷键 | 功能 |
|--------|------|
| `⌘+Shift+N` | 全局快速记录（支持后台唤起） |
| `⌘+N` | 新建记录 |
| `Enter` | 保存记录（输入框中） |
| `Esc` | 取消/关闭 |

## 项目结构

```
MyTimeline/
├── Models/          # 数据模型
├── Views/           # 视图组件
│   ├── Main/        # 主界面
│   ├── QuickEntry/  # 快速输入
│   └── Settings/    # 设置界面
├── Services/        # 服务层（AI、数据存储）
└── build.sh         # 编译脚本
```

## License

MIT
