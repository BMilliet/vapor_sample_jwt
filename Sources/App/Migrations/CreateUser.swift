import Fluent
import Vapor

struct CreateUser: AsyncMigration {
    var name: String { "CreateUser" }

    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("role", .string, .required)
            .field("password_hash", .string, .required)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
