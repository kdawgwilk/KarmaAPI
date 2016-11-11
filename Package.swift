import PackageDescription

let package = Package(
    name: "KarmaAPI",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
	"Sources/App/TurnstileMain.swift",
	"Sources/App/Models/TestUser.swift",
	"Sources/App/Middleware/BasicAuthMiddleware.swift",
	"Sources/App/Middleware/DigitsAuthMiddleware.swift",
	"Sources/App/Collections/BaseCollection.swift",
	"Sources/App/Collections/AuthCollection.swift",
    ]
)

