// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Libretto",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../../framework/score"),
        .package(path: "../../infra/stage"),
        .package(path: "../../framework/plugins/score-oauth"),
        .package(path: "../../framework/plugins/score-payments"),
        .package(path: "../../framework/plugins/score-lucide"),
        .package(path: "../../framework/plugins/allegro-theme"),
    ],
    targets: [
        .executableTarget(
            name: "Libretto",
            dependencies: [
                .product(name: "Score", package: "score"),
                .product(name: "ScoreOAuth", package: "score-oauth"),
                .product(name: "ScorePayments", package: "score-payments"),
                .product(name: "ScoreLucide", package: "score-lucide"),
                .product(name: "AllegroTheme", package: "allegro-theme"),
            ],
            path: "Sources"
        )
    ]
)
