import HTTP
import Fluent


public class TokenAuthMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let _ = try request.user()

        return try next.respond(to: request)
    }
}
