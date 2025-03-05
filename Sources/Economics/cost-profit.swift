import Foundation

public struct CostProfitAnalysis {
    public let costs: Costs
    public let price: Double
    public let sales: Int
    public let rounding: Bool

    public init(costs: Costs, price: Double, sales: Int, rounding: Bool = false) {
        self.costs = costs
        self.price = price
        self.sales = sales
        self.rounding = rounding
    }

    public func revenue() -> Double {
        let result = price * Double(sales)
        return rounding ? roundToTwoDecimals(result) : result
    }

    public func netProfit() -> Double {
        let result = revenue() - costs.total(sales: sales)
        return rounding ? roundToTwoDecimals(result) : result
    }

    public func profitMargin() -> Double {
        let revenue = revenue()
        let result = revenue > 0 ? (netProfit() / revenue) * 100 : 0
        return rounding ? roundToTwoDecimals(result) : result
    }
}
