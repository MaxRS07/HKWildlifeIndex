//
//  WildlifeEntry.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 23/3/2024.
//

import Foundation
import SwiftUI

public class WildlifeEntry : Identifiable {
    let name: String
    let latin: String
    let description: String
    
    let weight: String
    let size: String
    
    let classification: Classification
    
    let rarity : Rarity
    
    init(name: String, latin: String, description: String, weight: String, size: String, classification: Classification, rarity: Rarity) {
        self.name = name
        self.latin = latin
        self.description = description
        self.weight = weight
        self.size = size
        self.classification = classification
        self.rarity = rarity
    }
    var thumbnail : Image {
        return Image(uiImage: .init(named: self.name.replacingOccurrences(of: " ", with: "-") + "-0")!)
    }
}
public class WildlifeIndex : ObservableObject {
    public var entries : [WildlifeEntry] = [
        WildlifeEntry(name: "Golden Orb Weaver", latin: "Nephila pilipes", description: "The Golden Orb Weaver spider, commonly found in Southeast Asia, is a breathtaking arachnid renowned for its striking appearance and remarkable web-spinning abilities. With a body length averaging around 4-5 centimeters, the spider boasts a vibrant golden hue, which glistens in the sunlight, earning it its resplendent name. Its delicate legs are adorned with intricate black and yellow patterns, adding to its visual allure. One of the most captivating features of this species is its intricately woven orb-shaped web, which can stretch up to one meter in diameter and is meticulously laced with golden silk. This web serves as both a trap to ensnare unsuspecting insects and a shelter for the spider itself. The Golden Orb Weaver's diet primarily consists of flying insects, and its venom, although harmless to humans, effectively immobilizes its prey. This magnificent spider, with its striking appearance and masterful web-spinning abilities, stands as an emblematic creature of the enchanting biodiversity found in Southeast Asia's lush and diverse ecosystems.", weight: "Female 7g, Male 3g", size: "Female 30mm, Male 6mm", classification: .aranae(infraorder: "araneomorphae", family: "nephilidae", genus: "nephila"), rarity: .rare),
        WildlifeEntry(name: "Striped Blue Crow", latin: "Euploea mulciber", description: "Euploea mulciber, also known as the Striped Blue Crow or Mulciber Crow, is a captivating butterfly species found in various parts of Asia. With its dark wings adorned by broad white or pale yellow stripes, this butterfly showcases a mesmerizing contrast that catches the eye. The adult butterfly has a wingspan ranging from 60 to 70 millimeters, and its upper side features a deep black coloration with distinct white stripes, while the undersides are brownish with lighter bands and markings. Euploea mulciber adds a touch of elegance to its surroundings as it gracefully flutters through its natural habitats.", weight: "<1g", size: "Wingspan: 90-110mm", classification: .nymphalidae(genus: "euploea"), rarity: .uncommon),
        WildlifeEntry(name: "Chinese Pangolin", latin: "Manis pentadactyla", description: "The Chinese pangolin (Manis pentadactyla) is a species of pangolin native to various regions in China and surrounding countries. It is a unique and fascinating mammal known for its distinctive appearance and remarkable adaptations. Covered in overlapping scales made of keratin, the Chinese pangolin has a slender body, a long snout, and a prehensile tail, which it uses for climbing trees and digging burrows. As an insectivorous creature, it primarily feeds on ants and termites, using its long, sticky tongue to capture its prey. Unfortunately, the Chinese pangolin faces significant threats due to habitat loss, illegal hunting, and trafficking, making it critically endangered. Efforts are being made to protect and conserve this remarkable species and raise awareness about the importance of biodiversity conservation.", weight: "2-10kg", size: "31-48cm", classification: .mammalia(order: "pholidota", infraorder: "", family: "manidae", genus: "manus"), rarity: .mythic),
        WildlifeEntry(name: "Asian Needle Ant", latin: "Brachyponera chinensis", description: "The Asian needle ant (Pachycondyla chinensis) is one of the invasive ant species that has been reported. These ants are believed to have been introduced to the region through human activities, such as the transportation of goods and materials. In Hong Kong, they are known for their aggressive nature and ability to establish large colonies. Asian needle ants in Hong Kong primarily inhabit natural areas, including forests, grasslands, and wetlands. They construct nests in soil and leaf litter, and their presence can be particularly problematic in urban parks and gardens. Efforts are being made to monitor and manage the spread of these ants in order to minimize their impact on local ecosystems.", weight: "1-5mg", size: "8-12mm", classification: .ant(genus: "brachyponera"), rarity: .common),
        WildlifeEntry(name: "Wild Boar", latin: "Sus scrofa", description: "In Hong Kong, Sus scrofa, commonly known as the wild boar, represents a significant presence in the region's diverse wildlife. These large, omnivorous mammals inhabit the rural and forested areas, including country parks and nature reserves, that dot the territory. With their sturdy frames, muscular bodies, and distinctive curved tusks, wild boars are a robust species. Adult individuals can grow up to two meters in length and weigh between 100 to 200 kilograms. While generally avoiding urban areas, the expanding population of wild boars has led to occasional encounters with human settlements, necessitating efforts to manage and mitigate potential human-wildlife conflicts.", weight: "100-200kg", size: "1.5-2m", classification: .mammalia(order: "artiodactyla", infraorder: "", family: "suidae", genus: "sus"), rarity: .epic),
        WildlifeEntry(name: "Chinese White Dolphin", latin: "Sousa chinensis", description: "The Chinese white dolphin, also known as the pink dolphin, is a captivating marine mammal that inhabits the waters surrounding Hong Kong. Renowned for its unique and striking appearance, this dolphin species showcases a captivating pinkish hue on its skin, making it a cherished icon of the region's marine biodiversity. The Chinese white dolphin possesses a graceful and streamlined body, reaching lengths of up to 2.5 meters and weighing around 200 kilograms. Their playful and social nature is often witnessed as they gracefully leap and frolic in the waves, captivating observers with their acrobatic displays. Unfortunately, these dolphins face numerous challenges due to habitat loss, water pollution, and increased maritime traffic. Conservation efforts are crucial to safeguard the future of these enchanting creatures, ensuring that they continue to grace Hong Kong's coastal waters with their presence for generations to come.", weight: "", size: "~2.7m", classification: .mammalia(order: "artiodactyla", infraorder: "cetacea", family: "delphinidae", genus: "sousa"), rarity: .legendary)
    ]
}

