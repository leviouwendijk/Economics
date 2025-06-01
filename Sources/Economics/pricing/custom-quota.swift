import Foundation

public struct SessionEstimation {
    public let prognosis: Double
    public let suggestion: Double

    public init(
        prognosis: Double,
        suggestion: Double,

    ) {
        self.prognosis = prognosis
        self.suggestion = suggestion
    }
}

public struct CustomQuota {
    public let base: Double
    public let travelCost: TravelCost
    public let estimation: SessionEstimation

    public init(
        base: Double,
        travelCost: TravelCost,
        estimation: SessionEstimation
    ) {
        self.base = base
        self.travelCost = travelCost
        self.estimation = estimation
    }
}
