//
//  Entity+Extensions.swift
//  KarmaAPI
//
//  Created by Kaden Wilkinson on 11/10/16.
//
//

import Fluent

extension Entity {
    static func find(by id: NodeRepresentable) throws -> Self? {
        return try find(id)
    }
}
