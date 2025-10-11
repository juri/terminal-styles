//
//  Builder.swift
//
//  Created by Juri Pakaste on 10.10.2025.
//

import Foundation
import TerminalANSI

@resultBuilder
public struct StyleBuilder {
    public static func buildBlock() -> StyledOutput { StyledOutputEmpty() }
    public static func buildBlock(_ components: StyledOutput...) -> StyledOutput {
        StyledOutputGroup(group: components)
    }
    public static func buildPartialBlock(first: StyledOutput) -> StyledOutput { first }
    public static func buildPartialBlock(accumulated: StyledOutput, next: StyledOutput) -> StyledOutput {
        StyledOutputGroup(group: [accumulated, next])
    }

    public static func buildEither(first component: StyledOutput) -> StyledOutput { component }
    public static func buildEither(second component: StyledOutput) -> StyledOutput { component }
    public static func buildExpression(_ expression: String) -> StyledOutput { StyledOutputText(text: expression) }
    public static func buildExpression(_ expression: Foreground) -> StyledOutput {
        StyledOutputForeground(foreground: [expression])
    }
    public static func buildExpression(_ expression: [Foreground]) -> StyledOutput {
        StyledOutputForeground(foreground: expression)
    }
    public static func buildExpression(_ expression: Background) -> StyledOutput {
        StyledOutputBackground(background: expression)
    }
    public static func buildExpression(_ expression: Style) -> any StyledOutput {
        StyledOutputStyle(style: expression)
    }
    public static func buildExpression(_ expression: StyledOutput?) -> StyledOutput {
        expression.map { StyledOutputGroup(group: [$0]) } ?? StyledOutputEmpty()
    }
    public static func buildIf(_ element: StyledOutput?) -> StyledOutput { element ?? StyledOutputEmpty() }

    public static func styledOutput(@StyleBuilder _ builder: () -> any StyledOutput) -> any StyledOutput {
        builder()
    }

    public static func string(@StyleBuilder _ builder: () -> any StyledOutput) -> String {
        builder().controlCode.map(\.ansiCommand.message).joined()
    }

    public static func print(@StyleBuilder _ builder: () -> any StyledOutput) {
        Swift.print(self.string(builder))
    }

    public static func print(to stream: inout some TextOutputStream, @StyleBuilder _ builder: () -> any StyledOutput) {
        Swift.print(self.string(builder), to: &stream)
    }

    public static func print(to fileHandle: FileHandle, @StyleBuilder _ builder: () -> any StyledOutput) throws {
        try fileHandle.write(contentsOf: Data(self.string(builder).utf8))
    }
}

public func buildCodes(@StyleBuilder _ builder: () -> any StyledOutput) -> String {
    builder().controlCode.map(\.ansiCommand.message).joined()
}

public protocol StyledOutput {
    var controlCode: [ANSIControlCode] { get }
}

public struct StyledOutputForeground: StyledOutput {
    public var foreground: [Foreground]

    public init(foreground: [Foreground]) {
        self.foreground = foreground
    }

    public var controlCode: [ANSIControlCode] {
        [ANSIControlCode.setGraphicsRendition(self.foreground.map(\.setGraphicsRendition))]
    }
}

public struct StyledOutputStyle: StyledOutput {
    public var style: Style

    public init(style: Style) {
        self.style = style
    }

    public var controlCode: [ANSIControlCode] {
        [self.style.ansiControlCode]
    }
}

public struct StyledOutputBackground: StyledOutput {
    public var background: Background?

    public init(background: Background? = nil) {
        self.background = background
    }

    public var controlCode: [ANSIControlCode] {
        guard let background = self.background else {
            return []
        }
        return [ANSIControlCode.setGraphicsRendition([background.setGraphicsRendition])]
    }
}

public struct StyledOutputText: StyledOutput {
    public var text: String

    public init(text: String) {
        self.text = text
    }

    public var controlCode: [ANSIControlCode] {
        [ANSIControlCode.literal(self.text)]
    }
}

public struct StyledOutputEmpty: StyledOutput {
    public let controlCode: [ANSIControlCode] = []
}

public struct StyledOutputGroup: StyledOutput {
    var group: [any StyledOutput]

    public var controlCode: [ANSIControlCode] {
        group.flatMap(\.controlCode)
    }
}

enum BuildStyle {
    case foreground(Foreground?)
    case background(Background?)
    case text(String)
}
