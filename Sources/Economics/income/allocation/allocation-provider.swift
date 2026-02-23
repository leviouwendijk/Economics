import Foundation

public enum IncomeAllocationPreset: String, CaseIterable, Codable, Hashable {
    case previous
    case defaults
    case adaptation_a
    case adaptation_b
    case adaptation_c

    public func allocations() throws -> [IncomeAllocation] {
        switch self {
        case .previous:
            return try IncomeAllocationProvider.previous()
        case .defaults:
            return try IncomeAllocationProvider.defaults()
        case .adaptation_a:
            return try IncomeAllocationProvider.adaptation_a()
        case .adaptation_b:
            return try IncomeAllocationProvider.adaptation_b()
        case .adaptation_c:
            return try IncomeAllocationProvider.adaptation_c()
        }
    }
}

public struct IncomeAllocationProvider {
    public init() {}

    public static func previous() throws -> [IncomeAllocation] {
        return [
            try IncomeAllocation(
                account: .savings,
                order: 1,
                percentage: 10,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .incomeTax,
                order: 2,
                percentage: 20,
                type: .relative
            ),
            try IncomeAllocation(
                account: .charges,
                order: 3,
                percentage: 10,
                type: .relative
            )
        ]
    }

    public static func defaults() throws -> [IncomeAllocation] {
        return [
            try IncomeAllocation(
                account: .savings,
                order: 1,
                percentage: 15,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .incomeTax,
                order: 2,
                percentage: 35.5,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .charges,
                order: 3,
                percentage: 2.75,
                type: .relative
            ),
            try IncomeAllocation(
                account: .purchases,
                order: 4,
                percentage: 14.5,
                type: .relative
            ),
            try IncomeAllocation(
                account: .housingExpenses,
                order: 5,
                percentage: 20,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .livingExpenses,
                order: 6,
                percentage: 12.5,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .municipalBills,
                order: 7,
                percentage: 7.25,
                type: .relative
            )
        ]
    }

    public static func adaptation_a() throws -> [IncomeAllocation] {
        return [
            try IncomeAllocation(
                account: .savings,
                order: 1,
                percentage: 10,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .purchases,
                order: 2,
                percentage: 20.0,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .livingExpenses,
                order: 3,
                percentage: 45.0,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .incomeTax,
                order: 4,
                percentage: 15.0,
                type: .absolute
            )
        ]
    }

    public static func adaptation_b() throws -> [IncomeAllocation] {
        return [
            try IncomeAllocation(
                account: .savings,
                order: 1,
                percentage: 15,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .incomeTax,
                order: 2,
                percentage: 35.5,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .charges,
                order: 3,
                percentage: 1.36125,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .purchases,
                order: 4,
                percentage: 6.98011875,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .housingExpenses,
                order: 5,
                percentage: 20,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .livingExpenses,
                order: 6,
                percentage: 12.5,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .municipalBills,
                order: 7,
                percentage: 0.627750765625,
                type: .absolute
            )
        ]
    }

    public static func adaptation_c() throws -> [IncomeAllocation] {
        return [
            try IncomeAllocation(
                account: .savings,
                order: 1,
                percentage: 15,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .incomeTax,
                order: 2,
                percentage: 35.0,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .charges,
                order: 3,
                percentage: 2.0,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .purchases,
                order: 4,
                percentage: 5,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .housingExpenses,
                order: 5,
                percentage: 20,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .livingExpenses,
                order: 6,
                percentage: 15.0,
                type: .absolute
            ),
            try IncomeAllocation(
                account: .municipalBills,
                order: 7,
                percentage: 1,
                type: .absolute
            )
        ]
    }
}
