import Vapor

func routes(_ app: Application) throws {
    let basePath: PathComponent = "todo-lists"

    app.group(basePath) { todos in
        // POST /users
        todos.post { req in
            try req.content
                .decode(TodoList.self)
                .save(on: req.db)
                .transform(to: Response(status: .created))
        }

        // GET /users
        todos.get { req in
            try await TodoList
                .query(on: req.db)
                .all()
                .get()
        }

        // POST /users/:todoID
        todos.get(":todoID") { req -> EventLoopFuture<TodoList> in
            TodoList.find(req.parameters.get("todoID"), on: req.db)
                .unwrap(or: Abort(.notFound))
        }

        // DELETE /users:/todoID
        todos.delete(":todoID") { req -> EventLoopFuture<HTTPStatus> in
            return TodoList.find(req.parameters.get("todoID"), on: req.db)
                .unwrap(or: Abort(.notFound))
                .flatMap { todo in
                    todo.delete(on: req.db)
                        .transform(to: .noContent)
                }
        }

        // PUT /users:/todoID
        todos.put(":todoID") { req -> EventLoopFuture<TodoList> in
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
}
