import Testing
@testable import SwiftOklchSimd

@Test func sRGBToOklch() async throws {
    let r = Float(64) / 255
    let g = Float(177) / 255
    let b = Float(183) / 255
    
    let colour = OklchColour.fromRGB(r: r, g: g, b: b)
    #expect(colour == OklchColour(lightness: 0.6999109, chroma: 0.10010426, hue: -2.789962))
}

@Test func OklchToSRGB() async throws {
    let r: Float = 0.25098106
    let g: Float = 0.6941175
    let b: Float = 0.7176471
    
    let colour = OklchColour(lightness: 0.6999109, chroma: 0.10010426, hue: -2.789962)
    #expect(colour.toSRGB() == (r, g, b))
}

@Test func difference() async throws {
    let c1 = OklchColour.fromRGB(r: 255, g: 0, b: 0)
    let c2 = OklchColour.fromRGB(r: 0, g: 255, b: 0)
    
    #expect(c1.difference(c2) == 41.932644)
}
