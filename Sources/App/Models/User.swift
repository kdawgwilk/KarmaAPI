import Vapor
import FluentProvider
import AuthProvider
import HTTP
//import Auth
import Foundation
import Turnstile
import TurnstileWeb
import TurnstileCrypto
import Crypto


final class User: BaseModel {

    // Required properties
    // Example ID: 723205272156524544
    var username: String
    var password                = ""

    var twitterID               = ""

    var digitsID                = ""
    var phoneNumber             = ""

    var accessToken             = URandom().secureToken
    var apiKeyID                = URandom().secureToken
    var apiKeySecret            = URandom().secureToken

    var firstName               = ""
    var lastName                = ""
    var email                   = ""
    var imageURL                = ""

    // MARK: Auth Inits

    init(credentials: UsernamePassword) {
        self.username           = credentials.username
        self.password           = BCrypt.hash(password: credentials.password)
        super.init()
    }

    init(credentials: DigitsAccount) {
        self.username           = "digit" + credentials.uniqueID
        self.digitsID           = credentials.uniqueID
        super.init()
    }

//    init(credentials: TwitterAccount) {
//        self.username           = "twitter" + credentials.uniqueID
//        self.digitsID           = credentials.uniqueID
//        super.init()
//    }

    // MARK: Data Initializers

    required convenience init(row: Row) throws {
        try self.init(node: row)
    }

    required convenience init(json: JSON) throws {
        try self.init(node: json)
    }

    required init(node: Node) throws {
        username                = try node.get("username")
        password                = try node.get("password")

        accessToken             = try node.get("access_token")
        apiKeyID                = try node.get("api_key_id")
        apiKeySecret            = try node.get("api_key_secret")

        twitterID               = try node.get("twitter_id")

        digitsID                = try node.get("digits_id")
        phoneNumber             = try node.get("phone_number")

        firstName               = try node.get("first_name")
        lastName                = try node.get("last_name")
        email                   = try node.get("email")
        imageURL                = try node.get("image_url")

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

        try node.set("username", username)
        try node.set("password", password)

        try node.set("access_token", accessToken)
        try node.set("api_key_id", apiKeyID)
        try node.set("api_key_secret", apiKeySecret)

        try node.set("twitter_id", twitterID)

        try node.set("digits_id", digitsID)
        try node.set("phone_number", phoneNumber)
        
        try node.set("first_name", firstName)
        try node.set("last_name", lastName)
        try node.set("email", email)
        try node.set("image_url", imageURL)

        return node
    }
}

// MARK: - Authentication

extension User: TokenAuthenticatable {
    typealias TokenType = User
}

extension User: PasswordAuthenticatable {
    static var usernameKey: String {
        return "username"
    }
}

//extension User: Auth.User {
//    static func authenticate(credentials: Credentials) throws -> Auth.User {
//        var user: User?
//        
//        switch credentials {
//        /**
//         Fetches a user, and checks that the password is present, and matches.
//         */
//        case let credentials as UsernamePassword:
//            let fetchedUser = try User.query()
//                .filter("username", credentials.username)
//                .first()
//            if let password = fetchedUser?.password,
//                password != "",
//                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
//                user = fetchedUser
//            }
//
//        /**
//         Fetches the user by session ID. Used by the Vapor session manager.
//         */
//        case let credentials as Identifier:
//            user = try User.find(credentials.id)
//
//        /**
//         Authenticates via AccessToken
//         */
//        case let credentials as AccessToken:
//            user = try User.query().filter("access_token", credentials.string).first()
//
//        /**
//         Fetches the user by Digits ID. If the user doesn't exist, autoregisters it.
//         */
//        case let credentials as DigitsAccount:
//            if let existing = try User.query().filter("digits_id", credentials.uniqueID).first() {
//                user = existing
//            } else {
//                user = try User.register(credentials: credentials) as? User
//            }
//
//        /**
//         Fetches the user by Twitter ID. If the user doesn't exist, autoregisters it.
//         */
//        case let credentials as TwitterAccount:
//            if let existing = try User.query().filter("twitter_id", credentials.uniqueID).first() {
//                user = existing
//            } else {
//                user = try User.register(credentials: credentials) as? User
//            }
//
//
//        /**
//         Authenticates via API Keys
//         */
//        case let credentials as APIKey:
//            user = try User.query()
//                .filter("api_key_id", credentials.id)
//                .filter("api_key_secret", credentials.secret)
//                .first()
//
//        default:
//            throw UnsupportedCredentialsError()
//        }
//
//        guard let u = user else {
//            throw IncorrectCredentialsError()
//        }
//
//        return u
//    }
//
//    // This shouldn't be used because a user can be created with the above method instead
//    static func register(credentials: Credentials) throws -> Auth.User {
//        var newUser: User
//
//        switch credentials {
//        case let credentials as UsernamePassword:
//            newUser = User(credentials: credentials)
//        case let credentials as DigitsAccount:
//            newUser = User(credentials: credentials)
//        default:
//            throw Abort(.badRequest, reason: "Invalid credentials.")
//        }
//
//        if try User.query().filter("username", newUser.username).first() == nil {
//            try newUser.save()
//            return newUser
//        } else {
//            throw AccountTakenError()
//        }
//    }
//}

extension Request {
    func user() throws -> User {
        guard let user = auth.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        return user
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            super.prepare(self, with: builder)

            builder.string("username")
            builder.string("password")

            builder.string("access_token")
            builder.string("api_key_id")
            builder.string("api_key_secret")

            builder.string("twitter_id")

            builder.string("digits_id")
            builder.string("phone_number")

            builder.string("first_name")
            builder.string("last_name")
            builder.string("email")
            builder.string("image_url")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Merge

extension User {
    func merge(updates: User) {
        super.merge(updates: updates)
        username                = updates.username
        password                = updates.password

        accessToken             = updates.accessToken
        apiKeyID                = updates.apiKeyID
        apiKeySecret            = updates.apiKeySecret

        twitterID               = updates.twitterID

        digitsID                = updates.digitsID
        phoneNumber             = updates.phoneNumber

        firstName               = updates.firstName
        lastName                = updates.lastName
        email                   = updates.email
        imageURL                = updates.imageURL
    }
}

// MARK: Relationships

extension User {
    var groups: Siblings<User, Group, Pivot<User, Group>> {
        return siblings()
    }

    var points: Children<User, Score> {
        return children()
    }

    var userTasks: Children<User, UserTask> {
        return children()
    }

    var userRewards: Children<User, UserReward> {
        return children()
    }
}



