

import Foundation
import BCrypt
import os.log

class SecurityManager {
    func hash(_ input: String) -> String? {
        do {
            let salt = try BCrypt.Salt()
            let hashedString = try BCrypt.Hash.make(message: input, with: salt)
            return hashedString.makeString()
        } catch {
            Logger().error("Error hashing string: \(error.localizedDescription)")
            return nil
        }
    }
    func verify(_ password: String, hashedPassword: String) -> Bool {
        do {
            return try BCrypt.Hash.verify(message: password, matches: hashedPassword)
        } catch {
            Logger().error("Error verifying password: \(error.localizedDescription)")
            return false
        }
    }
}
