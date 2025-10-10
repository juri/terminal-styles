//
//  TerminalStyles.swift
//
//  Created by Juri Pakaste on 9.10.2025.
//

import TerminalANSI

public struct Style {
    var background: Background?
    public var foreground: [Foreground]

    public init(
        background: Background? = nil,
        foreground: [Foreground] = [],
    ) {
        self.background = background
        self.foreground = foreground
    }

    public mutating func add(contentsOf style: Style) {
        self.add(foregrounds: style.foreground)
        self.background = style.background
    }

    public func adding(contentsOf style: Style) -> Style {
        var value = self
        value.add(contentsOf: style)
        return value
    }

    public mutating func add(foregrounds: [Foreground]) {
        Foreground.add(foregrounds, to: &self.foreground)
    }

    public func adding(foregrounds: [Foreground]) -> Style {
        var value = self
        value.add(foregrounds: foregrounds)
        return value
    }

    public mutating func add(background: Background?) {
        self.background = background
    }

    public func adding(background: Background?) -> Style {
        var value = self
        value.add(background: background)
        return value
    }

    public mutating func add(foreground: Foreground) {
        self.add(foregrounds: [foreground])
    }

    public func adding(foreground: Foreground) -> Style {
        var value = self
        value.add(foreground: foreground)
        return value
    }

    public var ansiCommand: ANSICommand {
        var codes = self.foreground.map(\.setGraphicsRendition)
        if let background = self.background {
            codes.append(background.setGraphicsRendition)
        }

        return ANSIControlCode.setGraphicsRendition(codes).ansiCommand
    }

    public func apply(to text: String) -> String {
        "\(self.ansiCommand.message)\(text)\(ANSIControlCode.setGraphicsRendition([.reset]).ansiCommand.message)"
    }
}

public enum Foreground {
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

public enum Background {
    case color256(Int)
    case colorBasic(BasicPalette)
    case colorBasicBright(BasicPalette)
    case colorRGB(RGBColor8)

    public var setGraphicsRendition: SetGraphicsRendition {
        switch self {
        case let .color256(c): .background256(c)
        case let .colorBasic(c): .backgroundBasic(c)
        case let .colorBasicBright(c): .backgroundBasicBright(c)
        case let .colorRGB(c): .backgroundRGB(c)
        }
    }
}
