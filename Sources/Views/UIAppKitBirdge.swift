//
//  TypeAlias.swift
//  Firefly
//
//  Created by Zachary lineman on 6/15/21.
//

import SwiftUI

/*
 This entire file's job is to make converting between AppKit and UIKit way easier.
 It makes common typaliases for classes & types in either framework
 It also includes a few of extensions that make using AppKit easier when coming from UIKit
 */
#if canImport(AppKit)
import AppKit

public typealias FireflyView = NSView
public typealias FireflyColor = NSColor
public typealias FireflyFont = NSFont
public typealias FireflyImage = NSImage
public typealias TextView = NSTextView
public typealias BezierPath = NSBezierPath
public typealias FireflyScrollView = NSScrollView
public typealias Screen = NSScreen
public typealias Window = NSWindow
public typealias EdgeInsets = NSEdgeInsets
public typealias TextViewDelegate = NSTextViewDelegate

public typealias ViewRepresentable = NSViewRepresentable
public typealias KeyCommand = NSLimitedKeyCommand

#elseif canImport(UIKit)
import UIKit

public typealias FireflyView = UIView
public typealias FireflyColor = UIColor
public typealias FireflyFont = UIFont
public typealias FireflyImage = UIImage
public typealias TextView = UITextView
public typealias BezierPath = UIBezierPath
public typealias FireflyScrollView = UIScrollView
public typealias Screen = UIScreen
public typealias Window = UIWindow
public typealias EdgeInsets = UIEdgeInsets
public typealias TextViewDelegate = UITextViewDelegate

public typealias ViewRepresentable = UIViewRepresentable
public typealias KeyCommand = UIKeyCommand
#endif

#if canImport(AppKit)
extension NSColor {
    static var label: NSColor {
        return NSColor.labelColor
    }
    
    static var systemBackground: NSColor {
        return NSColor.textBackgroundColor
    }
}

extension NSTextView {
    var text: String {
        get {
            return self.string
        }
        set {
            self.string = newValue
        }
    }
}

extension NSFont {
    //TODO: Implement This
    static func italicSystemFont(ofSize fontSize: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: fontSize)
    }
}

extension NSView {
    func isDarkMode() -> Bool {
        return self.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
#endif
