//
//  MyTimelineApp.swift
//  MyTimeline
//
//  macOS 桌面时间轴记录应用
//

import SwiftUI
import Carbon.HIToolbox

@main
struct MyTimelineApp: App {
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // 注册默认值
        UserDefaults.standard.register(defaults: [
            "aiAutoClassify": true,
            "showMenuBarIcon": true
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(dataStore)
                .environmentObject(appState)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(after: .newItem) {
                Button("快速记录") {
                    appState.showQuickEntry = true
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(dataStore)
                .environmentObject(appState)
        }
    }
}

// MARK: - App Delegate for Global Hotkey & Menu Bar

class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var statusItem: NSStatusItem?
    private var settingsObserver: NSObjectProtocol?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerGlobalHotkey()
        setupMenuBarIcon()
        
        // 监听设置变化
        settingsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateMenuBarVisibility()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        unregisterGlobalHotkey()
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Menu Bar Icon
    
    private func setupMenuBarIcon() {
        updateMenuBarVisibility()
    }
    
    private func updateMenuBarVisibility() {
        let showIcon = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
        
        if showIcon {
            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
                
                if let button = statusItem?.button {
                    button.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "MyTimeline")
                    button.image?.size = NSSize(width: 18, height: 18)
                }
                
                setupMenu()
            }
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "快速记录", action: #selector(showQuickEntry), keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "打开 MyTimeline", action: #selector(openMainWindow), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc private func showQuickEntry() {
        SpotlightWindowController.shared.show()
    }
    
    @objc private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title.contains("Timeline") || $0.contentView != nil }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Global Hotkey
    
    private func registerGlobalHotkey() {
        // 注册全局快捷键: Cmd+Shift+N
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4D544C4E) // "MTLN"
        hotKeyID.id = 1
        
        // Cmd+Shift+N
        let keyCode: UInt32 = UInt32(kVK_ANSI_N)
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        // 安装事件处理器
        let handler: EventHandlerUPP = { (_, event, _) -> OSStatus in
            DispatchQueue.main.async {
                // 显示 Spotlight 样式输入框
                SpotlightWindowController.shared.show()
            }
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, &eventHandler)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        print("[HotKey] 全局快捷键已注册: Cmd+Shift+N")
    }
    
    private func unregisterGlobalHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            print("[HotKey] 全局快捷键已注销")
        }
    }
}
