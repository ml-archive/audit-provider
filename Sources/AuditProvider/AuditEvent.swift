import FluentProvider

public final class AuditEvent: Model {
    public let storage = Storage()

    public let authorId: Int
    public let eventTypeId: UInt8
    public let severityTypeId: UInt8
    public let message: String

    public var eventType: Audit.EventType {
        return Audit.EventType.fromMySQL(eventTypeId, message: message)
    }

    public var severity: Audit.Severity {
        return Audit.Severity.fromMySQL(severityTypeId)
    }

    public init(authorId: Int, eventType: Audit.EventType, severityType: Audit.Severity, message: String) {
        self.authorId = authorId
        self.eventTypeId = eventType.toMySQL
        self.severityTypeId = severityType.toMySQL
        self.message = message
    }

    public init(row: Row) throws {
        authorId = try row.get("authorId")
        eventTypeId = try row.get("eventTypeId")
        severityTypeId = try row.get("severityTypeId")
        message = try row.get("message")
    }

    public func makeRow() throws -> Row {
        var row = Row()

        try row.set("authorId", authorId)
        try row.set("eventTypeId", eventTypeId)
        try row.set("severityTypeId", severityTypeId)
        try row.set("message", message)

        return row
    }
}
extension AuditEvent: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return try makeRow().converted(to: Node.self)
    }
}
extension AuditEvent: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        return try makeRow().converted(to: JSON.self)
    }
}
extension AuditEvent: ViewDataRepresentable {
    public func makeViewData() throws -> ViewData {
        return try makeRow().converted(to: ViewData.self)
    }
}
extension AuditEvent: Timestampable {}
extension AuditEvent: SoftDeletable {}
extension AuditEvent: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.int("authorId")
            $0.custom("eventTypeId", type: "TINYINT UNSIGNED")
            $0.custom("severityTypeId", type: "TINYINT UNSIGNED")
            $0.string("message", length: 191)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Audit.EventType {
    public var toMySQL: UInt8 {
        switch self {
        case .created:              return 0
        case .updated:              return 1
        case .deleted:              return 2
        case .custom(_, let val):   return val
        }
    }

    public static func fromMySQL(_ typeId: UInt8, message: String? = nil) -> Audit.EventType {
        switch typeId {
        case 0: return  .created
        case 1: return  .updated
        case 2: return  .deleted
        default: return .custom(message ?? "The event's message was not provided in the `fromMySQL` call", typeId)
        }
    }
}

extension Audit.Severity {
    public var toMySQL: UInt8 {
        switch self {
        case .debug:            return 0
        case .normal:           return 1
        case .important:        return 2
        case .danger:           return 3
        case .custom(let val):  return val
        }
    }

    public static func fromMySQL(_ severityId: UInt8) -> Audit.Severity {
        switch severityId {
        case 0: return  .debug
        case 1: return  .normal
        case 2: return  .important
        case 3: return  .danger
        default: return .custom(severityId)
        }
    }
}

