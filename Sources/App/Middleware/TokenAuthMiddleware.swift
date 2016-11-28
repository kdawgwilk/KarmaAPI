import Auth
import HTTP

public class TokenAuthMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let accessToken = request.auth.header?.bearer {
            try? request.auth.login(accessToken, persist: false)
        }

        return try next.respond(to: request)
    }
}



