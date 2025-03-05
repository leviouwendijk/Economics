import Foundation

public struct SavingsTarget {
    public struct Configuration {
        public let target: Double
        public let income: Double
        public let rounding: Bool

        public init(target: Double, income: Double, rounding: Bool = false) {
            self.target = target
            self.income = income
            self.rounding = rounding
        }
    }

    public static func time(config: Configuration, saveRate: Double) -> Int {
        let monthlySavings = (saveRate / 100) * config.income
        guard monthlySavings > 0 else { return Int.max }
        return Int(ceil(config.target / monthlySavings))
    }

    public static func saverate(config: Configuration, months: Int) -> Double {
        guard months > 0, config.income > 0 else { return 0 }
        let output = (config.target / (config.income * Double(months))) * 100
        if config.rounding {
            return roundToTwoDecimals(output)
        } else {
            return output
        }
    }
}
