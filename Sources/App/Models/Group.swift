import Vapor
import Fluent
import Foundation


final class Group: BaseModel, Model {
    var name: String
    var description: String?

    init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
        super.init()
    }
    
    override required init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        description = try node.extract("description")
        try super.init(node: node, in: context)
    }
    
    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
            "name": name,
            "description": description
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create("groups") { group in
            prepare(model: group)
            group.string("name")
            group.string("description", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("groups")
    }
}

// MARK: Merge

extension Group {
    func merge(updates: Group) {
        super.merge(updates: updates)
        name = updates.name
        description = updates.description ?? description
    }
}

// MARK: Relationships

extension Group {
    func users() throws -> Siblings<User> {
        return try siblings()
    }

    func tasks() throws -> Children<Task> {
        return children()
    }

    func rewards() throws -> Children<Reward> {
        return children()
    }

    func scores() throws -> Children<Score> {
        return children()
    }

    func userTasks() throws -> Children<UserTask> {
        return children()
    }

    func userRewards() throws -> Children<UserReward> {
        return children()
    }
}
