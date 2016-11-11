import Vapor
import Fluent
import HTTP
import Auth
import Foundation
import TurnstileCrypto
import Hash


final class User: BaseModel, Model {

    // Required properties
    // Example ID: 723205272156524544
    var digitsID: String
    var phoneNumber: String
    var accessToken: String?

    convenience init(credentials: DigitsCredentials) throws {
        try self.init(digitsID: credentials.digitsID, phoneNumber: credentials.phoneNumber)
    }

    init(digitsID: String, phoneNumber: String) throws {
        self.digitsID = digitsID
        self.phoneNumber = phoneNumber
        self.accessToken = try Hash.random(.sha512).base64String
        super.init()
    }

    override init(node: Node, in context: Context) throws {
        digitsID = try node.extract("digits_id")
        phoneNumber = try node.extract("phone_number")
        accessToken = try node.extract("access_token")
        try super.init(node: node, in: context)
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "created_on": createdOn,
            "digits_id": digitsID,
            "phone_number": phoneNumber,
            "access_token": accessToken,
        ])
    }

    func groups() throws -> Siblings<Group> {
        return try siblings()
    }
}

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        let user: User?
        
        switch credentials {
        // This is used with cookies, but is broken currently
        case let id as Identifier:
            user = try User.find(id.id)
        // All requests should use this auth method except for initial login
        case let credentials as AccessToken:
            user = try User.query().filter("access_token", credentials.string).first()
        // Only used for initial login
        case let credentials as DigitsCredentials:
            let userList = try User.query().filter("digits_id", credentials.digitsID).all()
            if userList.count > 0  {
                user = userList.first
            } else {
                user = try User(credentials: credentials)
                try user!.save()
            }
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }

        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found.")
        }

        return u
    }

    // This shouldn't be used because a user can be created with the above method instead
    static func register(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let credentials as DigitsCredentials:
            var user = try User(credentials: credentials)
            try user.save()
            return user
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
    }
}

//extension Request {
//    func user() throws -> User {
//        guard let user = try auth.user() as? User else {
//            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
//        }
//
//        return user
//    }
//}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users") { user in
            prepare(model: user)
            user.string("digits_id")
            user.string("phone_number")
            user.string("access_token", optional: true)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}

// MARK: Merge

extension User {
    func merge(updates: User) {
        super.merge(updates: updates)
        digitsID = updates.digitsID
        phoneNumber = updates.phoneNumber
        accessToken = updates.accessToken
    }
}

// MARK: Relationships

extension User {
    func points() throws -> Children<Score> {
        return children()
    }

    func userTasks() throws -> Children<UserTask> {
        return children()
    }

    func userRewards() throws -> Children<UserReward> {
        return children()
    }
}



