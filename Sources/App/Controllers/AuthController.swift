import Foundation

// Vapor
import HTTP
import Vapor

// Authentication
import Turnstile
import TurnstileWeb
import TurnstileCrypto


struct AuthController {
    var digits: Digits?
//    var twitter: Twitter?

    init(digits: Digits? = nil) { //, twitter: Twitter? = nil) {
        self.digits = digits
//        self.twitter = twitter
    }

    /// Digits auth handler
    ///
    /// - Parameter request: Passed from Vapor
    /// - Returns: Successful login message
    /// - Throws: An unauthorized error
    func loginDigits(request: Request) throws -> ResponseRepresentable {
        guard let digits = digits else {
            throw Abort(.unauthorized, reason: "AuthController has no digits realm")
        }

        guard
            let urlString = request.headers["X-Auth-Service-Provider"],
            let url = URL(string: urlString),
            let authHeader = request.headers["X-Verify-Credentials-Authorization"],
            let oauthParams = OAuthParameters(header: authHeader)
        else {
            return request.auth.authenticated(User.self)!
//            throw Abort.custom(status: .unauthorized, message: "Bad Digits headers")
        }

        let credentials: Credentials? = OAuthEcho(authServiceProvider: url, oauthParameters: oauthParams)
        let account = try digits.authenticate(credentials: credentials!) as! DigitsAccount
//        try request.auth.login(account)

        return request.auth.authenticated(User.self)!
    }

    /// Twitter auth handler
    ///
    /// - Parameter request: Passed from Vapor
    /// - Returns: Successful login message
    /// - Throws: An unauthorized error
//    func loginTwitter(request: Request) throws -> ResponseRepresentable {
//        guard let twitter = twitter else {
//            throw Abort(.unauthorized, reason: "AuthController has no twitter realm")
//        }
//
//        guard
//            let urlString = request.headers["X-Auth-Service-Provider"],
//            let url = URL(string: urlString),
//            let authHeader = request.headers["X-Verify-Credentials-Authorization"],
//            let oauthParams = OAuthParameters(header: authHeader)
//            else {
//                throw Abort(.unauthorized, reason: "Bad Twitter headers")
//        }
//
//        let credentials: Credentials? = OAuthEcho(authServiceProvider: url, oauthParameters: oauthParams)
//        let account = try twitter.authenticate(credentials: credentials!) as! TwitterAccount
//        try request.auth.login(account)
//
//        return try request.auth.user() as! ResponseRepresentable
//    }

}
