import Vapor
import Fluent
import Foundation


final class Task: BaseModel {
    var name: String
    var groupID: Identifier
    var description: String?
    var points: Int

    init(name: String, description: String? = nil, points: Int = 5, group: Group) throws {
        guard let groupID = group.id else {
            throw Abort(.internalServerError, reason: "Failed to create Task")
        }
        self.name               = name
        self.groupID            = groupID
        self.points             = points

        super.init()
    }

    // MARK: Data Initializers

    required convenience init(row: Row) throws {
        try self.init(node: row)
    }

    required convenience init(json: JSON) throws {
        try self.init(node: json)
    }

    required init(node: Node) throws {
        name                    = try node.get("name")
        groupID                 = try node.get("group_id")
        description             = try node.get("description")
        points                  = try node.get("points") ?? 5

        try super.init(node: node)
    }

    // MARK: Data Constructors

    override func makeRow() throws -> Row {
        return try makeNode(in: rowContext).converted()
    }

    override func makeJSON() throws -> JSON {
        return try makeNode(in: jsonContext).converted()
    }

    override func makeNode(in context: Context?) throws -> Node {
        var node = try super.makeNode(in: context)

        try node.set("name", name)
        try node.set("group_id", groupID)
        try node.set("description", description)
        try node.set("points", points)

        return node
    }
}

// MARK: Preparations

extension Task: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            prepare(self, with: builder)
            
            builder.string("name")
            builder.foreignId(for: Group.self)
            builder.string("description", optional: true)
            builder.int("points")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension Task {
    func merge(updates: Task) {
        super.merge(updates: updates)
        
        name                    = updates.name
        groupID                 = updates.groupID
        description             = updates.description ?? description
        points                  = updates.points
    }
}

// MARK: Relationships

extension Task {
    var group: Parent<Task, Group> {
        return parent(id: groupID)
    }
}
