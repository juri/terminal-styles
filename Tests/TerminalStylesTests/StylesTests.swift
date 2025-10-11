import Testing

@testable import TerminalStyles

@Suite struct StylesTests {
    @Test func `join overrides background`() {
        var s1 = Style(background: .color256(5), foreground: [.color256(10)])
        s1.add(contentsOf: Style(background: .color256(20)))
        #expect(s1 == Style(background: .color256(20), foreground: [.color256(10)]))
    }

    @Test func `join overrides foreground color`() {
        var s1 = Style(background: .color256(5), foreground: [.color256(10)])
        s1.add(contentsOf: Style(foreground: [.color256(20)]))
        #expect(s1 == Style(background: .color256(5), foreground: [.color256(20)]))
    }

    @Test
    func `join overrides both colors`() async throws {
        var s1 = Style(background: .color256(5), foreground: [.color256(10)])
        s1.add(contentsOf: Style(background: .color256(100), foreground: [.color256(20)]))
        #expect(s1 == Style(background: .color256(100), foreground: [.color256(20)]))
    }

    @Test
    func `join adds non-color foreground`() async throws {
        var s1 = Style(background: .color256(5), foreground: [.color256(10)])
        s1.add(contentsOf: Style(background: .noBackground, foreground: [.bold]))
        #expect(s1 == Style(background: .noBackground, foreground: [.color256(10), .bold]))
    }

    @Test
    func `adding foreground doesn't add same value again`() async throws {
        var s1 = Style(foreground: [.color256(10), .italic])
        s1.add(foreground: .italic)
        #expect(s1 == Style(foreground: [.color256(10), .italic]))
    }

    @Test
    func `adding foreground color removes earlier color but leaves other attributes intact`() async throws {
        var s1 = Style(foreground: [.color256(10), .italic, .underline, .bold])
        s1.add(foreground: .colorBasic(.green))
        #expect(s1 == Style(foreground: [.italic, .underline, .bold, .colorBasic(.green)]))
    }
}
