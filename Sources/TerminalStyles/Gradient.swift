//
//  Gradient.swift
//
//  Created by Juri Pakaste on 12.10.2025.
//

import TerminalANSI

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

public protocol LinearGradient {
    var points: [RGBColor8] { get }
    init(points: [RGBColor8])
}

extension LinearGradient {
    public init(hslPoints: [HSLColor]) {
        let rgbPoints = hslPoints.map(RGBColor8.init(hsl:))
        self.init(points: rgbPoints)
    }

    public init(hslGradient: LinearGradientHSL) {
        self.init(hslPoints: hslGradient.points)
    }

    public init?(length: Int, stops: [(Double, RGBColor8)]) {
        let hslPoints = stops.map { ($0, HSLColor(rgb: $1)) }
        guard let hslGradient = LinearGradientHSL(length: length, stops: hslPoints) else { return nil }
        self.init(hslGradient: hslGradient)
    }
}

public struct HorizontalForegroundPerCharacterStyler: PerCharacterStyler, LinearGradient {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(x, points.count - 1))
        return Style(foreground: [.colorRGB(self.points[index])])
    }
}

public struct VerticalForegroundPerCharacterStyler: PerCharacterStyler, LinearGradient {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(y, points.count - 1))
        return Style(foreground: [.colorRGB(self.points[index])])
    }
}

public struct HorizontalBackgroundPerCharacterStyler: PerCharacterStyler, LinearGradient {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(x, points.count - 1))
        return Style(background: .colorRGB(self.points[index]))
    }
}

public struct VerticalBackgroundPerCharacterStyler: PerCharacterStyler, LinearGradient {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public func styleForPosition(x: Int, y: Int) -> Style {
        let index = max(0, min(y, points.count - 1))
        return Style(background: .colorRGB(self.points[index]))
    }
}

/// `LinearGradientHSL` is a type that describes a linear gradient that progresses through distinct points.
public struct LinearGradientHSL {
    public let points: [HSLColor]

    public init(points: [HSLColor]) {
        self.points = points
    }

    /// Create a `LinearGradientHSL` of `length` points.
    /// - Parameters:
    ///     - stops: An array of tuples where the `Double` value is in the range 0...1 and represents
    ///              a fractional location in the gradient space, and the `HSLColor` is a color for that point.
    ///              If the Double value in the first `point` is larger than 0.0, the color from the
    ///              start of the space to that point is solid. If the Double value in the last `point`
    ///              is less than 1.0, the color from that point to the end of the space is solid.
    ///              If there's more than two values, the gradient progresses through those stops.
    /// - Returns: A ``LinearGradientHSL`` with `length` values in the ``LinearGradientHSL/points`` array.
    ///
    public init?(length: Int, stops: [(Double, HSLColor)]) {
        guard length > 0, !stops.isEmpty else { return nil }

        // Sort points by position to ensure proper interpolation
        let sortedPoints = stops.sorted { $0.0 < $1.0 }

        var gradientColors: [HSLColor] = []

        for i in 0..<length {
            let position = Double(i) / Double(length - 1)
            let color = interpolateColor(at: position, points: sortedPoints)
            gradientColors.append(color)
        }

        self.init(points: gradientColors)
    }
}

/// Helper function to interpolate color at a given position
private func interpolateColor(at position: Double, points: [(Double, HSLColor)]) -> HSLColor {
    // Handle edge cases
    if position <= points.first!.0 {
        return points.first!.1
    }
    if position >= points.last!.0 {
        return points.last!.1
    }

    // Find the two points to interpolate between
    for i in 0..<(points.count - 1) {
        let leftPoint = points[i]
        let rightPoint = points[i + 1]

        if position >= leftPoint.0 && position <= rightPoint.0 {
            let range = rightPoint.0 - leftPoint.0
            let t = range > 0 ? (position - leftPoint.0) / range : 0.0

            return interpolateHSLColors(leftPoint.1, rightPoint.1, t: t)
        }
    }

    // Fallback (shouldn't reach here)
    return points.first!.1
}

/// Helper function to interpolate between two HSL colors
private func interpolateHSLColors(_ color1: HSLColor, _ color2: HSLColor, t: Double) -> HSLColor {
    let h = interpolateHue(color1.hue, color2.hue, t: t)
    let s = color1.saturation + (color2.saturation - color1.saturation) * t
    let l = color1.luminance + (color2.luminance - color1.luminance) * t

    return HSLColor(hue: h, saturation: s, luminance: l)
}

/// Helper function to interpolate hue values (handles the circular nature of hue)
private func interpolateHue(_ hue1: Double, _ hue2: Double, t: Double) -> Double {
    let diff = hue2 - hue1

    // Choose the shorter path around the color wheel
    let adjustedDiff: Double
    if abs(diff) > 180 {
        adjustedDiff = diff > 0 ? diff - 360 : diff + 360
    } else {
        adjustedDiff = diff
    }

    let result = hue1 + adjustedDiff * t

    // Normalize to 0-360 range
    if result < 0 {
        return result + 360
    } else if result >= 360 {
        return result - 360
    } else {
        return result
    }
}
