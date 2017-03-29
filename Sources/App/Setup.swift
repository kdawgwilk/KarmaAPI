import Foundation

// Vapor
@_exported import Vapor
import HTTP
import Routing

// Database
import FluentProvider
import MySQLProvider

// Authentication
import AuthProvider
import TurnstileWeb

 
public func setup(_ drop: Droplet) throws {
    try setupProviders(drop)
    try setupModels(drop)
    try setupRoutes(drop)
    try setupResources(drop)
}

private func setupProviders(_ drop: Droplet) throws {
    let fluent = FluentProvider.Provider()
    try drop.addProvider(fluent)

    let auth = AuthProvider.Provider()
    try drop.addProvider(auth)
}

private func setupMiddleware(_ drop: Droplet) throws {
//	drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")
//	drop.addConfigurable(middleware: PasswordAuthenticationMiddleware<User>(), name: "basic-auth")
//	drop.addConfigurable(middleware: TokenAuthenticationMiddleware<User>(), name: "token-auth")
}

private func setupModels(_ drop: Droplet) throws {
    let preparations: [Preparation.Type] = [
        User.self,
        Group.self,
        Task.self,
        Reward.self,
        UserTask.self,
        UserReward.self,
        Score.self,
        Pivot<User, Group>.self,
    ]

    drop.preparations += preparations
}

private func setupRoutes(_ drop: Droplet) throws {

//	let authenticate = ProtectMiddleware(error:
//	    Abort.custom(status: .forbidden, message: "Not authorized.")
//	)

    let authenticate: [Middleware] = [
        PasswordAuthenticationMiddleware<User>(),
        TokenAuthenticationMiddleware<User>(),
    ]

	let userController              = UserController()
	var authController              = AuthController()
	let groupController             = GroupController()
	let taskController              = TaskController()
	let rewardController            = RewardController()

    let api            : RouteBuilder = drop.grouped("api")
    let v1             : RouteBuilder =  api.grouped("v1")
    let authenticated = v1
//	let authenticated  : RouteBuilder =   v1.grouped(authenticate)

	api.get { req in try JSON(node: ["ping": "pong"]) }
	v1.get  { req in try JSON(node: ["version": 1]) }


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
	    authController.digits = Digits(consumerKey: consumerKey)
	    authenticated.get("login", "digits", handler: authController.loginDigits)
	} else {
	    authenticated.get("login", "digits") { request in
	        return "You need to configure Digits Login first!"
	    }
	}

	/**
	 If Twitter Auth is configured, let's add /login/digits
	 to configure add a `twitter.json` file inside the `Config/secrets` folder with this format:
	 ```
	 {
	     "consumerKey": "<key goes here>",
         "consumerSecret": "<secret goes here>"
	 }
	 ```
	 */
//	if let consumerKey = drop.config["twitter", "consumerKey"]?.string {
//	    authController.twitter = Twitter(consumerKey: consumerKey)
//	    authenticated.get("login", "twitter", handler: authController.loginTwitter)
//	} else {
//	    authenticated.get("login", "twitter") { request in
//	        return "You need to configure Twitter Login first!"
//	    }
//	}

	/// /users/:id
	authenticated.resource("users", userController)


	/// /groups/:id
	authenticated.resource("groups", groupController)
	/// /groups/:id/score
//	authenticated.get("groups", Group.self, "score", handler: groupController.score)
    authenticated.get("groups", Group.identifier, "score", handler: groupController.score)


	/// /tasks/:id
	authenticated.resource("tasks", taskController)
	/// /tasks/:id/begin
//	authenticated.post("tasks", Task.self, "begin", handler: taskController.begin)
    authenticated.post("tasks", Task.identifier, "begin", handler: taskController.begin)

	/// /tasks/:id/mark-completed
//	authenticated.post("tasks", Task.self, "mark-completed", handler: taskController.markCompleted)
    authenticated.post("tasks", Task.identifier, "mark-completed", handler: taskController.markCompleted)


	/// /rewards/:id
	authenticated.resource("rewards", rewardController)
	/// /rewards/:id/claim
//	authenticated.post("rewards", Reward.self, "claim", handler: rewardController.claim)
    authenticated.post("rewards", Reward.identifier, "claim", handler: rewardController.claim)
	/// /rewards/:id/mark-recieved
//	authenticated.post("rewards", Reward.self, "mark-recieved", handler: rewardController.markRecieved)
	authenticated.post("rewards", Reward.identifier, "mark-recieved", handler: rewardController.markRecieved)
}

private func setupResources(_ drop: Droplet) throws {

}
