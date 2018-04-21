//import FluentSQLite
import FluentPostgreSQL
//import FluentMySQL
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
//    try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())
//    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)
    
    // Configure a SQLite database
//    let sqlite: SQLiteDatabase
//    if env.isRelease {
//        /// Create file-based SQLite db using $SQLITE_PATH from process env
//        sqlite = try SQLiteDatabase(storage: .file(path: Environment.get("SQLITE_PATH")!))
//    } else {
//        /// Create an in-memory SQLite database
//        sqlite = try SQLiteDatabase(storage: .memory)
//    }

//    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
//                                                  username: "vapor",
//                                                  database: "vapor",
//                                                  password: "password")
//    let database = PostgreSQLDatabase(config: databaseConfig)
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                  username: username,
                                                  database: databaseName,
                                                  password: password)
    let database = PostgreSQLDatabase(config: databaseConfig)
    
//    let databaseConfig = MySQLDatabaseConfig(hostname: "localhost",
//                                             port: 3306,
//                                             username: "vapor",
//                                             password: "password",
//                                             database: "vapor")
//    let database = MySQLDatabase(config: databaseConfig)
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabaseConfig()
//    databases.add(database: sqlite, as: .sqlite)
    databases.add(database: database, as: .psql)
//    databases.add(database: database, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
//    migrations.add(model: Acronym.self, database: .sqlite)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
//    migrations.add(model: Acronym.self, database: .mysql)
    services.register(migrations)

}
