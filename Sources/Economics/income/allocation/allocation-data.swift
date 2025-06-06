import Foundation

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

public struct IncomeAllocation: Codable, Equatable {
    public let account: IncomeAllocationAccount
    public let order: Int
    public let percentage: Double   
    public let type: IncomeAllocationType     
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
}
