import Fluent
import Vapor
import JWT

func routes(_ app: Application) throws {
    app.get { req async in
        "👋 Hello"
    }

    let passwordProtected = app.grouped(User.authenticator(), User.guardMiddleware())
    passwordProtected.post("login") { req async throws -> ClientTokenResponse in
        let user = try req.auth.require(User.self)
        let payload = try SessionToken(with: user)
        return ClientTokenResponse(token: try await req.jwt.sign(payload))
    }

    let secure = app.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware())
    secure.post("validateLoggedInUser") { req -> HTTPStatus in
        let sessionToken = try req.auth.require(SessionToken.self)
        print(sessionToken.userId)
        return .ok
    }

    // 🏄‍♂️ Register route controllers
    try app.register(collection: UserController())
}
