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

}

public struct Result {
    public let name: String
    public let gross: Double
    public let cost: Double
    public let profit: Double
}

public struct PaymentProcessor {
    public struct Configuration {
        public let name: String
        public let fees: (fixed: Double, percentage: Double, monthly: Double)
        public let rounding: Bool

        public init(name: String,
                    fees: (fixed: Double, percentage: Double, monthly: Double),
                    rounding: Bool = false) {
            self.name = name
            self.fees = fees
            self.rounding = rounding
        }
    }

    public static func calculate(config: Configuration, transactions: PlatformTransactions) -> Result {
        func fixedCost() -> Double {
            return transactions.volume > 0 ? Double(transactions.volume) * config.fees.fixed : 0
        }

        func variableCost() -> Double {
            return transactions.averageValue() > 0 ? (transactions.averageValue() * (config.fees.percentage / 100)) * Double(transactions.volume) : 0
        }

        func sumCost() -> Double {
            return fixedCost() + variableCost()
        }

        func profit() -> Double {
            return transactions.sumValue() - sumCost()
        }

        let gross = transactions.sumValue()
        let cost = sumCost()
        let profit = profit()

        return Result(
            name: config.name,
            gross: config.rounding ? roundToTwoDecimals(gross) : gross,
            cost: config.rounding ? roundToTwoDecimals(cost) : cost,
            profit: config.rounding ? roundToTwoDecimals(profit) : profit
        )
    }
}

public enum CompareCriteria {
    case profit
    case transaction
    case subscription
}

public struct ComparePaymentProcessors {
    public let configs: [PaymentProcessor.Configuration]
    public let transactions: PlatformTransactions

    public init(configs: [PaymentProcessor.Configuration], transactions: PlatformTransactions) {
        self.configs = configs
        self.transactions = transactions
    }

    public func best(criteria: CompareCriteria) -> Result? {
        let results = configs.map { PaymentProcessor.calculate(config: $0, transactions: transactions) }

        switch criteria {
        case .profit:
            return results.max(by: { $0.profit < $1.profit }) 
        case .transaction:
            return results.min(by: { $0.cost < $1.cost })
        case .subscription:
            return configs.min(by: { $0.fees.monthly < $1.fees.monthly }).map { PaymentProcessor.calculate(config: $0, transactions: transactions) }
        }
    }
}
