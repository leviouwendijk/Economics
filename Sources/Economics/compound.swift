import Foundation

public enum CompoundTime {
    case beginning
    case end
}

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

    public static func value(config: Configuration, years: Int, calculationTime: CompoundTime = .end) -> (value: Double, invested: Double, return: Double) {
        let rateDecimal = config.annualRate / 100.0
        let monthlyRate = rateDecimal / 12.0
        var amount = config.principal

        let totalMonths = years * 12

        for _ in 1...totalMonths {
            switch calculationTime {
                case .beginning:
                    amount += config.monthlyInvestment
                    amount *= (1 + monthlyRate)
                case .end:
                    amount *= (1 + monthlyRate)
                    amount += config.monthlyInvestment
            }
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
