
import Foundation
import SwiftUI

public struct Classification : Hashable {
    var domain: Domain
    var kingdom: Kingdom
    var phylum: Phylum
    var subphylum: Subphylum
    var classification: String
    var order: String
    var genus: String
    var family: String
    
    var list : [String] {
       return [
        domain.rawValue,
        kingdom.rawValue,
        phylum.rawValue,
        subphylum.rawValue,
        classification,
        order,
        genus,
        family,
        ]
    }
    static var hierarchy : [String] = [
        "Domain",
        "Kingdom",
        "Phylum",
        "Subphylum",
        "Classification",
        "Order",
        "Genus",
        "Family"
    ]
    
    init(domain: Domain, kingdom: Kingdom, phylum: Phylum, subphylum: Subphylum, classification: String, order: String, family: String, genus: String) {
        self.domain = domain
        self.kingdom = kingdom
        self.phylum = phylum
        self.subphylum = subphylum
        self.classification = classification
        self.order = order
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
                              family: family ?? self.family,
                              genus: genus ?? self.genus)
    }
    static func insecta(order: String, infraorder: String, family : String, genus: String) -> Self {
        return Classification(domain: .eukaryota, kingdom: .animalia, phylum: .arthropoda, subphylum: .none, classification: "insecta", order: order, family: family, genus: genus)
    }
    static func aranae(infraorder: String, family: String, genus: String) -> Self { Classification(domain: .eukaryota, kingdom: .animalia, phylum: .arthropoda, subphylum: .chelicerata, classification: "arachnida", order: "aranae", family: family, genus: genus)
    }
    
    static func nymphalidae(genus: String) -> Self { .insecta(order: "lepidoptera", infraorder: "", family: "nymphalidae", genus: genus)
    }
    static func mammalia(order: String, family: String, genus: String) -> Self {
        Classification(domain: .eukaryota, kingdom: .animalia, phylum: .chordata, subphylum: .none, classification: "mammalia", order: order, family: family, genus: genus)
    }
    static func ant(genus: String) -> Self {
        return .insecta(order: "Hymenoptera", infraorder: "", family: "Formicidae", genus: genus)
    }
    static func aves(order: String, family: String, genus: String) -> Self {
        return Classification(domain: .eukaryota, kingdom: .animalia, phylum: .chordata, subphylum: .none, classification: "Aves", order: order, family: family, genus: genus)
    }
}
enum Domain : String {
    case bacteria = "bacteria"
    case archaea = "archaea"
    case eukaryota = "eukaryota"
}
enum Kingdom : String {
    case animalia = "animalia"
    case plantae = "plantae"
    case fungi = "fungi"
    case protista = "protista"
    case eubacteria = "eubacteria"
    case archaebacteria = "archaebacteria"
}
enum Phylum : String {
    case porifera = "porifera"
    case cnidaria = "cnidaria"
    case platyhelminthe = "platyhelminthe"
    case nematoda = "nematoda"
    case annelida = "annelida"
    case arthropoda = "arthropoda"
    case mollusca = "mollusca"
    case echinodermata = "echinodermata"
    case chordata = "chordata"
}
enum Subphylum : String {
    case vertebrates = "vertebrates"
    case tunicates = "tunicates"
    case cephalochordates = "cephalochordates"
    case arthropods = "arthropods"
    case annelids = "annelids"
    case mollusks = "mollusks"
    case echinoderms = "echinoderms"
    case hemichordates = "hemichordates"
    case chordates = "chordates"
    case nematodes = "nematodes"
    case platyhelminthes = "platyhelminthes"
    case cnidarians = "cnidarians"
    case poriferans = "poriferans"
    case ctenophores = "ctenophores"
    case placozoans = "placozoans"
    case chelicerata = "chelicerata"
    case none
}
enum Rarity : CaseIterable, Hashable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
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
