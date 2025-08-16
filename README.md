# Swift Oklch SIMD

A Swift package for converting between sRGB and Oklch colour spaces, with SIMD acceleration.

Usage:
```swift
// Convert from sRGB to Oklch
let colour = OklchColour.fromRGB(r: 255, g: 0, b: 0)

// Convert from Oklch to sRGB
let srgb = colour.toSRGB()
```
