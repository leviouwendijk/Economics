import Foundation

public struct CostPerAcquisition {
    public let marketingCost: Double
    public let leads: Int
    public let sales: Int

    public init(marketingCost: Double, leads: Int, sales: Int) {
        self.marketingCost = marketingCost
        self.leads = leads
        self.sales = sales
    }

    public func costPerLead() -> Double {
        return leads > 0 ? marketingCost / Double(leads) : 0
    }

    public func conversionRate() -> Double {
        return leads > 0 ? (Double(sales) / Double(leads)) * 100 : 0
    }

    public func costPerAcquisition() -> Double {
        let conversionRate = self.conversionRate() / 100
        return conversionRate > 0 ? costPerLead() / conversionRate : Double.infinity
    }
}
