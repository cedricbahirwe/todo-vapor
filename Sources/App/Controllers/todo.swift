//
//  File.swift
//  
//
//  Created by Cédric Bahirwe on 15/10/2022.
//

import Fluent
import Vapor

extension FieldKey {
  static let name: FieldKey = "name"
}

final class TodoList: Model {
  static let schema = "todo-lists"
  @ID(key: .id)
  var id: UUID?
  @Field(key: .name)
  var name: String
}

extension TodoList: Content {}
