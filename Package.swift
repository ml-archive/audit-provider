import PackageDescription

let package = Package(
    name: "AuditProvider",
    dependencies: [
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1)
    ]
)
