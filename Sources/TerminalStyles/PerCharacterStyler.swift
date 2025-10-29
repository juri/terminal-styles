//
//  PerCharacterStyler.swift
//  terminal-styles
//
//  Created by Juri Pakaste on 15.10.2025.
//

import TerminalANSI

/// `PerCharacterStyler` can produce a ``Style`` for a x/y position.
public protocol PerCharacterStyler {
    func styleForPosition(x: Int, y: Int) -> Style
}

extension PerCharacterStyler {
    /// Apply the `PerCharacterStyles` to a sequence of lines.
    /// - Parameters:
    ///     - lines: The lines to style.
    ///     - addNewLines: If true, newlines will be added to the ends of the lines.
    ///     - reset: If true, style resets will be added to the ends of the lines, before the added newline.
    public func apply(
        lines: some Sequence<some StringProtocol>,
        addNewLines: Bool = true,
        reset: Bool = true,
    ) -> String {
        return zip(0..., lines).map { index, line in
            self.apply(line: line, lineIndex: index, reset: reset)
        }.joined()
    }

    /// Apply the `PerCharacterStyles` to a line of text.
    /// - Parameters:
    ///     - line: The line to style.
    ///     - lineIndex: The index of this line in a larger block of text.
    ///     - addNewLine: If true, a newline will be added to the end of the line.
    ///     - reset: If true, a style reset will be added to the end of the line, before the added newline.
    public func apply(
        line: some StringProtocol,
        lineIndex: Int,
        addNewline: Bool = true,
        reset: Bool = true,
    ) -> String {
        var output = zip(0..., line).map { index, char in
            let style = self.styleForPosition(x: index, y: lineIndex).ansiCommand.message
            return "\(style)\(char)"
        }.joined()
        if reset {
            output.append(ANSIControlCode.setGraphicsRendition([.reset]).ansiCommand.message)
        }
        if addNewline {
            output.append("\n")
        }
        return output
    }
}

/// Join two stylers.
///
/// The values from `styler2` will override those from `styler1` in case of conflict.
public struct JoinedPerCharacterStyler<S1: PerCharacterStyler, S2: PerCharacterStyler>: PerCharacterStyler {
    public let styler1: S1
    public let styler2: S2

    public init(styler1: S1, styler2: S2) {
        self.styler1 = styler1
        self.styler2 = styler2
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let style1 = self.styler1.styleForPosition(x: x, y: y)
        let style2 = self.styler2.styleForPosition(x: x, y: y)
        return style1.adding(contentsOf: style2)
    }
}

/// A styler that returns the colors from `points` as ``Foreground/colorRGB(_:)`` based on the
/// `x` parameter of ``styleForPosition(x:y:)``.
public struct HorizontalForegroundPerCharacterStyler: PerCharacterStyler {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(x, points.count - 1))
        return Style(foreground: [.colorRGB(self.points[index])])
    }
}

/// A styler that returns the colors from `points` as ``Foreground/colorRGB(_:)`` based on the
/// `y` parameter of ``styleForPosition(x:y:)``.
public struct VerticalForegroundPerCharacterStyler: PerCharacterStyler {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(y, points.count - 1))
        return Style(foreground: [.colorRGB(self.points[index])])
    }
}

/// A styler that returns the colors from `points` as ``Background/color256(_:)`` based on the
/// `x` parameter of ``styleForPosition(x:y:)``.
public struct HorizontalBackgroundPerCharacterStyler: PerCharacterStyler {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(x, points.count - 1))
        return Style(background: .colorRGB(self.points[index]))
    }
}

/// A styler that returns the colors from `points` as ``Background/color256(_:)`` based on the
/// `y` parameter of ``styleForPosition(x:y:)``.
public struct VerticalBackgroundPerCharacterStyler: PerCharacterStyler {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(y, points.count - 1))
        return Style(background: .colorRGB(self.points[index]))
    }
}

/// A styler that always returns the static `style` value, regardless of the parameters passed to
/// ``styleForPosition(x:y:)``.
public struct ConstantPerCharacterStyler: PerCharacterStyler {
    public let style: Style

    /// Initialize with the given ``Style``.
    public init(style: Style) {
        self.style = style
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        self.style
    }
}
