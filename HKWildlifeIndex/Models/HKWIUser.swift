
import Foundation
import SwiftUI
import os.log
import SwiftData

final class HKWIUser : Codable {
    var gid: String?
    var username: String
    var password: String?
    
    var pfp: String = ""
    var discovered: [String] = []
    var level: Int = 1
    var xp: Double = 0
    var photos : [Data] = []
    var friends : [String] = []
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.gid = nil
    }
    init(username: String, gid: String) {
        self.username = username
        self.gid = gid
        self.password = nil
    }
    init() {
        self.username = "Local User"
        self.gid = nil
        self.password = nil
    }
}
func jsonEncode<T : Codable>(_ object: T) -> [String : Any]? {
    do {
        let jsonData = try JSONEncoder().encode(object)
        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        return dictionary
    }
    catch {
        Logger().error("\(error.localizedDescription)")
    }
    return nil
}

