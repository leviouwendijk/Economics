import Foundation

public struct IncomeAllocator {
    public let income: Double
    public let allocations: [IncomeAllocation]
    
    public init(
        income: Double,
        allocations: [IncomeAllocation]
    ) {
        self.income = income
        self.allocations = allocations.sorted(by: { $0.order < $1.order })
    }
    
    public func divide() -> IncomeAllocationSummary {
        var remainder = income
        var steps: [IncomeAllocationEntry] = []

        for allocation in allocations {
            let pct = allocation.percentage / 100
            let principal = allocation.type == .relative ? remainder : income
            let result = principal * pct
            remainder -= result

            let entry = IncomeAllocationEntry(
                allocation: allocation,
                principal: principal,
                result: result,
                remainder: remainder
            )
            steps.append(entry)
        }
        return IncomeAllocationSummary(income: income, entries: steps)
    }

    public func periodsToReachGross(
        target grossTarget: Double,
    ) -> Int {
        guard income > 0 else { return .max }
        return Int(ceil(grossTarget / income))
    }

    public func periodsToReach(
        target accountTarget: Double,
        in account: IncomeAllocationAccount,
    ) -> Int? {
        let summary = divide()
        guard let entry = summary.entries.first(where: { $0.allocation.account == account }),
              entry.result > 0
        else { return nil }
        return Int(ceil(accountTarget / entry.result))
    }
    
    public func projectedBalance(
        for account: IncomeAllocationAccount,
        periods n: Int,
    ) -> Double {
        guard n > 0 else { return 0 }
        let summary = divide()
        let perPeriod = summary.entries.first { $0.allocation.account == account }!.result
        return perPeriod * Double(n)
    }
}
