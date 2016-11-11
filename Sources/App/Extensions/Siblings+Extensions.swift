import Vapor
import Fluent

extension Siblings where T: Model {
    func includes(_ item: T) throws -> Bool {
        return try filter("id", item.id!).all().count > 0
    }
}
