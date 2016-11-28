import Foundation

// Vapor
import HTTP
import Vapor


struct UserController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().toJSON()
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var user = try request.user()
        try user.save()
        return user
    }
    
    func update(request: Request, user: User) throws -> ResponseRepresentable {
        let new = try request.user()
        var user = user
        user.merge(updates: new)
        try user.save()
        return user
    }

    func delete(request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return user
    }

    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: create,
            show: show,
            modify: update,
            destroy: delete
        )
    }
}
