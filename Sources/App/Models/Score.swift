import Vapor
import Fluent
import Foundation


final class Score: BaseModel {
    var points: Int
    var groupID: Identifier
    var userID: Identifier

    init(points: Int = 0, group: Group, user: User) throws {
        guard let groupID = group.id,
              let userID = user.id else {
            throw Abort(.internalServerError, reason: "Failed to create Score")
        }
        self.points             = points
        self.groupID            = groupID
        self.userID             = userID

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
        points                  = try node.get("points")
        groupID                 = try node.get("group_id")
        userID                  = try node.get("user_id")

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

        try node.set("points", points)
        try node.set("group_id", groupID)
        try node.set("user_id", userID)

        return node
    }
}

extension Score: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            super.prepare(self, with: builder)

            builder.string("points")
            builder.foreignId(for: Group.self)
            builder.foreignId(for: User.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension Score {
    func merge(updates: Score) {
        super.merge(updates: updates)

        points                  = updates.points
        groupID                 = updates.groupID
        userID                  = updates.userID
    }
}

extension Score {
    var group: Parent<Score, Group> {
        return parent(id: groupID)
    }

    var user: Parent<Score, User> {
        return parent(id: userID)
    }
}
