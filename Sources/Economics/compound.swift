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
        let monthlyRate = rateDecimal / 12.0
        var amount = config.principal

        let totalMonths = years * 12

        // let compoundedPrincipal = config.principal * pow(1 + monthlyRate, Double(totalMonths))
        // let compoundedContributions = config.monthlyInvestment * ((pow(1 + monthlyRate, Double(totalMonths)) - 1) / monthlyRate)

        // for _ in 1...totalMonths {
        //     amount = (amount * (1 + monthlyRate)) + config.monthlyInvestment
        // }

        for _ in 1...totalMonths {
            amount *= (1 + monthlyRate) // Apply interest to the current total
            amount += config.monthlyInvestment // Add monthly contribution
        }

        let totalContribution = config.principal + (config.monthlyInvestment * Double(totalMonths))
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
