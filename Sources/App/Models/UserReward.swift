import Vapor
import Fluent
import Foundation


final class UserReward: BaseModel, Model {
    var rewardID: Node?
    var groupID: Node?
    var userID: Node?

    var rewardedOn: String?

    init(reward: Reward, group: Group, user: User) {
        self.rewardID = reward.id
        self.groupID = group.id
        self.userID = user.id
        super.init()
    }

    override init(node: Node, in context: Context) throws {
        rewardID = try node.extract("reward_id")
        groupID = try node.extract("group_id")
        userID = try node.extract("user_id")
        try super.init(node: node, in: context)
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
            "reward_id": rewardID,
            "group_id": groupID,
            "user_id": userID
        ])
    }
}

extension UserReward: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("userrewards") { userReward in
            prepare(model: userReward)
            userReward.string("reward_id")
            userReward.string("group_id")
            userReward.string("user_id")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("userrewards")
    }
}

// MARK: Merge

extension UserReward {
    func merge(updates: UserReward) {
        super.merge(updates: updates)
        rewardID = updates.rewardID ?? rewardID
        groupID = updates.groupID ?? groupID
        userID = updates.userID ?? userID
    }
}

extension UserReward {
    func reward() throws -> Parent<Reward> {
        return try parent(rewardID)
    }

    func group() throws -> Parent<Group> {
        return try parent(groupID)
    }

    func user() throws -> Parent<User> {
        return try parent(userID)
    }
}
