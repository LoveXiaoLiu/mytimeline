#!/usr/bin/env swift
// 清爽明亮风格图标 - 浅色背景 + 流动渐变线条

import Cocoa
import Foundation

func createIcon(size: Int) -> NSImage {
    let cgSize = CGSize(width: size, height: size)
    let image = NSImage(size: cgSize)
    
    image.lockFocus()
    
    let s = CGFloat(size)
    let padding = s * 0.08
    let cornerRadius = s * 0.22
    
    // 浅色渐变背景 - 白到淡蓝
    let bgRect = CGRect(x: padding, y: padding, width: s - padding * 2, height: s - padding * 2)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    let bgGradient = NSGradient(colors: [
        NSColor(red: 240/255, green: 249/255, blue: 255/255, alpha: 1.0),  // 淡蓝白
        NSColor(red: 224/255, green: 242/255, blue: 254/255, alpha: 1.0),  // 浅天蓝
    ])
    bgGradient?.draw(in: bgPath, angle: -45)
    
    // 边框
    NSColor(red: 186/255, green: 230/255, blue: 253/255, alpha: 0.8).setStroke()
    bgPath.lineWidth = s * 0.01
    bgPath.stroke()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // 三条彩色流动曲线
    let curves: [(colors: [NSColor], yOffset: CGFloat, amplitude: CGFloat)] = [
        // 底层 - 青绿渐变
        ([NSColor(red: 45/255, green: 212/255, blue: 191/255, alpha: 1.0),
          NSColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)],
         s * 0.38, s * 0.12),
        // 中层 - 蓝紫渐变
        ([NSColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0),
          NSColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0)],
         s * 0.52, s * 0.15),
        // 顶层 - 橙粉渐变
        ([NSColor(red: 251/255, green: 146/255, blue: 60/255, alpha: 1.0),
          NSColor(red: 244/255, green: 114/255, blue: 182/255, alpha: 1.0)],
         s * 0.66, s * 0.10),
    ]
    
    for curve in curves {
        let path = CGMutablePath()
        let startX = padding + s * 0.05
        let endX = s - padding - s * 0.05
        let baseY = curve.yOffset
        let amp = curve.amplitude
        
        path.move(to: CGPoint(x: startX, y: baseY))
        
        // 平滑 S 曲线
        path.addCurve(
            to: CGPoint(x: endX, y: baseY),
            control1: CGPoint(x: s * 0.38, y: baseY + amp),
            control2: CGPoint(x: s * 0.62, y: baseY - amp)
        )
        
        // 渐变描边
        context.saveGState()
        context.addPath(path)
        context.setLineWidth(s * 0.04)
        context.setLineCap(.round)
        context.replacePathWithStrokedPath()
        context.clip()
        
        let gradientColors = curve.colors.map { $0.cgColor } as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                   colors: gradientColors,
                                   locations: [0, 1])!
        context.drawLinearGradient(gradient,
                                    start: CGPoint(x: startX, y: baseY),
                                    end: CGPoint(x: endX, y: baseY),
                                    options: [])
        context.restoreGState()
    }
    
    // 三个圆点节点 - 带阴影效果
    let dotPositions: [(x: CGFloat, y: CGFloat, color: NSColor)] = [
        (0.22, 0.38, NSColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)),
        (0.50, 0.52, NSColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0)),
        (0.78, 0.66, NSColor(red: 251/255, green: 146/255, blue: 60/255, alpha: 1.0)),
    ]
    
    for dot in dotPositions {
        let x = s * dot.x
        let y = s * dot.y
        let r = s * 0.055
        
        // 白色外圈（阴影效果）
        context.setShadow(offset: CGSize(width: 0, height: -s * 0.01), blur: s * 0.02,
                          color: NSColor(white: 0, alpha: 0.15).cgColor)
        context.setFillColor(NSColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        
        // 彩色内圈
        context.setShadow(offset: .zero, blur: 0, color: nil)
        context.setFillColor(dot.color.cgColor)
        context.fillEllipse(in: CGRect(x: x - r * 0.7, y: y - r * 0.7, width: r * 1.4, height: r * 1.4))
    }
    
    image.unlockFocus()
    return image
}

func saveAsPNG(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }
    try? pngData.write(to: URL(fileURLWithPath: path))
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.icns"
let iconsetDir = "/tmp/AppIcon.iconset"

try? FileManager.default.removeItem(atPath: iconsetDir)
try? FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

for size in [16, 32, 64, 128, 256, 512, 1024] {
    saveAsPNG(createIcon(size: size), to: "\(iconsetDir)/icon_\(size)x\(size).png")
    if size <= 512 { saveAsPNG(createIcon(size: size * 2), to: "\(iconsetDir)/icon_\(size)x\(size)@2x.png") }
}

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconsetDir, "-o", outputPath]
try? task.run()
task.waitUntilExit()

try? FileManager.default.removeItem(atPath: iconsetDir)
if task.terminationStatus == 0 { print("✅ 图标已生成: \(outputPath)") }
