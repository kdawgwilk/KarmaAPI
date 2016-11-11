import Vapor
import HTTP


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

extension UserController {
    func login(request: Request) throws -> ResponseRepresentable {
        let credentials = try DigitsCredentials(headers: request.headers)

        try request.auth.login(credentials)

        return try request.user()
    }
}

extension Request {
//    func user() throws -> User {
//        if let userID = query?["user_id"]?.int,
//            let user = try User.find(by: userID) {
//            // TODO: Handle invalid :user_id
//            return user
//        } else {
//            guard let json = json else { throw Abort.badRequest }
//            return try User(node: json)
//        }
//    }

    func user() throws -> User {
//        guard let user = try auth.user() as? User else {
//            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
//        }
        guard
            let token = headers["Authorization"],
            let user = try User.query().filter("access_token", token).first() else {
                throw Abort.custom(status: .forbidden, message: "Not authorized.")
        }
        return user
    }
}
