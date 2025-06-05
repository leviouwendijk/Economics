import Foundation
import plate

public enum QuotaTierType: String, CaseIterable, RawRepresentable, Sendable, Identifiable {
    case local
    case combined
    case remote

    public var id: String {
        rawValue
    }
}

public struct CustomQuota: Sendable {
    public let base: Double
    public let travelCost: TravelCost
    public let prognosis: SessionCountEstimationObject
    public let suggestion: SessionCountEstimationObject
    public let singular: SessionCountEstimationObject

    public init(
        base: Double = 350,
        travelCost: TravelCost,
        prognosis: SessionCountEstimationObject,
        suggestion: SessionCountEstimationObject,
        singular: SessionCountEstimationObject
    ) throws {
        self.base = base
        self.travelCost = travelCost
        self.prognosis = prognosis
        self.suggestion = suggestion
        self.singular = singular
    }

    public func cost(in tier: QuotaTierType, for level: QuotaLevelType) throws -> Double {
        let adjusted = try self.adjusted(to: tier, for: level)
        return try travelCost.cost(for: adjusted)
    }

    public func base(in tier: QuotaTierType, for level: QuotaLevelType) throws -> Double {
        let adjusted = try self.adjusted(to: tier, for: level)
        return try adjusted.base(using: base)
    }

    public func adjusted(to tier: QuotaTierType, for level: QuotaLevelType) throws -> SessionCountEstimationObject {
        switch tier {
        case .combined:
            switch level {
                case .singular:
                return singular
                case .suggestion:
                return suggestion
                case .prognosis:
                return prognosis
            }

        case .local:
            switch level {
                case .singular:
                return try singular.adjust(to: .local)
                case .suggestion:
                return try suggestion.adjust(to: .local)
                case .prognosis:
                return try prognosis.adjust(to: .local)
            }

        case .remote:
            switch level {
                case .singular:
                return try singular.adjust(to: .remote)
                case .suggestion:
                return try suggestion.adjust(to: .remote)
                case .prognosis:
                return try prognosis.adjust(to: .remote)
            }
        }
    }

    public func level(in tier: QuotaTierType, for level: QuotaLevelType) throws -> QuotaTierLevelContent {
        let b = try base(in: tier, for: level)
        let c = try cost(in: tier, for: level)
        let p = b + c
        return QuotaTierLevelContent(
            // level: level,
            rate: QuotaRate(
                base: b,
                cost: c,
                price: p
            ),
            estimation: try adjusted(to: tier, for: level)
        )
    }

    public func levels(in tier: QuotaTierType) throws -> QuotaTierLevels {
        let prognosis = try self.level(in: tier, for: .prognosis)
        let suggestion = try self.level(in: tier, for: .suggestion)
        let singular = try self.level(in: tier, for: .singular)

        return try QuotaTierLevels(
            prognosis: prognosis,
            suggestion: suggestion,
            singular: singular
        )
    }

    public func tier(being type: QuotaTierType) throws -> QuotaTierContent {
        let levels = try self.levels(in: type)
        return QuotaTierContent(
            tier: type,
            levels: levels
        )
    }

    public func tiers() throws -> [QuotaTierContent] {
        var contents: [QuotaTierContent] = []
        for i in QuotaTierType.allCases {
            let tier = try self.tier(being: i)
            contents.append(tier)
        }
        return contents
    }

    public func inputs(for clientIdentifier: String? = nil) -> String {
        var str = ""

        if let client = clientIdentifier {
            str.append(client)
            str.append("\n")
            let div = String(repeating: "-", count: 55)
            str.append(div)
            str.append("\n")
        }

        let settings = """
        kilometers: \(travelCost.kilometers)
            at:
                \(travelCost.rates.time) / hr
                \(travelCost.rates.travel) / km
                \(travelCost.speed) km/hr
            for: 
                \(travelCost.traveledHours()) hours
        cost per session: \(travelCost.total())

        using base rate: \(base)

        estimation:
            prognosis: \(prognosis.count) sessions
                remote: \(prognosis.remote)
                local: \(prognosis.local)
            suggestion: \(suggestion.count) sessions
                remote: \(suggestion.remote)
                local: \(suggestion.local)
            singular: \(suggestion.count) sessions
                remote: \(singular.remote)
                local: \(singular.local)
        """

        str.append(settings)
        return str
    }

    public func shortInputs(for tier: QuotaTierType, clientIdentifier: String? = nil) throws -> String {
        var str = ""

        if let client = clientIdentifier {
            str.append(client)
            str.append("\n")
            let div = String(repeating: "-", count: 55)
            str.append(div)
            str.append("\n")
        }

        let t = try self.tier(being: tier)

        let settings = """
        (base: \(base), kilometers: \(travelCost.kilometers))

        \(t.string(for: tier, clientIdentifier: clientIdentifier))
        """

        str.append(settings)
        return str
    }

    // public func tierSummary(for tier: QuotaTierType, clientIdentifier: String? = nil) -> String {
    //     let content = self.tier(being: tier)

