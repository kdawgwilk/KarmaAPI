import Vapor
import Fluent
import HTTP
import Auth
import Foundation
import Turnstile
import TurnstileWeb
import TurnstileCrypto
import Hash


final class User: BaseModel, Model {

    // Required properties
    // Example ID: 723205272156524544
    var username: String
    var password = ""
    var digitsID = ""
    var phoneNumber = ""
    var accessToken = URandom().secureToken
    var apiKeyID = URandom().secureToken
    var apiKeySecret = URandom().secureToken

    var firstName = ""
    var lastName = ""
    var email = ""
    var imageURL = ""

    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
        super.init()
    }

    init(credentials: DigitsAccount) {
        self.username = "digit" + credentials.uniqueID
        self.digitsID = credentials.uniqueID
        super.init()
    }

    /**
     Initializer for Fluent
     */
    override init(node: Node, in context: Context) throws {
        username        = try node.extract("username")
        password        = try node.extract("password")

        accessToken     = try node.extract("access_token")
        apiKeyID        = try node.extract("api_key_id")
        apiKeySecret    = try node.extract("api_key_secret")

        digitsID        = try node.extract("digits_id")
        phoneNumber     = try node.extract("phone_number")

        firstName       = try node.extract("first_name")
        lastName        = try node.extract("last_name")
        email           = try node.extract("email")
        imageURL        = try node.extract("image_url")

        try super.init(node: node, in: context)
    }

    /**
     Serializer for Fluent
     */
    override func makeNode(context: Context) throws -> Node {
        var node = [String: NodeRepresentable]()

        node["id"]              = id
        node["created_on"]      = createdOn

        node["username"]        = username
        node["password"]        = password

        node["access_token"]    = accessToken
        node["api_key_id"]      = apiKeyID
        node["api_key_secret"]  = apiKeySecret

        node["digits_id"]       = digitsID
        node["phone_number"]    = phoneNumber
        
        node["first_name"]      = firstName
        node["last_name"]       = lastName
        node["email"]           = email
        node["image_url"]       = imageURL

        return try Node(node: node)
    }

    func groups() throws -> Siblings<Group> {
        return try siblings()
    }
}

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: User?
        
        switch credentials {
        /**
         Fetches a user, and checks that the password is present, and matches.
         */
        case let credentials as UsernamePassword:
            let fetchedUser = try User.query()
                .filter("username", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }

        /**
         Fetches the user by session ID. Used by the Vapor session manager.
         */
        case let credentials as Identifier:
            user = try User.find(credentials.id)

        /**
         Authenticates via AccessToken
         */
        case let credentials as AccessToken:
            user = try User.query().filter("access_token", credentials.string).first()

        /**
         Fetches the user by Digits ID. If the user doesn't exist, autoregisters it.
         */
        case let credentials as DigitsAccount:
            if let existing = try User.query().filter("digits_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try User.register(credentials: credentials) as? User
            }

        /**
         Authenticates via API Keys
         */
        case let credentials as APIKey:
            user = try User.query()
                .filter("api_key_id", credentials.id)
                .filter("api_key_secret", credentials.secret)
                .first()

        default:
            throw UnsupportedCredentialsError()
        }

        guard let u = user else {
            throw IncorrectCredentialsError()
        }

        return u
    }

    // This shouldn't be used because a user can be created with the above method instead
    static func register(credentials: Credentials) throws -> Auth.User {
        var newUser: User

        switch credentials {
        case let credentials as UsernamePassword:
            newUser = User(credentials: credentials)
        case let credentials as DigitsAccount:
            newUser = User(credentials: credentials)
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }

        if try User.query().filter("username", newUser.username).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }
}

extension Request {
    func user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
        }
        return user
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users") { user in
            prepare(model: user)
            user.string("username")
            user.string("password")

            user.string("access_token")
            user.string("api_key_id")
            user.string("api_key_secret")

            user.string("digits_id")
            user.string("phone_number")

            user.string("first_name")
            user.string("last_name")
            user.string("email")
            user.string("image_url")
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
        username = updates.username
        password = updates.password

        accessToken = updates.accessToken
        apiKeyID = updates.apiKeyID
        apiKeySecret = updates.apiKeySecret

        digitsID = updates.digitsID
        phoneNumber = updates.phoneNumber

        firstName = updates.firstName
        lastName = updates.lastName
        email = updates.email
        imageURL = updates.imageURL
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



