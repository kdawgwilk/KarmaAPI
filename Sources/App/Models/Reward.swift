import Vapor
import Fluent
import Foundation


final class Reward: BaseModel {
    var name: String
    var groupID: Identifier
    var description: String?
    var cost: Int

    // General Initializer

    init(name: String, description: String? = nil, cost: Int = 5, group: Group) throws {
        guard let groupID = group.id else {
            throw Abort(.internalServerError, reason: "Failed to create Reward")
        }
        self.name               = name
        self.groupID            = groupID
        self.description        = description
        self.cost               = cost
        
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
        cost                    = try node.get("cost") ?? 5

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
        try node.set("cost", cost)

        return node
    }
}

extension Reward: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            super.prepare(self, with: builder)
            
            builder.string("name")
            builder.foreignId(for: Group.self)
            builder.string("description", optional: true)
            builder.int("cost")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension Reward {
    func merge(updates: Reward) {
        super.merge(updates: updates)
        
        name                    = updates.name
        groupID                 = updates.groupID
        description             = updates.description ?? description
        cost                    = updates.cost
    }
}

extension Reward {
    var group: Parent<Reward, Group> {
        return parent(id: groupID)
    }
}
