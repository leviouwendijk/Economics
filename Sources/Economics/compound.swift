import Foundation

public struct CompoundValue {
    public struct Configuration {
        public let principal: Double
        public let annualRate: Double
        public let monthlyInvestment: Double
        public let rounding: Bool

        public init(principal: Double, annualRate: Double, monthlyInvestment: Double, rounding: Bool = false) {
            self.principal = principal
            self.annualRate = annualRate
            self.monthlyInvestment = monthlyInvestment
            self.rounding = rounding
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

        if config.rounding {
            return (
                value: roundToTwoDecimals(amount),
                invested: roundToTwoDecimals(totalContribution),
                return: roundToTwoDecimals(totalReturn)
            )
        } else {
            return (value: amount, invested: totalContribution, return: totalReturn)
        }
    }
}
