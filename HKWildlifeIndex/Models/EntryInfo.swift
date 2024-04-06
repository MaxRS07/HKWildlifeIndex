//
//  EntryInfo.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 23/3/2024.
//

import Foundation
import SwiftUI

public struct Classification {
    var domain: Domain
    var kingdom: Kingdom
    var phylum: Phylum
    var subphylum: Subphylum
    var classification: String
    var order: String
    var infraorder: String
    var genus: String
    var family: String
    
    init(domain: Domain, kingdom: Kingdom, phylum: Phylum, subphylum: Subphylum, classification: String, order: String, infraorder: String, family: String, genus: String) {
        self.domain = domain
        self.kingdom = kingdom
        self.phylum = phylum
        self.subphylum = subphylum
        self.classification = classification
        self.order = order
        self.infraorder = infraorder
        self.family = family
        self.genus = genus
    }
    func set(domain: Domain?, kingdom: Kingdom?, phylum: Phylum?, subphylum: Subphylum?, classification: String?, order: String?, infraorder: String?, family: String?, genus: String?) -> Classification {
        return Classification(domain: domain ?? self.domain,
                              kingdom: kingdom ?? self.kingdom,
                              phylum: phylum ?? self.phylum,
                              subphylum: subphylum ?? self.subphylum,
                              classification: classification ?? self.classification,
                              order: order ?? self.order,
                              infraorder: infraorder ?? self.infraorder,
                              family: family ?? self.family,
                              genus: genus ?? self.genus)
    }
    static func insecta(order: String, infraorder: String, family : String, genus: String) -> Self {
        return Classification(domain: .Eukaryota, kingdom: .animalia, phylum: .arthropoda, subphylum: .none, classification: "insecta", order: order, infraorder: infraorder, family: family, genus: genus)
    }
    static func aranae(infraorder: String, family: String, genus: String) -> Self { Classification(domain: .Eukaryota, kingdom: .animalia, phylum: .arthropoda, subphylum: .chelicerata, classification: "arachnida", order: "aranae", infraorder: infraorder, family: family, genus: genus)
    }
    
    static func nymphalidae(genus: String) -> Self { .insecta(order: "lepidoptera", infraorder: "", family: "nymphalidae", genus: genus)
    }
    static func mammalia(order: String, infraorder: String, family: String, genus: String) -> Self {
        Classification(domain: .Eukaryota, kingdom: .animalia, phylum: .chordata, subphylum: .none, classification: "mammalia", order: order, infraorder: infraorder, family: family, genus: genus)
    }
    static func ant(genus: String) -> Self {
        return .insecta(order: "Hymenoptera", infraorder: "", family: "Formicidae", genus: genus)
    }
}
enum Domain {
    case bacteria
    case Archaea
    case Eukaryota
}
enum Kingdom {
    case animalia
    case plantae
    case fungi
    case protista
    case eubacteria
    case archaebacteria
}
enum Phylum {
    case porifera
    case cnidaria
    case platyhelminthe
    case nematoda
    case annelida
    case arthropoda
    case mollusca
    case echinodermata
    case chordata
}
enum Subphylum {
    case vertebrates
    case tunicates
    case cephalochordates
    case arthropods
    case annelids
    case mollusks
    case echinoderms
    case hemichordates
    case chordates
    case nematodes
    case platyhelminthes
    case cnidarians
    case poriferans
    case ctenophores
    case placozoans
    case chelicerata
    case none
}
enum Rarity : CaseIterable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    case mythic
}
extension Rarity {
    var textView : RarityViewBuilder {
        switch self {
        case .common:
            return .init(name: "Common", color: .gray, background: 0.4)
        case .uncommon:
            return .init(name: "Uncommon", color: .green, background: 0.6)
        case .rare:
            return .init(name: "Rare", color: .blue, background: 0.85)
        case .epic:
            return .init(name: "Epic", color: .purple, background: 0.6)
        case .legendary:
            return .init(name: "Legendary", color: .yellow, background: 0.8)
        case .mythic:
            return .init(name: "Mythic", color: .red, background: 0.65)
        }
    }
}
struct RarityViewBuilder {
    let name : String
    let color : Color
    let background : CGFloat

    init(name: String, color: Color, background: CGFloat) {
        self.name = name
        self.color = color
        self.background = background
    }
}
