import Vapor
import HTTP
import Auth


struct DigitsCredentials: Credentials {
    static let requestURLStringKey: HeaderKey = "X-Auth-Service-Provider"
    static let authorizationHeaderKey: HeaderKey = "X-Verify-Credentials-Authorization"
    private let requestURLString: String
    private let authorizationHeader: String
    let accessToken: AccessToken
    let digitsID: String
    let digitsIDInt: Int
    let phoneNumber: String
    let createdAt: String

    struct AccessToken {
        let secret: String
        let token: String
    }

    private init(requestURLString: String, authorizationHeader: String) throws {
        self.requestURLString = requestURLString
        self.authorizationHeader = authorizationHeader

        let response = try BasicClient.get(requestURLString, headers: ["Authorization": authorizationHeader])

        if response.status != .ok {
            throw Abort.custom(status: response.status, message: "Digits API returned \(response.status) code")
        }
        guard let json = response.json else {
            throw Abort.badRequest
        }

        print("Json: \(try json.serialize(prettyPrint: true).string)")

        guard let secret        = json["access_token"]?["secret"]?.string,
            let token           = json["access_token"]?["token"]?.string,
            let digitsID        = json["id_str"]?.string,
            let digitsIDInt     = json["id"]?.int,
            let phoneNumber     = json["phone_number"]?.string,
            let createdAt       = json["created_at"]?.string else {
                throw Abort.badRequest
        }
        self.accessToken = AccessToken(secret: secret, token: token)
        self.digitsIDInt = digitsIDInt
        self.digitsID = digitsID
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }

    init(headers: [HeaderKey: String]) throws {
        guard let requestURLString      = headers[DigitsCredentials.requestURLStringKey],
            let authorizationHeader   = headers[DigitsCredentials.authorizationHeaderKey] else {
                throw Abort.badRequest
        }
        try self.init(requestURLString: requestURLString, authorizationHeader: authorizationHeader)
    }
}
