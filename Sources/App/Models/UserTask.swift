import Vapor
import Fluent
import Foundation


final class UserTask: BaseModel {
    var taskID: Identifier
    var groupID: Identifier
    var userID: Identifier

    var completedOn: Date?

    init(task: Task, group: Group, user: User, completedOn: Date? = nil) throws {
        guard let taskID = task.id,
              let groupID = group.id,
              let userID = user.id else {
                throw Abort(.internalServerError, reason: "Failed to create UserTask")
        }
        self.taskID             = taskID
        self.groupID            = groupID
        self.userID             = userID
        self.completedOn        = completedOn
        
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
        taskID                  = try node.get("task_id")
        groupID                 = try node.get("group_id")
        userID                  = try node.get("user_id")
        completedOn             = try node.get("completed_on")

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

        try node.set("task_id", taskID)
        try node.set("group_id", groupID)
        try node.set("user_id", userID)
        try node.set("completed_on", completedOn)

        return node
    }
}

extension UserTask: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            prepare(self, with: builder)
            
            builder.foreignId(for: Task.self)
            builder.foreignId(for: Group.self)
            builder.foreignId(for: User.self)
            // FIXME: Why the compiler error
            builder.date("completed_on", optional: true)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension UserTask {
    func merge(updates: UserTask) {
        super.merge(updates: updates)

        taskID                  = updates.taskID
        groupID                 = updates.groupID
        userID                  = updates.userID

        completedOn             = updates.completedOn ?? completedOn
    }
}

extension UserTask {
    var task: Parent<UserTask, Task> {
        return parent(id: taskID)
    }

    var group: Parent<UserTask, Group> {
        return parent(id: groupID)
    }

    var user: Parent<UserTask, User> {
        return parent(id: userID)
    }
}
