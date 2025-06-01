import Foundation

public enum QuotaTierType: CaseIterable {
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
                return estimation.prognosis.local
                case .suggestion:
                return estimation.suggestion.local
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

public struct CustomQuota {
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
        let cost = travelCost.total()
        
        let prog = tier.travelable(in: estimation, for: .prognosis)
        let sugg = tier.travelable(in: estimation, for: .suggestion)

        let prognosis = Double(prog) * cost
        let suggestion = Double(sugg) * cost

        return QuotaTierRate(
            prognosis: prognosis,
            suggestion: suggestion,
            base: cost
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

}

// tier: remote
// estimation: prognosis = 5, suggestion = 3
// local: 2 -- if 

public struct QuotaTierPrice {
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

public struct QuotaTierRate {
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

public struct QuotaTierInput {
    public let base: Double
    public let tier: QuotaTierType
    public let estimation: SessionCountEstimation
    
    // private let local: Int {
    //     switch tier {
    //         case .local:
    //         return 

    //     }
    // }

    public init(
        base: Double,
        tier: QuotaTierType,
        estimation: SessionCountEstimation,
    ) {
        self.base = base
        self.tier = tier
        self.estimation = estimation
    }

    public func price() -> QuotaTierPrice {
        return QuotaTierPrice(
            prognosis: estimation.prognosis.double * base,
            suggestion: estimation.suggestion.double * base,
            base: base
        ) 

    }
}


