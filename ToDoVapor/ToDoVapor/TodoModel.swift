//
//  TodoModel.swift
//  ToDoVapor
//
//  Created by Cédric Bahirwe on 15/10/2022.
//

import Foundation

struct TodoModel: Identifiable, Codable {
    init(id: UUID = .init(), name: String) {
        self.id = id
        self.name = name
    }

    var id: UUID
    var name: String
}
