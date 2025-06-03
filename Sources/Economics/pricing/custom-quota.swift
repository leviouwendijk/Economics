import Foundation

public enum QuotaTierType: String, CaseIterable, RawRepresentable, Sendable {
    case local
    case combined
    case remote

    public func travelable(in estimation: SessionCountEstimation, for type: SessionCountEstimationType) -> Int {
        switch self {
            case .local:
            return 0
            case .combined:
            switch type {
                case .prognosis:
                return estimation.prognosis.count - estimation.prognosis.local
                case .suggestion:
                return estimation.suggestion.count - estimation.suggestion.local
            }
            case .remote:
            switch type {
                case .prognosis:
                return estimation.prognosis.count
                case .suggestion:
                return estimation.suggestion.count
            }
        }
    }
}

public struct CustomQuota: Sendable {
    public let base: Double
    public let travelCost: TravelCost
    public let estimation: SessionCountEstimation 

    public init(
        base: Double = 350,
        travelCost: TravelCost,
        estimation: SessionCountEstimation
    ) {
        self.base = base
        self.travelCost = travelCost
        self.estimation = estimation
    }

    public func cost(for tier: QuotaTierType) -> QuotaTierRate {
        guard tier != .local else {
            return QuotaTierRate(prognosis: 0, suggestion: 0, base: 0)
        }

        let cost = travelCost.total()
        
        let prog = tier.travelable(in: estimation, for: .prognosis)
        let sugg = tier.travelable(in: estimation, for: .suggestion)

        let prognosis = Double(prog) * cost
        let suggestion = Double(sugg) * cost

        let meanSessions = (Double(estimation.prognosis.count) + Double(estimation.suggestion.count)) / 2.0
        let meanCost = (prognosis + suggestion) / 2.0
        let avgCost = meanCost / meanSessions

        return QuotaTierRate(
            prognosis: prognosis,
            suggestion: suggestion,
            base: tier == .combined ? avgCost : cost
        )
    }

    public func base(for tier: QuotaTierType) -> QuotaTierRate {
        let prognosis = estimation.prognosis.double * base 
        let suggestion = estimation.suggestion.double * base 

        return QuotaTierRate(
            prognosis: prognosis,
            suggestion: suggestion,
            base: base
        )
    }

    public func price(for tier: QuotaTierType) -> QuotaTierRate {
        let cost = cost(for: tier) 
        let baseRate = base(for: tier)

        let prognosis = baseRate.prognosis + cost.prognosis
        let suggestion = baseRate.suggestion + cost.suggestion

        let basePrice = baseRate.base + cost.base

        return QuotaTierRate(
            prognosis: prognosis,
            suggestion: suggestion,
            base: basePrice
        )
    }

    public func tier(for tier: QuotaTierType) -> QuotaTierContent {
        return QuotaTierContent(
            tier: tier,
            base: base(for: tier),
            cost: cost(for: tier),
            price: price(for: tier)
        )
    }

    public func tiers() -> [QuotaTierContent] {
        var tiers: [QuotaTierContent] = []
        for t in QuotaTierType.allCases {
            tiers.append(tier(for: t))
        }
        return tiers
    }

    public func inputs() -> String {
        return """
        kilometers: \(travelCost.kilometers)
            at:
                \(travelCost.rates.time) / hr
                \(travelCost.rates.travel) / km
                \(travelCost.speed) km/hr
            for: 
                \(travelCost.traveledHours()) hours
        using base rate: \(base)
        """
    }

    public func tierSummary(for tier: QuotaTierType) -> String {
        let content = self.tier(for: tier)

        return """
        \(content.string())

        \(self.inputs())
        """
    }

    public func quotaSummary() -> String {
        let contents = self.tiers()

        return """
        \(self.inputs())

        \(contents.table())
        """
    }

    // public func tiersStringDictionary() -> [QuotaTierType: String] {
    //     let contents = self.tiers()
    //     var dict: [QuotaTierType: String] = [:]
    //     for t in contents {
    //         dict[t.tier] = t.string()
    //     }
    //     return dict
    // }
}

public struct QuotaTierContent: Sendable {
    public let tier: QuotaTierType
    public let base: QuotaTierRate
    public let cost: QuotaTierRate
    public let price: QuotaTierRate

    public init(
        tier: QuotaTierType,
        base: QuotaTierRate,
        cost: QuotaTierRate,
        price: QuotaTierRate
    ) {
        self.tier = tier
        self.base = base
        self.cost = cost
        self.price = price
    }

    public func string(
        tier: Bool = true,
        cost: Bool = true,
        base: Bool = true
    ) -> String {
        var str = ""
        if tier {
            str.append("tier: \(self.tier.rawValue)\n\n")
        }
        str.append("price: \(price)\n")
        if cost {
            str.append("cost: \(cost)\n")
        }
        if base {
            str.append("base: \(base)\n")
        }
        return str
    }
}

public struct QuotaTierRate: Sendable {
    public let prognosis: Double
    public let suggestion: Double
    public let base: Double

    public init(
        prognosis: Double,
        suggestion: Double,
        base: Double,
    ) {
        self.prognosis = prognosis
        self.suggestion = suggestion
        self.base = base
    }

    public func string(all: Bool = false) -> String {
        // let prog = String(format: "%.2f", prognosis)
        let sugg = String(format: "%.2f", suggestion)
        // let base = String(format: "%.2f", base)

        let strAll = String(format: "prognosis: %.2f, suggestion: %.2f, base: %.2f", prognosis, suggestion, base)

        return all ? strAll : sugg
    }
}

public func quota(
    kilometers: Double,
    prognosis: (Int, Int),
    suggestion: (Int, Int),
    base: Double
) throws -> CustomQuota {
    let travelCost = TravelCost(kilometers: kilometers)
    let prog = try SessionCountEstimationObject(type: .prognosis, count: prognosis.0, local: prognosis.1)
    let sugg = try SessionCountEstimationObject(type: .suggestion, count: suggestion.0, local: suggestion.1)
    let estimation = try SessionCountEstimation(prognosis: prog, suggestion: sugg)

    let quota = CustomQuota(
        base: 350,
        travelCost: travelCost,
        estimation: estimation
    )
    
    return quota
}

