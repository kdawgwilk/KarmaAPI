import Vapor
import HTTP
import FluentProvider


struct GroupController: ResourceRepresentable {

    func index(request: Request) throws -> ResponseRepresentable {
        guard let user = request.auth.authenticated(User.self) else {
            return try Group.all().makeJSON()
        }
        return try user.groups.all().makeJSON()
    }

    func show(request: Request, group: Group) throws -> ResponseRepresentable {
        guard let user = request.auth.authenticated(User.self) else {
            return group
        }

        guard try group.users.isAttached(user) else {
            throw Abort.notFound
        }

        return group
    }

    func create(request: Request) throws -> ResponseRepresentable {
        guard let json = request.json else {
            throw Abort(.badRequest)
        }

        let group = try Group(json: json)
        try group.save()

        guard let user = request.auth.authenticated(User.self) else {
            return group
        }

        try group.users.add(user)
        return group
    }

    func update(request: Request, group: Group) throws -> ResponseRepresentable {
        guard let json = request.json else {
            throw Abort(.badRequest)
        }

        let new = try Group(json: json)
        let group = group
        group.merge(updates: new)
        try group.save()

        guard let user = request.auth.authenticated(User.self) else {
            return group
        }

        guard try group.users.isAttached(user) else {
            throw Abort.notFound
        }

        return group
    }

    func delete(request: Request, group: Group) throws -> ResponseRepresentable {
        guard let user = request.auth.authenticated(User.self) else {
            try group.delete()
            return group
        }

        guard try group.users.isAttached(user) else {
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
        guard try group.users.isAttached(user) else {
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
            guard try group.users.isAttached(user()) else {
                throw Abort.notFound
            }
            return group
        } else {
            guard let json = json else { throw Abort.badRequest }
            return try Group(node: json)
        }
    }
}
