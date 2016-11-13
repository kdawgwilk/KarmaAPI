import Vapor
import Fluent
import Foundation


class BaseModel {
    // Unfortunately doesn't support UUIDs yet
    var id: Node?

    // Used by Fluent internally, will be removed at some point
    var exists: Bool = false

    var createdOn: String

    init() {
        createdOn = String(Int(Date().timeIntervalSince1970.rounded()))
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        createdOn = try node.extract("created_on")
    }

    func makeNode(context: Context) throws -> Node {
        fatalError("Needs to overidden!")
    }

    func merge(updates: BaseModel) {
        id = updates.id ?? id
        createdOn = updates.createdOn
    }

    static func prepare(model: Schema.Creator) {
        model.id()
        model.string("created_on")
    }
}


extension BaseModel: Equatable {

    static func ==(lhs: BaseModel, rhs: BaseModel) -> Bool {
        return type(of: lhs) == type(of: rhs) && lhs.id == rhs.id
    }
}

//func ==<T: BaseModel>(lhs: T, rhs: T) -> Bool {
//    return lhs.id == rhs.id
//}

