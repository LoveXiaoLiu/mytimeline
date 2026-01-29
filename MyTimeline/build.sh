#!/bin/bash

# MyTimeline 编译脚本
# 用法: ./build.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="MyTimeline"
BUNDLE_ID="com.mytimeline.app"

echo "🔨 开始编译 $APP_NAME..."

# 检查 Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "❌ 未安装 Xcode Command Line Tools"
    echo "请运行: xcode-select --install"
    exit 1
fi

# 清理旧的构建目录
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/$APP_NAME.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/$APP_NAME.app/Contents/Resources"

# 创建 Info.plist
cat > "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>MyTimeline</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.mytimeline.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>MyTimeline</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMainStoryboardFile</key>
    <string></string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# 创建 PkgInfo
echo -n "APPL????" > "$BUILD_DIR/$APP_NAME.app/Contents/PkgInfo"

# 生成应用图标
echo "🎨 生成应用图标..."
swift "$PROJECT_DIR/GenerateIcon.swift" "$BUILD_DIR/$APP_NAME.app/Contents/Resources/AppIcon.icns"

# 收集所有 Swift 源文件
SWIFT_FILES=$(find "$PROJECT_DIR/MyTimeline" -name "*.swift" -type f)

echo "📦 编译 Swift 文件..."

# 检查是否需要构建 Universal Binary
UNIVERSAL=${UNIVERSAL:-false}

if [ "$UNIVERSAL" = "true" ]; then
    echo "🌐 构建 Universal Binary (arm64 + x86_64)..."
    
    # 编译 arm64 版本
    echo "  → 编译 arm64..."
    swiftc \
        -o "$BUILD_DIR/$APP_NAME-arm64" \
        -target arm64-apple-macosx14.0 \
        -sdk $(xcrun --show-sdk-path) \
        -framework SwiftUI \
        -framework SwiftData \
        -framework AppKit \
        -framework Foundation \
        -framework Carbon \
        -parse-as-library \
        -Onone \
        $SWIFT_FILES
    
    # 编译 x86_64 版本
    echo "  → 编译 x86_64..."
    swiftc \
        -o "$BUILD_DIR/$APP_NAME-x86_64" \
        -target x86_64-apple-macosx14.0 \
        -sdk $(xcrun --show-sdk-path) \
        -framework SwiftUI \
        -framework SwiftData \
        -framework AppKit \
        -framework Foundation \
        -framework Carbon \
        -parse-as-library \
        -Onone \
        $SWIFT_FILES
    
    # 合并为 Universal Binary
    echo "  → 合并 Universal Binary..."
    lipo -create \
        "$BUILD_DIR/$APP_NAME-arm64" \
        "$BUILD_DIR/$APP_NAME-x86_64" \
        -output "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"
    
    # 清理临时文件
    rm "$BUILD_DIR/$APP_NAME-arm64" "$BUILD_DIR/$APP_NAME-x86_64"
else
    # 检测当前架构并编译
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        TARGET="x86_64-apple-macosx14.0"
        echo "🖥️ 检测到 Intel Mac，使用 x86_64 架构..."
    else
        TARGET="arm64-apple-macosx14.0"
        echo "🍎 检测到 Apple Silicon，使用 arm64 架构..."
    fi
    
    swiftc \
        -o "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME" \
        -target $TARGET \
        -sdk $(xcrun --show-sdk-path) \
        -framework SwiftUI \
        -framework SwiftData \
        -framework AppKit \
        -framework Foundation \
        -framework Carbon \
        -parse-as-library \
        -Onone \
        $SWIFT_FILES
fi

echo "✅ 编译完成!"
echo ""
echo "📍 应用位置: $BUILD_DIR/$APP_NAME.app"
echo ""
echo "运行方式:"
echo "  1. 双击打开: open \"$BUILD_DIR/$APP_NAME.app\""
echo "  2. 或拖拽到 Applications 文件夹"
echo ""

# 询问是否立即运行
read -p "是否立即运行应用? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$BUILD_DIR/$APP_NAME.app"
fi
