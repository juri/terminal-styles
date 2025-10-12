//
//  Gradient.swift
//
//  Created by Juri Pakaste on 12.10.2025.
//

import TerminalANSI

/// `GradientHorizontalHSL` is a type that describes a linear gradient that progresses horizontally on a text line.
/// Each `HSLColor` value in the `points` array represents one character on the line.
public struct GradientHorizontalHSL {
    let points: [HSLColor]
}

/// `createGradient` creates a `GradientHorizontalHSL` for a line of `length` characters.
/// - Parameters:
///     - points: An array of tuples where the `Double` value is in the range 0...1 and represents
///               a fractional location on the line, and the `HSLColor` is a color for that point.
///               If the Double value in the first `point` is larger than 0.0, the color from the
///               start of the line to that point is solid. If the Double value in the last `point`
///               is less than 1.0, the color from that point to the end of the line is solid.
///               If there's more than two values, the gradient progresses through those points.
/// - Returns: A ``GradientHorizontalHSL`` with `length` values in the ``GradientHorizontalHSL/points`` array.
///
public func createGradient(length: Int, points: [(Double, HSLColor)]) -> GradientHorizontalHSL? {
    guard length > 0, !points.isEmpty else { return nil }

    // Sort points by position to ensure proper interpolation
    let sortedPoints = points.sorted { $0.0 < $1.0 }

    var gradientColors: [HSLColor] = []

    for i in 0..<length {
        let position = Double(i) / Double(length - 1)
        let color = interpolateColor(at: position, points: sortedPoints)
        gradientColors.append(color)
    }

    return GradientHorizontalHSL(points: gradientColors)
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
