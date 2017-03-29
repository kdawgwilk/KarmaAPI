import Vapor
import Fluent
import Foundation


final class Group: BaseModel {
    var name: String
    var description: String?

    init(name: String, description: String? = nil) {
        self.name               = name
        self.description        = description
        
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
        description             = try node.get("description")

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
        try node.set("description", description)

        return node
    }
}

extension Group: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            super.prepare(self, with: builder)
            
            builder.string("name")
            builder.string("description", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension Group {
    func merge(updates: Group) {
        super.merge(updates: updates)

        name                    = updates.name
        description             = updates.description ?? description
    }
}

// MARK: Relationships

extension Group {
    var users: Siblings<Group, User, Pivot<Group, User>> {
        return siblings()
    }

    var tasks: Children<Group, Task> {
        return children()
    }

    var rewards: Children<Group, Reward> {
        return children()
    }

    var scores: Children<Group, Score> {
        return children()
    }

    var userTasks: Children<Group, UserTask> {
        return children()
    }

    var userRewards: Children<Group, UserReward> {
        return children()
    }
}
