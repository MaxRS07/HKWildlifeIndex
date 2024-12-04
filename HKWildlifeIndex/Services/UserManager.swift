import Foundation
import SwiftUI
import GoogleSignIn
import os.log
import FirebaseFirestore
import BCrypt

enum SignInError : Error {
    case authFailed(description: String)
    case other
}
class UserManager : ObservableObject {
    @Published var hkwiUser : HKWIUser?
    @Published var gidUser : GIDGoogleUser?
    @Published var localUser : HKWIUser
    @Published var forceID : UUID = UUID()
    
    typealias ExistingUser = Bool
    
    public var loggedIn : Bool {
        return hkwiUser != nil
    }
    public var currentUser : HKWIUser {
        return loggedIn ? hkwiUser! : localUser
    }
    
    init(hkwiUser: HKWIUser? = nil, gidUser: GIDGoogleUser? = nil) {
        self.hkwiUser = hkwiUser
        self.gidUser = gidUser
        if let user = UserDefaults.standard.object(forKey: "savedUser") as? HKWIUser {
            localUser = user
        } else {
            localUser = HKWIUser()
        }
    }
    public func refresh() {
        forceID = UUID()
    }
    public func save() {
        
    }
    public func findUser(gid: String) async -> HKWIUser? {
        let users = Firestore.firestore().collection("users")
        let query = users.whereField("gid", isEqualTo: gid)
        do {
            if let doc = try await query.getDocuments().documents.first?.data(as: HKWIUser.self) as? HKWIUser {
                return doc
            }
        } catch {
            Logger().error("\(error.localizedDescription)")
            return nil
        }
        return nil
    }
    public func signIn() async throws {
        let users = Firestore.firestore().collection("users")
        guard let gid = gidUser?.userID else {throw SignInError.authFailed(description: "Google user not signed in")}
        if let doc = await findUser(gid: gid) {
            hkwiUser = doc
        } else {
            throw SignInError.authFailed(description: "User with specified GID does not exist")
        }
    }
    public func signIn(username: String, password: String) async throws {
        let users = Firestore.firestore().collection("users")
        let query = users.whereField("username", isEqualTo: username)
        do {
            if let doc = try await query.getDocuments().documents.first?.data(as: HKWIUser.self) as? HKWIUser {
                if SecurityManager().verify(password, hashedPassword: doc.password ?? "") {
                    DispatchQueue.main.async { [weak self] in
                        self?.hkwiUser = doc
                    }
                } else {
                    throw SignInError.authFailed(description: "Incorrect Password")
                }
            } else {
                registerUser(username, password)
            }
        } catch {
            throw error
        }
    }
    public func googleSignIn() async throws -> ExistingUser {
        if let vc = await (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
                self.gidUser = result.user
                if let gid = gidUser?.userID {
                    return ((await findUser(gid: gid)) != nil)
                }
            }
            catch {
                throw error
            }
        }
        return false
    }
    public func getGoogleHKWIUser(username: String) async throws {
        let users = Firestore.firestore().collection("users")
        if let gid = gidUser?.userID {
            let query = users.whereField("gid", isEqualTo: gid)
            do {
                if let doc = try await query.getDocuments().documents.first?.data(as: HKWIUser.self) {
                    DispatchQueue.main.async { [weak self] in
                        self?.hkwiUser = doc
                    }
                } else {
                    registerGoogleUser(username: username)
                    try await signIn()
                }
            } catch {
                throw SignInError.authFailed(description: error.localizedDescription)
            }
        } else {
            throw SignInError.authFailed(description: "IDK what happened")
        }
    }
    private func registerGoogleUser(username: String) {
        guard let gid = gidUser?.userID else {return}
        let users = Firestore.firestore().collection("users")
        let user = HKWIUser(username: username, gid: gid)
        let userData = jsonEncode(user)!
        users.addDocument(data: userData)
    }
    private func registerUser(_ username: String, _ password: String) {
        let users = Firestore.firestore().collection("users")
        let user = HKWIUser(username: username, password: password)
        let userData = jsonEncode(user)!
        users.addDocument(data: userData)
    }
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
        hkwiUser = nil
    }
}
