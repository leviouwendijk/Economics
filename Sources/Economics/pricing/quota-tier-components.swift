import Foundation
// import Extensions
import plate

public enum QuotaRateType: String, CaseIterable, Sendable {
    case base
    case cost
    case price
}

public struct QuotaRate: Sendable {
    public let base: Double
    public let cost: Double
    public let price: Double

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

    public func viewableTuples(
        of rate: QuotaRateType,
        displayPolicy: QuotaPriceDisplayPolicy = .raw
    ) -> [(String, Double)] {
        switch rate {
        case .price:
            switch displayPolicy {
            case .raw:
                return [
                    ("prognosis", prognosis.rate.price),
                    ("suggestion", suggestion.rate.price),
                    ("singular", singular.rate.price)
                ]

                case let .rounded(multiple, direction, offset, _):
                let pr = prognosis.rate.rounded(to: multiple, direction: direction, by: offset).price
                let su = suggestion.rate.rounded(to: multiple, direction: direction, by: offset).price
                let si = singular.rate.rounded(to: multiple, direction: direction, by: offset).price

                return [
                    // ("prognosis", (integer ? pr.integer() : pr )),
                    ("prognosis", pr),
                    ("suggestion", su),
                    ("singular", si)
                ]
            }

        case .cost:
            return [
                ("prognosis", prognosis.rate.cost),
                ("suggestion", suggestion.rate.cost),
                ("singular", singular.rate.cost)
            ]

        case .base:
            return [
                ("prognosis", prognosis.rate.base),
                ("suggestion", suggestion.rate.base),
                ("singular", singular.rate.base)
            ]
        }
    }
}

public struct QuotaTierLevelContent: Sendable {
    public let rate: QuotaRate
    public let estimation: SessionCountEstimationObject

    public init(
        rate: QuotaRate,
        estimation: SessionCountEstimationObject
    ) {
        self.rate = rate
        self.estimation = estimation
    }
}

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
