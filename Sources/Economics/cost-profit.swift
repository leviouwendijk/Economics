import Foundation

public struct CostProfitAnalysis {
    public let costs: Costs
    public let price: Double
    public let sales: Int

    public init(costs: Costs, price: Double, sales: Int) {
        self.costs = costs
        self.price = price
        self.sales = sales
    }

    public func revenue() -> Double {
        return price * Double(sales)
    }

    public func netProfit() -> Double {
        return revenue() - costs.total(sales: sales)
    }

    public func profitMargin() -> Double {
        let revenue = revenue()
        return revenue > 0 ? (netProfit() / revenue) * 100 : 0
    }
}
