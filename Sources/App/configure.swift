import Vapor
import Fluent
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(.sqlite(.memory), as: .sqlite) // Register database
    app.migrations.add(CreateTodoListMigration(), to: .sqlite) // Add migration

    try app.autoMigrate().wait() // Needed for in-memory database.
    // register routes
    try routes(app)
}
