import Foundation

// NEW STRUCTS
// for simplifying a rate calculation to isolated object
public struct QuotaRate: Sendable {
    // public let price: Double
    public let base: Double
    public let cost: Double
    public var price: Double {
        return base + cost
    }

    public init(
        base: Double,
        cost: Double 
    ) {
        self.cost = cost
        self.base = base
    }
}

// for selecting by level
public enum QuotaLevelType: String, CaseIterable, Sendable {
    case prognosis
    case suggestion
    case singular
}

// for binding a rate to its level
// use this to replace base,cost,price in QuotaTierContent object
public struct QuotaTierLevel: Sendable {
    public let level: QuotaLevelType // .prognosis, .suggestion, .singular
    public let rate: QuotaRate
    public let estimation: SessionCountEstimationObject

    public init(
        level: QuotaLevelType,
        rate: QuotaRate,
        estimation: SessionCountEstimationObject
    ) throws {
        guard !(level == .singular && estimation.count > 1) else {
            throw SessionCountEstimationError.singularExceedsOne(count: estimation.count)
        }
        self.level = level
        self.rate = rate
        self.estimation = estimation
    }
}

extension Array where Element == QuotaTierLevel {
    public func missingCases() -> [QuotaLevelType] {
        let foundSet = Set(self.map { $0.level })
        let allSet   = Set(QuotaLevelType.allCases)
        return Array<QuotaLevelType>(allSet.subtracting(foundSet))
    }

    public func containsAllCases() -> Bool {
        return self.missingCases().isEmpty
    }

    public func meetInitializerRestriction(type restriction: SessionCountEstimationInitializerRestriction) throws {
        if 
            let sugg = self.first(where: { $0.level == .suggestion } ),
            let prog = self.first(where: { $0.level == .prognosis } )
        {
            let suggCount = sugg.estimation.count // easier on memory to copy only two necessary ints once in scope?
            let progCount = prog.estimation.count // or would it be easier not to copy but have to go search in the struct, (re?)loading the whole struct into memory?
            if restriction == .equal {
                guard !(suggCount > progCount) else {
                    throw SessionCountEstimationError.suggestionExceedsPrognosis(
                        prognosis: progCount,
                        suggestion: suggCount
                    )
                }
            } else {
                guard progCount > suggCount else {
                    throw SessionCountEstimationError.prognosisNotHigherThanSuggestion(
                        prognosis: progCount,
                        suggestion: suggCount
                    )
                }
            }
            return 
        } else {
            let m = self.missingCases() 
            throw QuotaTierError.missingLevels(types: m)
        }
    }
}
// END OF NEW STRUCTS

public enum SessionCountEstimationInitializerRestriction: Sendable {
    case equal
    case incremental

    public var explanation: String {
        switch self {
            case .equal:
                return "The 'suggestion' session count can not exceed the 'prognosis' session count, but they can be equal."
            case .incremental:
                return "The 'prognosis' session count must be set higher than the 'suggestion' session count; they cannot be equal."
        }
    }
}
