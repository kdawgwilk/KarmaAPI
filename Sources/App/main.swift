import Foundation

// Vapor
import HTTP
import Vapor
import Routing

// Database
import Fluent
import VaporMySQL

// Authentication
import Auth
import TurnstileWeb


let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)

drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")
drop.addConfigurable(middleware: BasicAuthMiddleware(), name: "basic-auth")
drop.addConfigurable(middleware: TokenAuthMiddleware(), name: "token-auth")

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

let userController      = UserController()
var authController      = AuthController()
let groupController     = GroupController()
let taskController      = TaskController()
let rewardController    = RewardController()

let api             : RouteGroup = drop.grouped("api")
let v1              : RouteGroup =  api.grouped("v1")
let authenticated   : RouteGroup =   v1.grouped(authenticate)

api.get { req in try JSON(node: ["Welcome to the Karma API"]) }
v1.get  { req in try JSON(node: ["version": "1"]) }


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
    authController.realm = Digits(consumerKey: consumerKey)
    v1.get("login", "digits", handler: authController.login)
} else {
    v1.get("login", "digits") { request in
        return "You need to configure Digits Login first!"
    }
}

/// /users/:id
authenticated.resource("users", userController)


/// /groups/:id
authenticated.resource("groups", groupController)
/// /groups/:id/score
authenticated.get("groups", Group.self, "score", handler: groupController.score)


/// /tasks/:id
authenticated.resource("tasks", taskController)
/// /tasks/:id/begin
authenticated.post("tasks", Task.self, "begin", handler: taskController.begin)
/// /tasks/:id/mark-completed
authenticated.post("tasks", Task.self, "mark-completed", handler: taskController.markCompleted)


/// /rewards/:id
authenticated.resource("rewards", rewardController)
/// /rewards/:id/claim
authenticated.post("rewards", Reward.self, "claim", handler: rewardController.claim)
/// /rewards/:id/mark-recieved
authenticated.post("rewards", Reward.self, "mark-recieved", handler: rewardController.markRecieved)


drop.run()
