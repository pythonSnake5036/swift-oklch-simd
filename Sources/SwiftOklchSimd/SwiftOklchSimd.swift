import Foundation
import simd

public struct OklchColour: Equatable {
    static private let linearRgbToLMSMatrix = simd_float3x3(rows: [
        simd_float3(0.4122214708, 0.5363325363, 0.0514459929),
        simd_float3(0.2119034982, 0.6806995451, 0.1073969566),
        simd_float3(0.0883024619, 0.2817188376, 0.6299787005),
    ])
    
    static private let LMSToLinearRGBMatrix = linearRgbToLMSMatrix.inverse
    
    static private let LMSToOklabMatrix = simd_float3x3(rows: [
        simd_float3(0.2104542553, 0.7936177850, -0.0040720468),
        simd_float3(1.9779984951, -2.4285922050, 0.4505937099),
        simd_float3(0.0259040371, 0.7827717662, -0.8086757660),
    ])
    
    static private let OklabToLMSMatrix = LMSToOklabMatrix.inverse
    
    /// Perceptual lightness, ranging from 0 (black) to 1 (white)
    public var lightness: Float
    /// Chromatic intensity, ranging from 0 with no theoretical upper limit
    public var chroma: Float
    /// Hue angle, represented in radians
    public var hue: Float
    
    public init(lightness: Float, chroma: Float, hue: Float) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
    }
    
    /**
        Initializes an `OKLCHColour` from the provided sRGB values
     
        - Parameter red: The value of red, in the range of 0-1
        - Parameter green: The value of green, in the range of 0-1
        - Parameter blue: The value of blue, in the range of 0-1
     */
    public static func fromRGB(r: Float, g: Float, b: Float) -> OklchColour {
        let rgb = simd_float3(r, g, b)
        let linear = sRGBToLinearRGB(rgb: rgb)
        let lms = linearRGBToLMS(rgb: linear)
        let oklab = LMSToOklab(lms: lms)
        let oklch = OklabToOklch(oklab: oklab)
        return OklchColour(lightness: oklch.x, chroma: oklch.y, hue: oklch.z)
    }
    
    /**
        Returns the colour convereted to sRGB on a (red, green, blue) tuple, with values in the range of 0-1
     */
    public func toSRGB() -> (Float, Float, Float) {
        let oklch = simd_float3(lightness, chroma, hue)
        let oklab = Self.OklchToOkLab(oklch: oklch)
        let lms = Self.OklabToLMS(oklab: oklab)
        let linear = Self.LMSToLinearRGB(lms: lms)
        let srgb = clamp(Self.linearRGBToSRGB(rgb: linear), min: 0.0, max: 1.0)
        return (srgb.x, srgb.y, srgb.z)
    }
    
    /**
        Returns the perceptual colour difference with `colour`
     */
    public func difference(_ colour: OklchColour) -> Float {
        let lab1 = Self.OklchToOkLab(oklch: simd_float3(lightness, chroma, hue))
        let lab2 = Self.OklchToOkLab(oklch: simd_float3(colour.lightness, colour.chroma, colour.hue))
        
        return distance(lab1, lab2)
    }
    
    private static func sRGBToLinearRGB(rgb: simd_float3) -> simd_float3 {
        var out = simd_float3()
        out.x = rgb.x <= 0.04045 ? rgb.x / 12.92 : pow((rgb.x + 0.055) / 1.055, 2.4)
        out.y = rgb.y <= 0.04045 ? rgb.y / 12.92 : pow((rgb.y + 0.055) / 1.055, 2.4)
        out.z = rgb.z <= 0.04045 ? rgb.z / 12.92 : pow((rgb.z + 0.055) / 1.055, 2.4)
        return out
    }
    
    private static func linearRGBToSRGB(rgb: simd_float3) -> simd_float3 {
        var out = simd_float3()
        out.x = rgb.x <= 0.0031308 ? rgb.x * 12.92 : 1.055 * pow(rgb.x, 1.0 / 2.4) - 0.055
        out.y = rgb.y <= 0.0031308 ? rgb.y * 12.92 : 1.055 * pow(rgb.y, 1.0 / 2.4) - 0.055
        out.z = rgb.z <= 0.0031308 ? rgb.z * 12.92 : 1.055 * pow(rgb.z, 1.0 / 2.4) - 0.055
        return out
    }
    
    private static func linearRGBToLMS(rgb: simd_float3) -> simd_float3 {
        return OklchColour.linearRgbToLMSMatrix * rgb
    }
    
    private static func LMSToLinearRGB(lms: simd_float3) -> simd_float3 {
        return OklchColour.LMSToLinearRGBMatrix * lms
    }
    
    private static func LMSToOklab(lms: simd_float3) -> simd_float3 {
        return OklchColour.LMSToOklabMatrix * pow(lms, simd_float3(1.0/3.0, 1.0/3.0, 1.0/3.0))
    }
    
    private static func OklabToLMS(oklab: simd_float3) -> simd_float3 {
        return pow(OklchColour.OklabToLMSMatrix * oklab, simd_float3(3.0, 3.0, 3.0))
    }
    
    private static func OklabToOklch(oklab: simd_float3) -> simd_float3 {
        let c = sqrtf(oklab.y * oklab.y + oklab.z * oklab.z)
        let h = atan2f(oklab.z, oklab.y)
        return simd_float3(oklab.x, c, h)
    }
    
    private static func OklchToOkLab(oklch: simd_float3) -> simd_float3 {
        let a = oklch.y * cosf(oklch.z)
        let b = oklch.y * sinf(oklch.z)
        return simd_float3(oklch.x, a, b)
    }
}
