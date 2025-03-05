import Foundation

public struct CompoundValue {
    public struct Configuration {
        public let principal: Double
        public let annualRate: Double
        public let monthlyInvestment: Double

        public init(principal: Double, annualRate: Double, monthlyInvestment: Double) {
            self.principal = principal
            self.annualRate = annualRate
            self.monthlyInvestment = monthlyInvestment
        }
    }

    public static func value(config: Configuration, years: Int) -> (value: Double, invested: Double, return: Double) {
        let rateDecimal = config.annualRate / 100.0
        var amount = config.principal

        for _ in 1...years {
            amount = (amount * (1 + rateDecimal)) + config.monthlyInvestment
        }

        let totalContribution = config.principal + (config.monthlyInvestment * Double(years))
        let totalReturn = amount - totalContribution

        return (value: amount, invested: totalContribution, return: totalReturn)
    }
}
