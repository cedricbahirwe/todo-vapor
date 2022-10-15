//
//  File.swift
//  
//
//  Created by Cédric Bahirwe on 15/10/2022.
//

import Fluent

struct CreateTodoListMigration: Migration {
    func prepare(on database: FluentKit.Database) -> EventLoopFuture<Void> {
        database
            .schema(TodoList.schema)
            .id()
            .field(.name, .string, .required)
            .create()
    }

    func revert(on database: FluentKit.Database) -> EventLoopFuture<Void> {
        database
            .schema(TodoList.schema)
            .delete()
    }
}
