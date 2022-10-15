import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, wald!"
    }

    app.post("todo-lists") { req in
        try req.content
            .decode(TodoList.self)
            .save(on: req.db)
            .transform(to: Response(status: .created))
    }

    app.get("todo-lists") { req in
        try await TodoList
            .query(on: req.db)
            .all()
            .get()
    }

    app.get("todo-lists", "lists", ":todoID") { req -> EventLoopFuture<TodoList> in
        TodoList.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    app.delete("todo-lists", ":todoID") { req -> EventLoopFuture<HTTPStatus> in
        print(req.parameters)
        return TodoList.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { todo in
                todo.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    app.put("todo-lists", ":todoID") { req -> EventLoopFuture<TodoList> in
      let updatedTodo = try req.content.decode(TodoList.self)
      return TodoList.find(
          req.parameters.get("todoID"),
          on: req.db)
        .unwrap(or: Abort(.notFound)).flatMap { todo in
          todo.name = updatedTodo.name
          return todo.save(on: req.db).map {
            todo
          }
      }
    }

}
