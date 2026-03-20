import Score

struct LibrettoTheme: Theme {
    let colorRoles: [String: ColorToken] = [
        "surface": .oklch(1.0, 0, 0),
        "text": .oklch(0.15, 0.010, 260),
        "border": .oklch(0.85, 0.015, 260),
        "accent": .oklch(0.50, 0.18, 280),
        "muted": .oklch(0.55, 0.020, 260),
        "destructive": .oklch(0.55, 0.22, 25),
        "success": .oklch(0.60, 0.19, 145),
        "bg": .oklch(0.99, 0.003, 260),
        "elevated": .oklch(0.97, 0.008, 260),
    ]

    let fontFamilies: [String: String] = [
        "sans": "system-ui, -apple-system, sans-serif",
        "mono": "ui-monospace, monospace",
    ]

    let typeScaleBase: Double = 16
    let spacingUnit: Double = 4
    let radiusBase: Double = 8
}
