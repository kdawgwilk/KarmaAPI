import Vapor
import Fluent
import Foundation


final class UserTask: BaseModel, Model {
    var taskID: Node?
    var groupID: Node?
    var userID: Node?

    var completedOn: String?

    init(task: Task, group: Group, user: User, completedOn: Date? = nil) {
        self.taskID = task.id
        self.groupID = group.id
        self.userID = user.id
        self.completedOn = String(describing: completedOn?.timeIntervalSince1970)
        super.init()
    }

    override init(node: Node, in context: Context) throws {
        taskID = try node.extract("task_id")
        groupID = try node.extract("group_id")
        userID = try node.extract("user_id")
        completedOn = try node.extract("completed_on")
        try super.init(node: node, in: context)
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
//            "task": Task.query().filter("id", taskID!).first(),
            "task_id": taskID,
            "group_id": groupID,
            "user_id": userID,
            "completed_on": completedOn
        ])
    }
}

extension UserTask: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("usertasks") { userTask in
            prepare(model: userTask)
            userTask.string("task_id")
            userTask.string("group_id")
            userTask.string("user_id")
            userTask.string("completed_on")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("usertasks")
    }
}

// MARK: Merge

extension UserTask {
    func merge(updates: UserTask) {
        super.merge(updates: updates)
        taskID = updates.taskID ?? taskID
        groupID = updates.groupID ?? groupID
        userID = updates.userID ?? userID
    }
}

extension UserTask {
    func task() throws -> Parent<Task> {
        return try parent(taskID)
    }

    func group() throws -> Parent<Group> {
        return try parent(groupID)
    }

    func user() throws -> Parent<User> {
        return try parent(userID)
    }
}
