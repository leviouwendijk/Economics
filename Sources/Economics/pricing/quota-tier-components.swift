import Foundation
import plate

public struct QuotaRate: Sendable {
    public let base: Double
    public let cost: Double
    public let price: Double

    // public var price: Double {
    //     return base + cost
    // }

    public init(
        base: Double,
        cost: Double,
        price: Double
    ) {
        self.cost = cost
        self.base = base
        self.price = price
    }

    public func rounded(to multiple: Double = 10, direction: RoundingOffsetDirection = .down, by offset: Double = 0.0) -> QuotaRate {
        return QuotaRate(
            base: base.roundTo(multiple).offset(direction: direction, by: offset),
            cost: cost.roundTo(multiple).offset(direction: direction, by: offset),
            price: price.roundTo(multiple).offset(direction: direction, by: offset),
        )
    }
}

public enum QuotaLevelType: String, CaseIterable, Sendable {
    case prognosis
    case suggestion
    case singular
}

public struct QuotaTierLevels: Sendable {
    public let prognosis: QuotaTierLevelContent
    public let suggestion: QuotaTierLevelContent
    public let singular: QuotaTierLevelContent
    public let restriction: SessionCountEstimationInitializerRestriction

    public init(
        prognosis: QuotaTierLevelContent,
        suggestion: QuotaTierLevelContent,
        singular: QuotaTierLevelContent,
        restriction: SessionCountEstimationInitializerRestriction = .restrictive
    ) throws {
        guard !(singular.estimation.count > 1) else {
            throw SessionCountEstimationError.singularExceedsOne(count: singular.estimation.count)
        }
        self.restriction = restriction
        self.prognosis = prognosis
        self.suggestion = suggestion
        self.singular = singular
        try meetInitializerRestriction()
    }

    public func meetInitializerRestriction() throws {
        let suggCount = suggestion.estimation.count // easier on memory to copy only two necessary ints once in scope?
        let progCount = prognosis.estimation.count // or would it be easier not to copy but have to go search in the struct, (re?)loading the whole struct into memory?
        if restriction == .lenient {
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
    }
}

public struct QuotaTierLevelContent: Sendable {
    // public let level: QuotaLevelType // .prognosis, .suggestion, .singular
    public let rate: QuotaRate
    public let estimation: SessionCountEstimationObject

    public init(
        // level: QuotaLevelType,
        rate: QuotaRate,
        estimation: SessionCountEstimationObject
    ) {
        // guard !(level == .singular && estimation.count > 1) else {
        //     throw SessionCountEstimationError.singularExceedsOne(count: estimation.count)
        // }
        // self.level = level
        self.rate = rate
        self.estimation = estimation
    }
}

// extension Array where Element == QuotaTierLevel {
    // public func missingCases() -> [QuotaLevelType] {
    //     let foundSet = Set(self.map { $0.level })
    //     let allSet   = Set(QuotaLevelType.allCases)
    //     return Array<QuotaLevelType>(allSet.subtracting(foundSet))
    // }

    // public func containsAllCases() -> Bool {
    //     return self.missingCases().isEmpty
    // }

    // public func meetInitializerRestriction(type restriction: SessionCountEstimationInitializerRestriction) throws {
    //     if 
    //         let sugg = self.first(where: { $0.level == .suggestion } ),
    //         let prog = self.first(where: { $0.level == .prognosis } )
    //     {
    //         let suggCount = sugg.estimation.count // easier on memory to copy only two necessary ints once in scope?
    //         let progCount = prog.estimation.count // or would it be easier not to copy but have to go search in the struct, (re?)loading the whole struct into memory?
    //         if restriction == .equal {
    //             guard !(suggCount > progCount) else {
    //                 throw SessionCountEstimationError.suggestionExceedsPrognosis(
    //                     prognosis: progCount,
    //                     suggestion: suggCount
    //                 )
    //             }
    //         } else {
    //             guard progCount > suggCount else {
    //                 throw SessionCountEstimationError.prognosisNotHigherThanSuggestion(
    //                     prognosis: progCount,
    //                     suggestion: suggCount
    //                 )
    //             }
    //         }
    //         return 
    //     } else {
    //         let m = self.missingCases() 
    //         throw QuotaTierError.missingLevels(types: m)
    //     }
    // }
// }
// END OF NEW STRUCTS

public enum SessionCountEstimationInitializerRestriction: Sendable {
    case lenient
    case restrictive

    public var explanation: String {
        switch self {
            case .lenient:
                return "The 'suggestion' session count can not exceed the 'prognosis' session count, but they can be equal."
            case .restrictive:
                return "The 'prognosis' session count must be set higher than the 'suggestion' session count; they cannot be equal."
        }
    }
}
