import Vapor
import Fluent
import VaporMySQL
import Auth
import Routing
import HTTP
import Foundation
import Turnstile
import TurnstileWeb
import TurnstileCrypto


let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)

drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")

drop.preparations = [
    User.self,
    Group.self,
    Task.self,
    Reward.self,
    UserTask.self,
    UserReward.self,
    Score.self,
    Pivot<User, Group>.self,
]

let authenticate = ProtectMiddleware(error:
    Abort.custom(status: .forbidden, message: "Not authorized.")
)

let userController = UserController()
let groupController = GroupController()
let taskController = TaskController()
let rewardController = RewardController()

let api: RouteGroup  = drop.grouped("api")
let v1: RouteGroup = api.grouped("v1")
let authenticated: RouteGroup = v1.grouped(authenticate)

api.get { req in try JSON(node: ["Welcome to the Karma API"]) }

v1.get { req in try JSON(node: ["version": "1"]) }


/**
 If Digits Auth is configured, let's add /login/digits
 to configure add a `digits.json` file inside the `Config/secrets` folder with this format:
 ```
 {
 "consumerKey": "<key goes here>",
 "consumerSecret": "<secret goes here>"
 }

 ```
 */
if let consumerKey = drop.config["digits", "consumerKey"]?.string {
    let digits = Digits(consumerKey: consumerKey)
//    drop.get("login", "digits", handler: userController.login)
    v1.post("login", "digits") { request in
        var credentials: Credentials?
        
        if let urlString = request.headers["X-Auth-Service-Provider"],
           let url = URL(string: urlString),
           let authHeader = request.headers["X-Verify-Credentials-Authorization"] {

            credentials = OAuthEcho(requestURL: url, authorizationHeader: authHeader)
            let account = try digits.authenticate(credentials: credentials!) as! DigitsAccount
            try request.auth.login(account)
            
        } else if let accessToken = request.headers["Authorization"] {
            try request.auth.login(AccessToken(string: accessToken))
        } else {
            throw Abort.custom(status: .unauthorized, message: "Failed to login")
        }

        return try request.auth.user() as! ResponseRepresentable
    }

} else {
    v1.post("login", "digits") { request in
        return "You need to configure Digits Login first!"
    }
}

// /users
authenticated.resource("users", userController)


// /groups
authenticated.resource("groups", groupController)
// /groups/:id/score
authenticated.get("groups", Group.self, "score", handler: groupController.score)


// /tasks/:id
authenticated.resource("tasks", taskController)
// /tasks/:id/begin
authenticated.post("tasks", Task.self, "begin", handler: taskController.begin)
// /tasks/:id/mark-completed
authenticated.post("tasks", Task.self, "mark-completed", handler: taskController.markCompleted)


// /rewards/:id
authenticated.resource("rewards", rewardController)
// /rewards/:id/claim
authenticated.post("rewards", Reward.self, "claim", handler: rewardController.claim)
// /rewards/:id/mark-recieved
authenticated.post("rewards", Reward.self, "mark-recieved", handler: rewardController.markRecieved)



drop.run()
