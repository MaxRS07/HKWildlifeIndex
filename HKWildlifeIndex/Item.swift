//
//  Item.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 26/3/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}