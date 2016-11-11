import Vapor
import HTTP


struct TaskController: ResourceRepresentable {

    func index(request: Request) throws -> ResponseRepresentable {
        return try request.group().tasks().all().toJSON()
    }

    func show(request: Request, task: Task) throws -> ResponseRepresentable {
        guard try task.group().get()! == request.group() else {
            throw Abort.notFound
        }
        return task
    }

    // FIXME: Needs to verify task is being created in group user has access to
    func create(request: Request) throws -> ResponseRepresentable {
        var task = try request.task()
        try task.save()
        return task
    }

    func update(request: Request, task: Task) throws -> ResponseRepresentable {
        guard try task.group().get()! == request.group() else {
            throw Abort.notFound
        }
        let new = try request.task()
        var task = task
        task.merge(updates: new)
        try task.save()
        return task
    }

    func delete(request: Request, task: Task) throws -> ResponseRepresentable {
        guard try task.group().get()! == request.group() else {
            throw Abort.notFound
        }
        try task.delete()
        return task
    }

    func makeResource() -> Resource<Task> {
        return Resource(
            index: index,
            store: create,
            show: show,
            modify: update,
            destroy: delete
        )
    }
}

extension TaskController {
    func begin(request: Request, task: Task) throws -> ResponseRepresentable {
        let user = try request.user()
        let group = try request.group()
        let score: Score

        var userTask = UserTask(task: task, group: group, user: user)
        try userTask.save()

        guard let userID    = user.id,
            let groupID   = group.id else {
                throw Abort.badRequest
        }

        if let scoreFound = try Score.query().filter("user_id", userID).filter("group_id", groupID).first() {
            score = scoreFound
        } else {
            score = Score(group: group, user: user)
        }


        score.points += task.points
        try score.save()
        return "User score for group \(group.name) = \(score.points)!"
    }

    func markCompleted(request: Request, task: Task) throws -> ResponseRepresentable {
        return "Success"
    }
}

extension TaskController {
    func completed(request: Request) throws -> ResponseRepresentable {
        let group = try request.group()
//        let tasksCompleted = 
        return try group.userTasks().all().makeNode().converted(to: JSON.self)
    }
}

extension Request {
    func task() throws -> Task {
        guard let json = json else { throw Abort.badRequest }
        return try Task(node: json)
    }
}
