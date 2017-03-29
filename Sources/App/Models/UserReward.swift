import Vapor
import Fluent
import Foundation


final class UserReward: BaseModel {
    var rewardID: Identifier
    var groupID: Identifier
    var userID: Identifier

    var rewardedOn: Date?

    init(reward: Reward, group: Group, user: User, rewardedOn: Date? = nil) throws {
        guard let rewardID = reward.id,
              let groupID = group.id,
              let userID = user.id else {
            throw Abort(.internalServerError, reason: "Failed to create UserReward")
        }
        self.rewardID           = rewardID
        self.groupID            = groupID
        self.userID             = userID
        self.rewardedOn         = rewardedOn

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
        rewardID                = try node.get("reward_id")
        groupID                 = try node.get("group_id")
        userID                  = try node.get("user_id")
        rewardedOn              = try node.get("rewarded_on")

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

        try node.set("reward_id", rewardID)
        try node.set("group_id", groupID)
        try node.set("user_id", userID)
        try node.set("rewarded_on", rewardedOn)

        return node
    }
}

extension UserReward: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            super.prepare(self, with: builder)
            
            builder.foreignId(for: Reward.self)
            builder.foreignId(for: Group.self)
            builder.foreignId(for: User.self)
            // FIXME: Why the compiler error
            builder.date("rewarded_on", optional: true)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension UserReward {
    func merge(updates: UserReward) {
        super.merge(updates: updates)

        rewardID                = updates.rewardID
        groupID                 = updates.groupID
        userID                  = updates.userID

        rewardedOn              = updates.rewardedOn ?? rewardedOn
    }
}

extension UserReward {
    var reward: Parent<UserReward, Reward> {
        return parent(id: rewardID)
    }

    var group: Parent<UserReward, Group> {
        return parent(id: groupID)
    }

    var user: Parent<UserReward, User> {
        return parent(id: userID)
    }
}
