import Vapor
import Fluent
import VaporMySQL
import Auth
import Routing
import HTTP


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

let userController = UserController()
let groupController = GroupController()
let taskController = TaskController()
let rewardController = RewardController()

let api: RouteGroup  = drop.grouped("api")
let v1: RouteGroup = api.grouped("v1")
let authenticated: RouteGroup = v1.grouped(TokenAuthMiddleware())

api.get { req in try JSON(node: ["Welcome to the Karma API"]) }

v1.get { req in try JSON(node: ["version": "1"]) }


// /login
v1.post("login", handler: userController.login)


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
