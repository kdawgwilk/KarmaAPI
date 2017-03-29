// swift-tools-version:3.1

import PackageDescription

let vaporBeta = Version(2,0,0, prereleaseIdentifiers: ["beta"])
let mysqlAlpha = Version(2,0,0, prereleaseIdentifiers: ["alpha"])
let fluentBeta = Version(1,0,0, prereleaseIdentifiers: ["beta"])

let package = Package(
    name: "KarmaAPI",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", vaporBeta),
        .Package(url: "https://github.com/vapor/fluent-provider.git", fluentBeta),
        .Package(url: "https://github.com/vapor/mysql-provider.git", mysqlAlpha),
        .Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 0),
        .Package(url: "https://github.com/stormpath/Turnstile.git", majorVersion: 1),
//        .Package(url:"https://github.com/matthijs2704/vapor-apns.git", majorVersion: 1, minor: 1),
    ],
    swiftLanguageVersions: [3, 4],
    exclude: [
        "Config",
        "Database",
        "Tests",
    ]
)

