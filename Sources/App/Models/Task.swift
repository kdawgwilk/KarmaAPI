import Vapor
import Fluent
import Foundation


final class Task: BaseModel, Model {
    var name: String
    var groupID: Node?
    var description: String?
    var points: Int

    init(name: String, description: String? = nil, points: Int = 5, group: Group) {
        self.name = name
        self.groupID = group.id
        self.points = points
        super.init()
    }

    override init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        groupID = try node.extract("group_id")
        description = try node.extract("description")
        points = try node.extract("points") ?? 5
        try super.init(node: node, in: context)
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
            "name": name,
            "group_id": groupID,
            "description": description,
            "points": points
        ])
    }
}

extension Task: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("tasks") { task in
            prepare(model: task)
            task.string("name")
            task.string("group_id")
            task.string("description", optional: true)
            task.int("points")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("tasks")
    }
}

// MARK: Merge

extension Task {
    func merge(updates: Task) {
        super.merge(updates: updates)
        name = updates.name
        groupID = updates.groupID ?? groupID
        description = updates.description ?? description
        points = updates.points
    }
}

// MARK: Relationships

extension Task {
    func group() throws -> Parent<Group> {
        return try parent(groupID)
    }
}
