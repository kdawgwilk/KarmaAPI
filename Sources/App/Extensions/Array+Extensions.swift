//
//  Array+Extensions.swift
//  KarmaAPI
//
//  Created by Kaden Wilkinson on 11/10/16.
//
//

import Vapor
import HTTP


extension Array where Element: Model {
    func toJSON() throws -> ResponseRepresentable {
        return try self.makeNode().converted(to: JSON.self)
    }
}

//extension Array: ResponseRepresentable {
//    public func makeResponse() throws -> Response {
//
//    }
//}
