import Foundation
import plate

public enum IncomeAllocationAccount: String, CaseIterable, Codable {
    case savings = "Savings"
    case incomeTax = "Income Tax"
    case charges = "Charges"
    case purchases = "Purchases"
    case housingExpenses = "Housing Expenses"
    case livingExpenses = "Living Expenses"
    case municipalBills = "Municipal Bills"
}

public enum IncomeAllocationType: String, Codable {
    case absolute
    case relative
}

public enum IncomeAllocationError: Error, LocalizedError, Sendable {
    case percentageAndFixedAreNil

    public var errorDescription: String? {
        switch self {
        case .percentageAndFixedAreNil:
            return "Either a percentage or fixed amount must be passed to intialize the IncomeAllocation object"
        }
    }
}

public struct IncomeAllocation: Codable, Equatable {
    public let account: IncomeAllocationAccount
    public let order: Int
    public let percentage: Double?
    public let fixed: Double?
    public let type: IncomeAllocationType     
    
    public init(
        account: IncomeAllocationAccount,
        order: Int,
        percentage: Double? = nil,
        fixed: Double? = nil,
        type: IncomeAllocationType
    ) throws {
        guard !(percentage == nil && fixed == nil) else {
            throw IncomeAllocationError.percentageAndFixedAreNil
        }
        self.account = account
        self.order = order
        self.percentage = percentage
        self.fixed = fixed
        self.type = type
    }
}

public struct IncomeAllocationEntry: Codable, Equatable {
    public let allocation: IncomeAllocation
    public let principal: Double        
    public let result: Double      
    public let remainder: Double   
}

public struct IncomeAllocationSummary: Codable, Equatable {
    public let income: Double
    public let entries: [IncomeAllocationEntry]

    public var totalDistributed: Double {
        entries.reduce(0) { $0 + $1.result }
    }
    public var finalRemainder: Double {
        entries.last?.remainder ?? income
    }
    public var percentDistributed: Double {
        totalDistributed / income * 100
    }
    public var percentRemaining: Double {
        finalRemainder / income * 100
    }

    public func textReport(width: Int = 20) -> String {
        var s = [String]()
        s.append("")
        s.append("Dividing income: \(income)")
        s.append(String(repeating: "-", count: width))
        s.append("")
        for entry in entries {
            s.append("Account: \(entry.allocation.account)")
            s.append("    Order: \(entry.allocation.order)")
            s.append("    Type: \(entry.allocation.type.rawValue)")
            s.append(String(format: "    Split: %\(width).2f = %.2f%% of %.2f", entry.result, entry.allocation.percentage ?? "", entry.principal))
            s.append("")
        }
        s.append(String(repeating: "=", count: width))
        s.append(String(format: "Metrics for: %.2f", income))
        s.append("")

        let ratios: [(String, String)] = [
            ("Total distributed", String(format: "EUR %.2f", totalDistributed)),
            ("Remainder (Free Cash Flow)", String(format: "EUR %.2f", finalRemainder)),
            ("Percent distributed", String(format: "%.2f%%", percentDistributed)),
            ("Percent remaining", String(format: "%.2f%%", percentRemaining))
        ]
        s.append(contentsOf: ratios.aligned(char: "."))

        s.append("(Note: new 'fixed' variables is not yet in print reports)")

        s.append("")

        return s.joined(separator: "\n")
    }
}
