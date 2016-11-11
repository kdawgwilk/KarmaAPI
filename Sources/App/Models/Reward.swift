import Vapor
import Fluent
import Foundation


final class Reward: BaseModel, Model {
    var name: String
    var groupID: Node?
    var description: String?
    var cost: Int

    init(name: String, description: String? = nil, cost: Int = 5, group: Group) {
        self.name = name
        self.groupID = group.id
        self.description = description
        self.cost = cost
        super.init()
    }

    required override init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        groupID = try node.extract("group_id")
        description = try node.extract("description")
        cost = try node.extract("cost") ?? 5
        try super.init(node: node, in: context)
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
            "name": name,
            "group_id": groupID,
            "description": description,
            "cost": cost
        ])
    }
}

extension Reward: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("rewards") { reward in
            prepare(model: reward)
            reward.string("name")
            reward.string("group_id")
            reward.string("description", optional: true)
            reward.int("cost")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("rewards")
    }
}

// MARK: Merge

extension Reward {
    func merge(updates: Reward) {
        super.merge(updates: updates)
        name = updates.name
        groupID = updates.groupID ?? groupID
        description = updates.description ?? description
        cost = updates.cost
    }
}

extension Reward {
    func group() throws -> Parent<Group> {
        return try parent(groupID)
    }
}
