import Foundation

public struct BreakEvenAnalysis {
    public let costs: Costs
    public let price: Double

    public init(costs: Costs, price: Double) {
        self.costs = costs
        self.price = price
    }

    public func breakEvenVolume() -> Int {
        let contributionMargin = price - costs.variable(sales: 1)
        return contributionMargin > 0 ? Int(ceil(costs.fixed() / contributionMargin)) : Int.max
    }
}
