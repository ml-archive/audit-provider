import Vapor

public final class Provider: Vapor.Provider {
    public static let repositoryName = "nodes-vapor/audit-provider"

    public init() {}

    public convenience init(config: Config) throws {
        self.init()
    }

    public func boot(_ config: Config) throws {
        config.preparations.append(AuditEvent.self)
    }

    public func boot(_ droplet: Droplet) throws {}

    public func beforeRun(_ droplet: Droplet) throws {}
}
