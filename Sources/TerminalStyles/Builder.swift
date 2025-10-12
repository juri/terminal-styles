//
//  Builder.swift
//
//  Created by Juri Pakaste on 10.10.2025.
//

import Foundation
import TerminalANSI

/// Build ``StyledOutput`` from ``Foreground``, ``Background``, ``Style``, ``String``
/// and other ``StyledOutput`` values.
///
/// Use ``string(_:)`` to generate a printable string, or call directly one of the static `print` methods
/// to print it out.
@resultBuilder
public struct StyleBuilder: Sendable {
    public static func buildBlock() -> any StyledOutput { StyledOutputEmpty() }
    public static func buildBlock(_ components: (any StyledOutput)...) -> any StyledOutput {
        StyledOutputGroup(group: components)
    }
    public static func buildPartialBlock(first: any StyledOutput) -> any StyledOutput { first }
    public static func buildPartialBlock(accumulated: any StyledOutput, next: any StyledOutput) -> any StyledOutput {
        StyledOutputGroup(group: [accumulated, next])
    }

    public static func buildEither(first component: any StyledOutput) -> any StyledOutput { component }
    public static func buildEither(second component: any StyledOutput) -> any StyledOutput { component }
    public static func buildExpression(_ expression: String) -> any StyledOutput { StyledOutputText(text: expression) }
    public static func buildExpression(_ expression: Foreground) -> any StyledOutput {
        StyledOutputForeground(foreground: [expression])
    }
    public static func buildExpression(_ expression: [Foreground]) -> any StyledOutput {
        StyledOutputForeground(foreground: expression)
    }
    public static func buildExpression(_ expression: Background) -> any StyledOutput {
        StyledOutputBackground(background: expression)
    }
    public static func buildExpression(_ expression: Style) -> any StyledOutput {
        StyledOutputStyle(style: expression)
    }
    public static func buildExpression(_ expression: (any StyledOutput)?) -> any StyledOutput {
        expression.map { StyledOutputGroup(group: [$0]) } ?? StyledOutputEmpty()
    }
    public static func buildIf(_ element: (any StyledOutput)?) -> any StyledOutput { element ?? StyledOutputEmpty() }

    /// Generate a ``StyledOutput`` value from `builder`.
    public static func styledOutput(@StyleBuilder _ builder: () -> any StyledOutput) -> any StyledOutput {
        builder()
    }

    /// Generate a `String` value from `builder`.
    public static func string(@StyleBuilder _ builder: () -> any StyledOutput) -> String {
        builder().controlCode.map(\.ansiCommand.message).joined()
    }

    /// Print out the string generated from `builder`.
    public static func print(@StyleBuilder _ builder: () -> any StyledOutput) {
        Swift.print(self.string(builder))
    }

    /// Print out the string generated from `builder` to `stream`.
    public static func print(to stream: inout some TextOutputStream, @StyleBuilder _ builder: () -> any StyledOutput) {
        Swift.print(self.string(builder), to: &stream)
    }

    /// Print out the string generated from `builder` to `fileHandle`.
    public static func print(to fileHandle: FileHandle, @StyleBuilder _ builder: () -> any StyledOutput) throws {
        try fileHandle.write(contentsOf: Data(self.string(builder).utf8))
    }
}

/// Text combined with styles you can build with ``StyleBuilder``.
public protocol StyledOutput {
    var controlCode: [ANSIControlCode] { get }
}

/// A ``StyleOutput`` value with ``Foreground`` values.
public struct StyledOutputForeground: StyledOutput {
    public var foreground: [Foreground]

    public init(foreground: [Foreground]) {
        self.foreground = foreground
    }

    public var controlCode: [ANSIControlCode] {
        [ANSIControlCode.setGraphicsRendition(self.foreground.map(\.setGraphicsRendition))]
    }
}

/// A ``StyleOutput`` value with a ``Style`` value.
public struct StyledOutputStyle: StyledOutput {
    public var style: Style

    public init(style: Style) {
        self.style = style
    }

    public var controlCode: [ANSIControlCode] {
        [self.style.ansiControlCode]
    }
}

/// A ``StyleOutput`` value with a ``Background`` value.
public struct StyledOutputBackground: StyledOutput {
    public var background: Background?

    public init(background: Background? = nil) {
        self.background = background
    }

    public var controlCode: [ANSIControlCode] {
        guard let sgr = self.background?.setGraphicsRendition else {
            return []
        }
        return [ANSIControlCode.setGraphicsRendition([sgr])]
    }
}

/// A ``StyleOutput`` value with a ``String``.
public struct StyledOutputText: StyledOutput {
    public var text: String

    public init(text: String) {
        self.text = text
    }

    public var controlCode: [ANSIControlCode] {
        [ANSIControlCode.literal(self.text)]
    }
}

/// Empty ``StyleOutput``.
public struct StyledOutputEmpty: StyledOutput {
    public let controlCode: [ANSIControlCode] = []
}

/// A ``StyleOutput`` value with a list of ``StyleOutput`` values.
public struct StyledOutputGroup: StyledOutput {
    var group: [any StyledOutput]

    public var controlCode: [ANSIControlCode] {
        group.flatMap(\.controlCode)
    }
}
