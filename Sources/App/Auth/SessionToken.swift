import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {

    // Constants
    var expirationTime: TimeInterval = 60 * 15

    // Token Data
    var expiration: ExpirationClaim

    // Custom data.
    var role: Role.RawValue
    var userName: String
    var userId: UUID

    init(userId: UUID, role: Role.RawValue, userName: String) {
        self.userId = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
        self.role = role
        self.userName = userName
    }

    init(with user: User) throws {
        self.userId = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
        self.role = user.role
        self.userName = user.email
    }


    // Run any additional verification logic beyond
    // signature verification here.
    // Since we have an ExpirationClaim, we will
    // call its verify method.
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}

struct ClientTokenResponse: Content {
    var token: String
}
