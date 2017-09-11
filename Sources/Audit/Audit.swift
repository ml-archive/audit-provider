import FluentProvider

public struct Audit {
    public enum Error: Swift.Error {
        case invalidEntityIdType
    }

    public enum EventType {
        case created
        case updated
        case deleted
        case custom(String, UInt8)
    }

    public enum Severity {
        case debug
        case normal
        case important
        case danger
        case custom(UInt8)
    }

    @discardableResult
    public static func report<M: Model>(_ author: Author, itemType: M.Type = M.self, event: EventType, severity: Severity = .normal) throws -> AuditEvent {
        guard let id = author.id?.int else { throw Error.invalidEntityIdType }
        let message = event.generateMessage(for: author.name, itemType: itemType)
        let event = AuditEvent(authorId: id, eventType: event, severityType: severity, message: message)
        try event.save()
        return event
    }

    @discardableResult
    public static func report<M: Model>(_ author: Author, itemType: M.Type = M.self, event: String, eventTypeId: UInt8 = 3, severity: Severity = .normal) throws -> AuditEvent {
        return try report(author, itemType: itemType, event: .custom(event, eventTypeId), severity: severity)
    }
}

extension Audit.EventType {
    public func generateMessage<M: Model>(for userName: String, itemType: M.Type = M.self) -> String {
        let itemType = (itemType as? AuditCustomDescribable.Type)?.auditDescription ?? M.name
        let string = "a/an '\(itemType)'"
        switch self {
        case .created: return "\(userName) created \(string)"
        case .updated: return "\(userName) updated \(string)"
        case .deleted: return "\(userName) deleted \(string)"
        case .custom(let message, _): return message
        }
    }
}

extension Model {
    @discardableResult
    public static func audit(_ author: Author, event: Audit.EventType, severity: Audit.Severity = .normal) throws -> AuditEvent {
        return try Audit.report(author, itemType: Self.self, event: event, severity: severity)
    }

    @discardableResult
    public static func audit(_ author: Author, event: String, eventTypeId: UInt8 = 3, severity: Audit.Severity = .normal) throws -> AuditEvent {
        return try audit(author, event: .custom(event, eventTypeId), severity: severity)
    }
}
