import Foundation
import plate

public enum QuotaTierType: String, CaseIterable, RawRepresentable, Sendable {
    case local
    case combined
    case remote
}

public struct CustomQuota: Sendable {
    public let base: Double
    public let travelCost: TravelCost
    // public let estimation: SessionCountEstimation 
    // public let estimation: [SessionCountEstimationObject] 
    public let prognosis: SessionCountEstimationObject
    public let suggestion: SessionCountEstimationObject
    public let singular: SessionCountEstimationObject

    public init(
        base: Double = 350,
        travelCost: TravelCost,
        prognosis: SessionCountEstimationObject,
        suggestion: SessionCountEstimationObject,
        singular: SessionCountEstimationObject? = nil
    ) throws {
        self.base = base
        self.travelCost = travelCost
        // self.estimation = estimation
        self.prognosis = prognosis
        self.suggestion = suggestion
        if let s = singular {
            self.singular = s
        } else {
            self.singular = try SessionCountEstimationObject(count: 1, local: 0)
        }
    }

    public func cost(in tier: QuotaTierType, for level: QuotaLevelType) -> Double {
        let cost = travelCost.total()
        
        var multiplier = 0.0

        switch tier {
            case .local:
            multiplier = 0.0

            case .combined:
            switch level {
                case .singular:
                // multiplier = Double(self.singular.remote)
                // do mean cost per 'remote' session instead -- if high, change to cost per session average ('count')
                let prog = Double(prognosis.remote) * cost
                let sugg = Double(suggestion.remote) * cost
                let meanCost = (prog + sugg) / 2.0
                let meanSessions = (Double(prognosis.remote) + Double(suggestion.remote)) / 2.0
                let averageCost = meanCost / meanSessions
                return averageCost

                case .suggestion:
                multiplier = Double(self.suggestion.remote)

                case .prognosis:
                multiplier = Double(self.prognosis.remote)
            }

            case .remote:
            switch level {
                case .singular:
                multiplier = Double(self.singular.count)

                case .suggestion:
                multiplier = Double(self.suggestion.count)

                case .prognosis:
                multiplier = Double(self.prognosis.count)
            }
        }

        return cost * multiplier
    }

    public func base(for level: QuotaLevelType) -> Double {
        var multiplier = 0.0
        switch level {
            case .singular:
            multiplier = Double(self.singular.count)

            case .suggestion:
            multiplier = Double(self.suggestion.count)

            case .prognosis:
            multiplier = Double(self.prognosis.count)
        }
        return base * multiplier
    }

    // public func price(in tier: QuotaTierType, for level: QuotaLevelType) -> Double {
    //     let base = base(for: level)
    //     let cost = cost(in: tier, for: level)

    //     return base + cost
    // }

    public func estimation(for level: QuotaLevelType) -> SessionCountEstimationObject {
        switch level {
            case .singular:
            return singular
            case .suggestion:
            return suggestion
            case .prognosis:
            return prognosis
        }
    }

    public func level(in tier: QuotaTierType, for level: QuotaLevelType) -> QuotaTierLevelContent {
        let b = base(for: level)
        let c = cost(in: tier, for: level)
        let p = b + c
        return QuotaTierLevelContent(
            // level: level,
            rate: QuotaRate(
                base: b,
                cost: c,
                price: p
            ),
            estimation: estimation(for: level)
        )
    }

    public func levels(in tier: QuotaTierType) throws -> QuotaTierLevels {
        let prognosis = self.level(in: tier, for: .prognosis)
        let suggestion = self.level(in: tier, for: .suggestion)
        let singular = self.level(in: tier, for: .singular)

        return try QuotaTierLevels(
            prognosis: prognosis,
            suggestion: suggestion,
            singular: singular
        )
        // var all: [QuotaTierLevelContent] = []
        // for i in QuotaLevelType.allCases {
        //     let level = try self.level(in: tier, for: i)
        //     all.append(level)
        // }
        // return all
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
    // public let base: QuotaTierRate
    // public let cost: QuotaTierRate
    // public let price: QuotaTierRate
    public let levels: QuotaTierLevels

    public init(
        tier: QuotaTierType,
        // base: QuotaTierRate,
        // cost: QuotaTierRate,
        // price: QuotaTierRate
        levels: QuotaTierLevels,
    ) {
        self.tier = tier
        // self.base = base
        // self.cost = cost
        // self.price = price
        // guard levels.containsAllCases() else {
        //     let missing = levels.missingCases()
        //     throw QuotaTierError.missingLevels(types: missing)
        // }
        // try levels.meetInitializerRestriction(type: restriction)
        self.levels = levels
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

