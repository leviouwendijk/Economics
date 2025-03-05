import Foundation

public struct SavingsTarget {
    public struct Configuration {
        public let target: Double
        public let income: Double

        public init(target: Double, income: Double) {
            self.target = target
            self.income = income
        }
    }

    public static func time(config: Configuration, saveRate: Double) -> Int {
        let monthlySavings = (saveRate / 100) * config.income
        guard monthlySavings > 0 else { return Int.max }
        return Int(ceil(config.target / monthlySavings))
    }

    public static func saverate(config: Configuration, months: Int) -> Double {
        guard months > 0, config.income > 0 else { return 0 }
        return (config.target / (config.income * Double(months))) * 100
    }
}
