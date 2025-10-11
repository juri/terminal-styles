//
//  TerminalStyles.swift
//
//  Created by Juri Pakaste on 9.10.2025.
//

import TerminalANSI

/// `Style` defines a background and a foreground for text output to terminal.
///
/// Both background and foreground are optional. You can stack multiple foreground styles.
public struct Style: Equatable, Sendable {
    /// Background style.
    public var background: Background?
    /// Foreground styles.
    public var foreground: [Foreground]

    public init(
        background: Background? = nil,
        foreground: [Foreground] = [],
    ) {
        self.background = background
        self.foreground = foreground
    }

    /// Add the contents of `style` to this style, overriding the current values where they conflict
    /// with the new ones.
    public mutating func add(contentsOf style: Style) {
        self.add(foregrounds: style.foreground)
        self.background = style.background ?? self.background
    }

    /// Combine this style with another one to create a new `Style`, overriding the values of this style with
    /// those of the other one where they conflict.
    public func adding(contentsOf style: Style) -> Style {
        var value = self
        value.add(contentsOf: style)
        return value
    }

    /// Add foregrounds to this style, overriding the current values where they conflict with the new ones.
    public mutating func add(foregrounds: [Foreground]) {
        Foreground.add(foregrounds, to: &self.foreground)
    }

    /// Combine this style with the foregrounds passed in as a parameter and return a new `Style`. The parameter
    /// foregrounds override the foregrounds of this style where they conflict.
    public func adding(foregrounds: [Foreground]) -> Style {
        var value = self
        value.add(foregrounds: foregrounds)
        return value
    }

    /// Add the background to this style.
    ///
    /// Adding a nil background has no effect. If you want to use this method to unset the background, use
    /// ``Background/noBackground``.
    public mutating func add(background: Background?) {
        if let background {
            self.background = background
        }
    }

    /// Combine this style with the passed-in background to create a new `Style`. The parameter background
    /// overrides the background in this style.
    public func adding(background: Background?) -> Style {
        var value = self
        value.add(background: background)
        return value
    }

    /// Add the foregrounds to this style, overriding the current ones where they conflict.
    public mutating func add(foreground: Foreground) {
        self.add(foregrounds: [foreground])
    }

    /// Combine this style with the passed-in foregrounds to create a new style, overriding the current foregrounds
    /// where they conflict.
    public func adding(foreground: Foreground) -> Style {
        var value = self
        value.add(foreground: foreground)
        return value
    }

    /// Create an `ANSIControlCode` for this style.
    public var ansiControlCode: ANSIControlCode {
        var codes = self.foreground.map(\.setGraphicsRendition)
        if let bgSGR = self.background?.setGraphicsRendition {
            codes.append(bgSGR)
        }

        return ANSIControlCode.setGraphicsRendition(codes)
    }

    /// Create an `ANSICommand` for this style.
    public var ansiCommand: ANSICommand {
        self.ansiControlCode.ansiCommand
    }

    /// Apply this style to `text` to create a styled `String`.
    public func apply(to text: String) -> String {
        "\(self.ansiCommand.message)\(text)\(ANSIControlCode.setGraphicsRendition([.reset]).ansiCommand.message)"
    }
}

/// Foreground styles you can apply to text.
public enum Foreground: Equatable, Sendable {
    case bold
    case color256(Int)
    case colorBasic(BasicPalette)
    case colorBasicBright(BasicPalette)
    case colorRGB(RGBColor8)
    case italic
    case underline

    public var setGraphicsRendition: SetGraphicsRendition {
        switch self {
        case .bold: .bold
        case let .color256(c): .text256(c)
        case let .colorBasic(c): .textBasic(c)
        case let .colorBasicBright(c): .textBasicBright(c)
        case let .colorRGB(c): .textRGB(c)
        case .italic: .italic
        case .underline: .underline
        }
    }

    var isAnyColor: Bool {
        switch self {
        case .bold: false
        case .color256: true
        case .colorBasic: true
        case .colorBasicBright: true
        case .colorRGB: true
        case .italic: false
        case .underline: false
        }
    }

    var isBold: Bool {
        guard case .bold = self else { return false }
        return true
    }

    var isItalic: Bool {
        guard case .italic = self else { return false }
        return true
    }

    var isUnderline: Bool {
        guard case .underline = self else { return false }
        return true
    }

    /// Add `foregrounds` to a list of `Foreground` values.
    ///
    /// This method removes any existing `Foreground` values from `list` where they
    /// conflict with the values in `foregrounds`.
    static func add(_ foregrounds: [Foreground], to list: inout [Foreground]) {
        var bold: Foreground?
        var color: Foreground?
        var italic: Foreground?
        var underline: Foreground?

        for f in foregrounds {
            switch f {
            case .bold: bold = f
            case .color256, .colorRGB, .colorBasic, .colorBasicBright: color = f
            case .italic: italic = f
            case .underline: underline = f
            }
        }

        var filtered = list.filter {
            switch $0 {
            case .bold: bold == nil
            case .color256, .colorRGB, .colorBasic, .colorBasicBright: color == nil
            case .italic: italic == nil
            case .underline: underline == nil
            }
        }

        if let bold { filtered.append(bold) }
        if let color { filtered.append(color) }
        if let italic { filtered.append(italic) }
        if let underline { filtered.append(underline) }

        list = filtered
    }
}

/// Background styles you can apply to text.
///
/// There's an explicit `noBackground` case you can use to specify that the background has been set to no value.
/// This can be used to to override a color where an nil background would not do so.
public enum Background: Equatable, Sendable {
    case color256(Int)
    case colorBasic(BasicPalette)
    case colorBasicBright(BasicPalette)
    case colorRGB(RGBColor8)
    case noBackground

    public var setGraphicsRendition: SetGraphicsRendition? {
        switch self {
        case let .color256(c): .background256(c)
        case let .colorBasic(c): .backgroundBasic(c)
        case let .colorBasicBright(c): .backgroundBasicBright(c)
        case let .colorRGB(c): .backgroundRGB(c)
        case .noBackground: nil
        }
    }
}
