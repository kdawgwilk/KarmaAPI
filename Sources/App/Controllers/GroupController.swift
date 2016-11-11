import Vapor
import HTTP
import Fluent


struct GroupController: ResourceRepresentable {

    func index(request: Request) throws -> ResponseRepresentable {
        return try request.user().groups().all().toJSON()
    }

    func show(request: Request, group: Group) throws -> ResponseRepresentable {
        guard try group.users().includes(request.user()) else {
            throw Abort.notFound
        }
        return group
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var group = try request.group()
        try group.save()
        var pivot = Pivot<User, Group>(try request.user(), group)
        try pivot.save()
        return group
    }

    func update(request: Request, group: Group) throws -> ResponseRepresentable {
        guard try group.users().includes(request.user()) else {
            throw Abort.notFound
        }
        let new: Group = try request.group()
        var group = group
        group.merge(updates: new)
        try group.save()
        return group
    }

    func delete(request: Request, group: Group) throws -> ResponseRepresentable {
        guard try group.users().includes(request.user()) else {
            throw Abort.notFound
        }
        try group.delete()
        return group
    }

    func makeResource() -> Resource<Group> {
        return Resource(
            index: index,
            store: create,
            show: show,
            modify: update,
            destroy: delete
        )
    }
}

extension GroupController {
    func score(request: Request, group: Group) throws -> ResponseRepresentable {
        let user = try request.user()
        guard try group.users().includes(user) else {
            throw Abort.notFound
        }
        let points = try Score.query().filter("user_id", user.id!).filter("group_id", group.id!).first()?.points ?? 0
        return try JSON(node: ["points": points])
    }
}

extension Request {
    func group() throws -> Group {
        if let groupID = query?["group_id"]?.int,
            let group = try Group.find(by: groupID) {
            // TODO: Handle invalid :group_id
            guard try group.users().includes(user()) else {
                throw Abort.notFound
            }
            return group
        } else {
            guard let json = json else { throw Abort.badRequest }
            return try Group(node: json)
        }
    }
}
