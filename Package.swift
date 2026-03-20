// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Libretto",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../score"),
        .package(path: "../score-plugins/score-oauth"),
        .package(path: "../score-plugins/score-payments"),
        .package(path: "../score-plugins/score-lucide"),
        .package(path: "../score-plugins/allegro-theme"),
    ],
    targets: [
        .executableTarget(
            name: "Libretto",
            dependencies: [
                .product(name: "Score", package: "Score"),
                .product(name: "ScoreOAuth", package: "score-oauth"),
                .product(name: "ScorePayments", package: "score-payments"),
                .product(name: "ScoreLucide", package: "score-lucide"),
                .product(name: "AllegroTheme", package: "allegro-theme"),
            ],
            path: "Sources"
        )
    ]
)
