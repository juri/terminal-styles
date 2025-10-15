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
    public func apply(
        lines: some Sequence<some StringProtocol>,
        addNewLines: Bool = true,
        reset: Bool = true,
    ) -> String {
        return zip(0..., lines).map { index, line in
            self.apply(line: line, lineIndex: index, reset: reset)
        }.joined()
    }

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
