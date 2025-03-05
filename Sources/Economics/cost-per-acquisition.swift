import Foundation

public struct CostPerAcquisition {
    public let marketingCost: Double
    public let leads: Int
    public let sales: Int
    public let rounding: Bool

    public init(marketingCost: Double, leads: Int, sales: Int, rounding: Bool = false) {
        self.marketingCost = marketingCost
        self.leads = leads
        self.sales = sales
        self.rounding = rounding
    }

    public func costPerLead() -> Double {
        let result = leads > 0 ? marketingCost / Double(leads) : 0
        return rounding ? roundToTwoDecimals(result) : result
    }

    public func conversionRate() -> Double {
        return leads > 0 ? (Double(sales) / Double(leads)) * 100 : 0
    }

    public func costPerAcquisition() -> Double {
        let conversionRate = self.conversionRate() / 100
        let result = conversionRate > 0 ? costPerLead() / conversionRate : Double.infinity
        return rounding ? roundToTwoDecimals(result) : result
    }
}
