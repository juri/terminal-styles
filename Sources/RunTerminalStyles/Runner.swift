//
//  Runner.swift
//
//  Created by Juri Pakaste on 9.10.2025.
//

import TerminalANSI
import TerminalStyles

@main
struct Runner {
    static func main() {
        var style = Style(foreground: [.colorRGB(.init(intR: 0xff, g: 0, b: 0))])
        print(style.apply(to: "Hello, "), terminator: "")
        print(style.adding(foregrounds: [.bold, .italic]).apply(to: "world!"))
        style.add(background: .colorRGB(.init(intR: 0x90, g: 0xB0, b: 0xFF)))
        print(style.apply(to: "With background!"))
    }
}