    //     return """
    //     \(content.string())

    //     \(self.inputs(for: clientIdentifier))
    //     """
    // }

    public func quotaSummary(clientIdentifier: String? = nil) throws -> String {
        let contents = try self.tiers()

        return """
        \(self.inputs(for: clientIdentifier))

        \(contents.table(by: .rate))
        """
    }
}

public struct QuotaTierContent: Sendable {
    public let tier: QuotaTierType
    public let levels: QuotaTierLevels

    public init(
        tier: QuotaTierType,
        levels: QuotaTierLevels,
    ) {
        self.tier = tier
        self.levels = levels
    }

    // public func resolve(for tier: QuotaTierType) -> SessionCountEstimationObject {
    //     var progRemote = 0
    //     var progLocal = 0
    //     var suggRemote = 0
    //     var suggLocal = 0
    //     var singular = ""

    //     switch tier {
    //         case .combined:
    //         progRemote = levels.prognosis.estimation.remote
    //         progLocal = levels.prognosis.estimation.local
    //         suggRemote = levels.suggestion.estimation.remote
    //         suggLocal = levels.suggestion.estimation.local
    //         singular = levels.singular.estimation.local == 1 ? "l" : "r"

    //         case .remote:
    //         progRemote = levels.prognosis.estimation.count
    //         progLocal = levels.prognosis.estimation.
    //         suggRemote = levels.suggestion.estimation.remote
    //         suggLocal = levels.suggestion.estimation.local
    //         singular = levels.singular.estimation.local == 1 ? "l" : "r"


    //     }
        

    // }

    public func string(for tier: QuotaTierType, clientIdentifier: String? = nil) -> String {
        var str = ""

        if let client = clientIdentifier {
            str.append(client)
            str.append("\n")
            let div = String(repeating: "-", count: 35)
            str.append(div)
            str.append("\n")
        }

        let singularLocation = levels.singular.estimation.local == 1 ? "l" : "r"

        let settings = """
        prognosis: \(levels.prognosis.estimation.count) (r: \(levels.prognosis.estimation.remote), l: \(levels.prognosis.estimation.local))
        suggestion: \(levels.suggestion.estimation.count) (r: \(levels.suggestion.estimation.remote), l: \(levels.suggestion.estimation.local))
        singular: (r/l: \(singularLocation))
        """

        str.append(settings)
        return str
    }

    // public func string(
    //     tier: Bool = true,
    //     cost: Bool = true,
    //     base: Bool = true
    // ) -> String {
    //     var str = ""
    //     if tier {
    //         str.append("tier: \(self.tier.rawValue)\n\n")
    //     }
    //     str.append("price: \(price)\n")
    //     if cost {
    //         str.append("cost: \(cost)\n")
    //     }
    //     if base {
    //         str.append("base: \(base)\n")
    //     }
    //     return str
    // }

    // public func flatten(to level: QuotaTierRateLevel) -> QuotaTierLevel {
    //     switch level {
    //     case .prognosis:
    //         return QuotaTierLevel(
    //             level: level,
    //             price: self.price.prognosis,
    //             cost:  self.cost.prognosis,
    //             base:  self.base.prognosis
    //         )

    //     case .suggestion:
    //         return QuotaTierLevel(
    //             level: level,
    //             price: self.price.suggestion,
    //             cost:  self.cost.suggestion,
    //             base:  self.base.suggestion
    //         )

    //     case .base:
    //         return QuotaTierLevel(
    //             level: level,
    //             price: self.price.base,
    //             cost:  self.cost.base,
    //             base:  self.base.base
    //         )
    //     }
    // }
}


// public struct QuotaTierRate: Sendable {
//     public let prognosis: Double
//     public let suggestion: Double
//     public let base: Double

//     public init(
//         prognosis: Double,
//         suggestion: Double,
//         base: Double,
//     ) {
//         self.prognosis = prognosis
//         self.suggestion = suggestion
//         self.base = base
//     }

//     public func string(all: Bool = false) -> String {
//         // let prog = String(format: "%.2f", prognosis)
//         let sugg = String(format: "%.2f", suggestion)
//         // let base = String(format: "%.2f", base)

//         let strAll = String(format: "prognosis: %.2f, suggestion: %.2f, base: %.2f", prognosis, suggestion, base)

//         return all ? strAll : sugg
//     }
// }

// public func quota(
//     kilometers: Double,
//     prognosis: (Int, Int),
//     suggestion: (Int, Int),
//     base: Double
// ) throws -> CustomQuota {
//     let travelCost = TravelCost(kilometers: kilometers)
//     let prog = try SessionCountEstimationObject(type: .prognosis, count: prognosis.0, local: prognosis.1)
//     let sugg = try SessionCountEstimationObject(type: .suggestion, count: suggestion.0, local: suggestion.1)
//     let estimation = try SessionCountEstimation(prognosis: prog, suggestion: sugg)

//     let quota = CustomQuota(
//         base: 350,
//         travelCost: travelCost,
//         estimation: estimation
//     )
    
//     return quota
// }

