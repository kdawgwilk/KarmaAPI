import Auth
import HTTP

public class BasicAuthMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let apiKey = request.auth.header?.basic {
            try? request.auth.login(apiKey, persist: false)
        }

        return try next.respond(to: request)
    }
}

