import Authentication
import Leaf
import Fluent
import FluentMySQL
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here

    // Register Auth
    try services.register(AuthenticationProvider())

    // Register Leaf with Vapor
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Register Fluent-MySQL with Vapor
    try services.register(FluentMySQLProvider())
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: "127.0.0.1",
        port: 3306,
        username: "nick",
        password: Environment.get("MYSQL_PASSWORD"),
        database: "mcstutor"
    )
    services.register(mysqlConfig)
    
    // Register Migrations
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Tutor.self, database: .mysql)
    migrationConfig.add(model: TutoringEntry.self, database: .mysql)
    services.register(migrationConfig)
    
    // register Middleware to use Sessions
    var middlewareConfig = MiddlewareConfig.default()
    middlewareConfig.use(SessionsMiddleware.self)
    middlewareConfig.use(FileMiddleware.self)
    services.register(middlewareConfig)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
