import Vapor
import Fluent
import Foundation


final class Score: BaseModel, Model {
    var points: Int
    var groupID: Node?
    var userID: Node?

    init(points: Int = 0, group: Group, user: User) {
        self.points = points
        self.groupID = group.id
        self.userID = user.id
        super.init()
    }

    override init(node: Node, in context: Context) throws {
        points = try node.extract("points")
        groupID = try node.extract("group_id")
        userID = try node.extract("user_id")
        try super.init(node: node, in: context)
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
            "points": points,
            "group_id": groupID,
            "user_id": userID
        ])
    }
}

extension Score: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("scores") { score in
            prepare(model: score)
            score.string("points")
            score.string("group_id")
            score.string("user_id")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("scores")
    }
}

// MARK: Merge

extension Score {
    func merge(updates: Score) {
        super.merge(updates: updates)
        points = updates.points
        groupID = updates.groupID ?? groupID
        userID = updates.userID ?? userID
    }
}

extension Score {
    func group() throws -> Parent<Group> {
        return try parent(groupID)
    }

    func user() throws -> Parent<User> {
        return try parent(userID)
    }
}
