import Vapor
import FluentProvider
import Foundation


class BaseModel: Model {
    let storage = Storage()

    var createdOn: String

    // MARK: General Initializer

    init() {
        createdOn = String(Int(Date().timeIntervalSince1970.rounded()))
    }

    // MARK: Data Initializers

    required convenience init(row: Row) throws {
        try self.init(node: row)
    }

    required convenience init(json: JSON) throws {
        try self.init(node: json)
    }

    required init(node: Node) throws {
        createdOn = try node.get("created_on")
        id = try node.get(idKey)
    }

    // MARK: Data Constructors

    func makeRow() throws -> Row {
        return try makeNode(in: rowContext).converted()
    }

    func makeJSON() throws -> JSON {
        return try makeNode(in: jsonContext).converted()
    }

    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(idKey, id)
        try node.set("created_on", createdOn)
        return node
    }

    func merge(updates: BaseModel) {
        id = updates.id ?? id
        createdOn = updates.createdOn
    }
}

extension BaseModel {

    static func prepare<T: Entity>(_ entity: T.Type, with builder: Creator) {
        builder.id(for: entity)
        builder.string("created_on")
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

