import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")

        users.get(use: self.index)
        users.post(use: self.create)
        
        users.group(":userID") { user in
            user.get(use: self.findById)
            //user.put(use: self.update) // TODO
            user.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func findById(req: Request) async throws -> UserDTO {
        let user = try await findUser(req: req)
        return user.toDTO()
    }

    @Sendable
    func create(req: Request) async throws -> UserDTO {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return user.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        let account = try await findUser(req: req)
        try await account.delete(on: req.db)
        return .noContent
    }

    private func findUser(req: Request) async throws -> User {
        guard let userID = req.parameters.get("userID"),
              let uuid = UUID(uuidString: userID) else {
            throw Abort(.badRequest, reason: "Invalid user ID format.")
        }

        guard let user = try await User.find(uuid, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }

        return user
    }
}
