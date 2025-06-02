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
    let estimation = SessionCountEstimation(prognosis: prog, suggestion: sugg)

    let quota = CustomQuota(
        base: 350,
        travelCost: travelCost,
        estimation: estimation
    )
    
    return quota
}
