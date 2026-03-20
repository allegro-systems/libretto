import Score

struct LibrettoTheme: Theme {
    let colorRoles: [String: ColorToken] = [
        "surface": .oklch(1.0, 0, 0),
        "text": .oklch(0.15, 0.010, 70),
        "border": .oklch(0.82, 0.020, 75),
        "accent": .oklch(0.62, 0.12, 75),
        "muted": .oklch(0.58, 0.020, 70),
        "destructive": .oklch(0.55, 0.22, 25),
        "success": .oklch(0.60, 0.19, 145),
        "bg": .oklch(0.98, 0.005, 80),
        "elevated": .oklch(0.96, 0.012, 80),
        "dimmer": .oklch(0.80, 0.018, 75),
        "score": .oklch(0.50, 0.10, 240),
        "stage": .oklch(0.48, 0.16, 350),
        "composer": .oklch(0.55, 0.14, 155),
        "libretto": .oklch(0.62, 0.12, 75),
        "sun": .oklch(0.62, 0.12, 75),
        "moon": .oklch(0.58, 0.020, 70),
    ]

    let fontFamilies: [String: String] = [
        "sans": "'Inter', system-ui, -apple-system, sans-serif",
        "serif": "'Fraunces', serif",
        "mono": "'DM Mono', ui-monospace, monospace",
    ]

    let stylesheetImports: [String] = [
        "https://fonts.googleapis.com/css2?family=DM+Mono:ital,wght@0,300;0,400;0,500;1,300;1,400;1,500&display=swap",
        "https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,100..900;1,9..144,100..900&display=swap",
    ]

    let typeScaleBase: Double = 16
    let spacingUnit: Double = 4
    let radiusBase: Double = 8

    let dark: (any ThemePatch)? = LibrettoDarkPatch()

    var named: [String: any ThemePatch] {
        ["dark": LibrettoDarkPatch()]
    }
}

struct LibrettoDarkPatch: ThemePatch {
    var syntaxTheme: SyntaxTheme? { .scoreDefault }

    let colorRoles: [String: ColorToken]? = [
        "surface": .oklch(0.145, 0.010, 75),
        "text": .oklch(0.915, 0.025, 83),
        "border": .oklch(0.28, 0.015, 70),
        "accent": .oklch(0.76, 0.095, 78),
        "muted": .oklch(0.53, 0.025, 72),
        "bg": .oklch(0.098, 0.006, 80),
        "elevated": .oklch(0.185, 0.014, 72),
        "dimmer": .oklch(0.305, 0.016, 70),
        "score": .oklch(0.68, 0.065, 240),
        "stage": .oklch(0.60, 0.115, 345),
        "composer": .oklch(0.76, 0.105, 152),
        "libretto": .oklch(0.76, 0.095, 78),
        "sun": .oklch(0.53, 0.025, 72),
        "moon": .oklch(0.76, 0.095, 78),
    ]
}
