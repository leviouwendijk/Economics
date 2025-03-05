import Foundation

public enum Period {
    case week, month, year
}

public struct PlatformTransactionFees {
    public let fixed: Double
    public let percentage: Double

    public init(fixed: Double, percentage: Double) {
        self.fixed = fixed
        self.percentage = percentage
    }
}

public struct PlatformTransactions {
    public let volume: Int
    public let value: Double
    public let fees: PlatformTransactionFees

    public init(volume: Int, value: Double, fees: PlatformTransactionFees) {
        self.volume = volume
        self.value = value
        self.fees = fees
    }

    public func sumValue() -> Double {
        return volume > 0 ? value * Double(volume) : 0
    }

    public func averageValue() -> Double {
        return volume > 0 ? value / Double(volume) : 0
    }

    public func fixedCost() -> Double {
        return volume > 0 ? Double(volume) * fees.fixed : 0
    }

    public func variableCost() -> Double {
        return averageValue() > 0 ? (averageValue() * (fees.percentage / 100)) * Double(volume) : 0
    }

    public func sumCost() -> Double {
        return fixedCost() + variableCost()
    }

    public func profit() -> Double {
        return sumValue() - sumCost()
    }
}

public struct Result {
    public let name: String
    public let gross: Double
    public let cost: Double
    public let profit: Double
}

public enum CompareCriteria {
    case profit
    case transaction
    case subscription
}

public struct PaymentProcessor {
    public struct Configuration {
        public let name: String
        public let transactions: PlatformTransactions
        public let monthlySubscription: Double
        public let rounding: Bool

        public init(name: String,
                    transactions: PlatformTransactions,
                    monthlySubscription: Double = 0.0,
                    rounding: Bool = false) {
            self.name = name
            self.transactions = transactions
            self.monthlySubscription = monthlySubscription
            self.rounding = rounding
        }
    }

    public static func calculate(config: Configuration) -> Result {
        let gross = config.transactions.sumValue()
        let cost = config.transactions.sumCost()
        let profit = config.transactions.profit()

        return Result(
            name: config.name,
            gross: config.rounding ? roundToTwoDecimals(gross) : gross,
            cost: config.rounding ? roundToTwoDecimals(cost) : cost,
            profit: config.rounding ? roundToTwoDecimals(profit) : profit
        )
    }

    public static func best(configs: [Configuration], criteria: CompareCriteria = .profit) -> Result? {
        let results = configs.map { calculate(config: $0) }

        switch criteria {
        case .profit:
            return results.max(by: { $0.profit < $1.profit }) 
        case .transaction:
            return results.min(by: { $0.cost < $1.cost })
        case .subscription:
            return configs.min(by: { $0.monthlySubscription < $1.monthlySubscription }).map { calculate(config: $0) }
        }
    }
}
