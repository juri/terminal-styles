//
//  GradientSnapshotTests.swift
//
//  Created by Juri Pakaste on 15.10.2025.
//

import SnapshotTesting
import TerminalANSI
import TerminalStyles
import Testing

@Suite struct GradientSnapshotTests {
    @Test func `vertical foreground`() {
        let text = """
            0ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            1ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            2ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            3ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            4ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            5ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            """
        let lines = text.split(separator: "\n")
        let gradient = VerticalForegroundPerCharacterStyler(
            linearGradientLength: lines.count,
            stops: [
                (0.0, RGBColor8(intR: 0x00, g: 0x00, b: 0x90)),
                (1.0, RGBColor8(intR: 0x00, g: 0x00, b: 0x40)),
            ]
        )!
        assertSnapshot(of: gradient.apply(lines: lines, addNewLines: true, reset: true), as: .lines)
    }

    @Test func `vertical background`() {
        let text = """
            0ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            1ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            2ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            3ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            4ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            5ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            """
        let lines = text.split(separator: "\n")
        let gradient = VerticalBackgroundPerCharacterStyler(
            linearGradientLength: lines.count,
            stops: [
                (0.0, RGBColor8(intR: 0x90, g: 0x20, b: 0x30)),
                (0.3, RGBColor8(intR: 0xFF, g: 0x30, b: 0xA0)),
                (1.0, RGBColor8(intR: 0x10, g: 0x40, b: 0x60)),
            ]
        )!
        assertSnapshot(of: gradient.apply(lines: lines, addNewLines: true, reset: true), as: .lines)
    }

    @Test func `horizontal foreground`() {
        let text = """
            0ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            1ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            2ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            3ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            4ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            5ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            """
        let lines = text.split(separator: "\n")
        let gradient = HorizontalForegroundPerCharacterStyler(
            linearGradientLength: lines[0].count,
            stops: [
                (0.0, RGBColor8(intR: 0x00, g: 0x00, b: 0x90)),
                (1.0, RGBColor8(intR: 0x00, g: 0x00, b: 0x40)),
            ]
        )!
        assertSnapshot(of: gradient.apply(lines: lines, addNewLines: true, reset: true), as: .lines)
    }

    @Test func `horizontal background`() {
        let text = """
            0ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            1ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            2ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            3ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            4ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            5ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            """
        let lines = text.split(separator: "\n")
        let gradient = HorizontalBackgroundPerCharacterStyler(
            linearGradientLength: lines[0].count,
            stops: [
                (0.0, RGBColor8(intR: 0x90, g: 0x20, b: 0x30)),
                (0.3, RGBColor8(intR: 0xFF, g: 0x30, b: 0xA0)),
                (1.0, RGBColor8(intR: 0x10, g: 0x40, b: 0x60)),
            ]
        )!
        assertSnapshot(of: gradient.apply(lines: lines, addNewLines: true, reset: true), as: .lines)
    }

    @Test func `joined stylers`() {
        let text = """
            0ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            1ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            2ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            3ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            4ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            5ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö    
            """
        let lines = text.split(separator: "\n")
        let bgGradient = HorizontalBackgroundPerCharacterStyler(
            linearGradientLength: lines[0].count,
            stops: [
                (0.0, RGBColor8(intR: 0x90, g: 0x20, b: 0x30)),
                (0.3, RGBColor8(intR: 0xFF, g: 0x30, b: 0xA0)),
                (1.0, RGBColor8(intR: 0x10, g: 0x40, b: 0x60)),
            ]
        )!
        let fgGadient = VerticalForegroundPerCharacterStyler(
            linearGradientLength: lines.count,
            stops: [
                (0.0, RGBColor8(intR: 0x00, g: 0x00, b: 0x90)),
                (1.0, RGBColor8(intR: 0x00, g: 0x00, b: 0x40)),
            ]
        )!
        let joinedGradient = JoinedPerCharacterStyler(styler1: bgGradient, styler2: fgGadient)

        assertSnapshot(of: joinedGradient.apply(lines: lines, addNewLines: true, reset: true), as: .lines)
    }
}
