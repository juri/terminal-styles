[![Build](https://github.com/juri/terminal-styles/actions/workflows/ci.yml/badge.svg)](https://github.com/juri/terminal-styles/actions/workflows/ci.yml)
[![Build](https://github.com/juri/terminal-styles/actions/workflows/format.yml/badge.svg)](https://github.com/juri/terminal-styles/actions/workflows/format.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2Fterminal-styles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/juri/terminal-styles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2Fterminal-styles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/juri/terminal-styles)

# terminal-styles

``terminal-styles`` is a small Swift library for building up terminal output styles. It builds on [terminal-ansi].

[terminal-ansi]: https://github.com/juri/terminal-ansi.git

## Example

```swift
var style = Style(foreground: [.colorRGB(.init(intR: 0xff, g: 0, b: 0))])
print(style.apply(to: "Hello, "), terminator: "")
print(style.adding(foregrounds: [.bold, .italic]).apply(to: "world!"))
style.add(background: .colorRGB(.init(intR: 0x90, g: 0xB0, b: 0xFF)))
print(style.apply(to: "With background!"))

let styleAndUnderline = StyleBuilder.styledOutput {
    style
    Foreground.underline
}

StyleBuilder.print {
    Foreground.colorRGB(.init(intR: 0x40, g: 0xD0, b: 0x90))
    Foreground.bold
    styleAndUnderline
    "Builders, too"
}
```

## Documentation

[Documentation] and `Package.swift` snippets are available at [Swift Package Index].

[Documentation]: https://swiftpackageindex.com/juri/terminal-styles/documentation/terminalstyles
[Swift Package Index]: https://swiftpackageindex.com/juri/terminal-styles
