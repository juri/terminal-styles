//
//  Gradient.swift
//
//  Created by Juri Pakaste on 12.10.2025.
//

import TerminalANSI

/// `GradientHorizontalRGB` is a type that describes a linear gradient that progresses horizontally on a text line.
/// Each `RGBColor8` value in the `points` array represents one character on the line.
public struct GradientHorizontalRGB {
    public let points: [RGBColor8]

    public init(points: [RGBColor8]) {
        self.points = points
    }

    public init(hslPoints: [HSLColor]) {
        let rgbPoints = hslPoints.map(RGBColor8.init(hsl:))
        self.init(points: rgbPoints)
    }

    public init(hslGradient: GradientHorizontalHSL) {
        self.init(hslPoints: hslGradient.points)
    }

    public struct UnequalGradientLengthsError: Error {}

    /// Applies the two gradients to `text`.
    ///
    /// If both `foreground` and `background` are specified, they must have equal number of points.
    /// If `fillWithLeadingCharacter` is specified and the length of the line is less than the number
    /// of elements in ``GradientHorizontalRGB/points``, the character is used to fill the leading edge
    /// of the line. Similarly `fillWithLeadingCharacter` fills out the trailing edge of the line.
    /// If both are specified, an undersized line is centered.
    public static func applyGradients(
        text: some StringProtocol,
        foreground: GradientHorizontalRGB?,
        background: GradientHorizontalRGB?,
        fillWithLeadingCharacter fillerLeading: Character? = nil,
        fillWithTrailingCharacter fillerTrailing: Character? = " ",
        reset: Bool = true,
    ) throws -> String {
        // Check that both gradients have the same number of points if both are provided
        if let fg = foreground, let bg = background, fg.points.count != bg.points.count {
            throw UnequalGradientLengthsError()
        }

        // Get the gradient with the most points to determine the expected length
        let gradientLength = max(foreground?.points.count ?? 0, background?.points.count ?? 0)

        // If no gradients are provided, return the original text
        guard gradientLength > 0 else {
            return String(text)
        }

        let characters = Array(text)
        let textLength = characters.count

        // Determine the working text with proper padding/centering
        let workingText: [Character]
        let startOffset: Int

        if textLength < gradientLength {
            // Text is shorter than gradient, need to pad
            let totalPadding = gradientLength - textLength

            if let leading = fillerLeading, let trailing = fillerTrailing {
                // Center the text
                let leadingPadding = totalPadding / 2
                let trailingPadding = totalPadding - leadingPadding
                workingText =
                    Array(repeating: leading, count: leadingPadding) + characters
                    + Array(repeating: trailing, count: trailingPadding)
                startOffset = 0
            } else if let leading = fillerLeading {
                // Pad with leading character
                workingText = Array(repeating: leading, count: totalPadding) + characters
                startOffset = 0
            } else if let trailing = fillerTrailing {
                // Pad with trailing character
                workingText = characters + Array(repeating: trailing, count: totalPadding)
                startOffset = 0
            } else {
                // No padding, just use the text as-is and center it in the gradient
                workingText = characters
                startOffset = (gradientLength - textLength) / 2
            }
        } else {
            // Text is longer than or equal to gradient
            workingText = characters
            startOffset = 0
        }

        var result = ""
        let maxLength = max(workingText.count, gradientLength)

        for i in 0..<maxLength {
            let textIndex = i - startOffset
            let gradientIndex = min(i, gradientLength - 1)

            // Get the character to render (or space if beyond text bounds)
            let char: Character
            if textIndex >= 0 && textIndex < workingText.count {
                char = workingText[textIndex]
            } else {
                char = " "
            }

            // Build the graphics rendition commands for this character
            var renditions: [SetGraphicsRendition] = []

            if let fg = foreground, gradientIndex < fg.points.count {
                renditions.append(.textRGB(fg.points[gradientIndex]))
            }

            if let bg = background, gradientIndex < bg.points.count {
                renditions.append(.backgroundRGB(bg.points[gradientIndex]))
            }

            // Apply the color and append the character
            if !renditions.isEmpty {
                let colorCode = ANSIControlCode.setGraphicsRendition(renditions)
                result += colorCode.ansiCommand.message
            }

            result += String(char)
        }

        if reset {
            let resetCode = ANSIControlCode.setGraphicsRendition([.reset])
            result += resetCode.ansiCommand.message
        }

        return result
    }
}

/// `GradientHorizontalHSL` is a type that describes a linear gradient that progresses horizontally on a text line.
/// Each `HSLColor` value in the `points` array represents one character on the line.
public struct GradientHorizontalHSL {
    public let points: [HSLColor]

    public init(points: [HSLColor]) {
        self.points = points
    }

    /// Create a `GradientHorizontalHSL` for a line of `length` characters.
    /// - Parameters:
    ///     - points: An array of tuples where the `Double` value is in the range 0...1 and represents
    ///               a fractional location on the line, and the `HSLColor` is a color for that point.
    ///               If the Double value in the first `point` is larger than 0.0, the color from the
    ///               start of the line to that point is solid. If the Double value in the last `point`
    ///               is less than 1.0, the color from that point to the end of the line is solid.
    ///               If there's more than two values, the gradient progresses through those points.
    /// - Returns: A ``GradientHorizontalHSL`` with `length` values in the ``GradientHorizontalHSL/points`` array.
    ///
    public init?(length: Int, points: [(Double, HSLColor)]) {
        guard length > 0, !points.isEmpty else { return nil }

        // Sort points by position to ensure proper interpolation
        let sortedPoints = points.sorted { $0.0 < $1.0 }

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
