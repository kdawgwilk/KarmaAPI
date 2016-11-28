import Foundation

// Vapor
import HTTP
import Vapor

// Authentication
import Turnstile
import TurnstileWeb
import TurnstileCrypto


struct AuthController {
    var realm: Realm?

    init(realm: Realm? = nil) {
        self.realm = realm
    }

    /// Currently only supports Digits auth
    ///
    /// - Parameter request: Passed from Vapor
    /// - Returns: Successful login message
    /// - Throws: An unauthorized error
    func login(request: Request) throws -> ResponseRepresentable {
        guard let digits = realm else {
            throw Abort.custom(status: .unauthorized, message: "AuthController has no realm")
        }
        var credentials: Credentials?

        guard
            let urlString = request.headers["X-Auth-Service-Provider"],
            let url = URL(string: urlString),
            let authHeader = request.headers["X-Verify-Credentials-Authorization"],
            let oauthParams = OAuthParameters(header: authHeader)
        else {
            throw Abort.custom(status: .unauthorized, message: "Bad Digits headers")
        }

        credentials = OAuthEcho(authServiceProvider: url, oauthParameters: oauthParams)
        let account = try digits.authenticate(credentials: credentials!) as! DigitsAccount
        try request.auth.login(account)

        return try request.auth.user() as! ResponseRepresentable
    }
}
