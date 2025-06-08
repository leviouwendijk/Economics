import Foundation

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
}
