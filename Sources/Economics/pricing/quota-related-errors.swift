import Foundation

public enum QuotaTierError: Error, LocalizedError, Sendable {
    case missingLevels(types: [QuotaLevelType])

    public var errorDescription: String? {
        switch self {
        case let .missingLevels(types):
            var str = ""
            for t in types {
                str.append("    \(t) is missing\n")
            }
            return """
            Failed to initialize QuotaTierContent because of missing QuotaTierLevel:
            \(str)
            """
        }
    }
}

public enum SessionCountEstimationError: Error, LocalizedError, Sendable {
    case localExceedsCount(count: Int, local: Int)
    case singularExceedsOne(count: Int)
    case suggestionExceedsPrognosis(prognosis: Int, suggestion: Int)
    case prognosisNotHigherThanSuggestion(prognosis: Int, suggestion: Int)
    case cannotUsePreInitializerForCombinedTier
    case isNotAdjustedForTier
    case cannotGetMultiplierForPriceCase

    public var errorDescription: String? {
        switch self {
        case let .localExceedsCount(count, local):
            return "Invalid SessionCountEstimationObject: local (\(local)) cannot exceed count (\(count))."
        case let .singularExceedsOne(count):
            return "Invalid SessionCountEstimationObject: singular estimation cannot be greater than 1 (\(count)))."
        case let .suggestionExceedsPrognosis(prognosis, suggestion):
            return "Invalid SessionCountEstimationObject: prognosis (\(prognosis)) cannot exceed suggestion (\(suggestion))."
        case let .prognosisNotHigherThanSuggestion(prognosis, suggestion):
            return "Invalid SessionCountEstimationObject: prognosis (\(prognosis)) must exceed suggestion (\(suggestion))."
        case .cannotUsePreInitializerForCombinedTier:
            return "Invalid SessionCountEstimationObject init: .combined tier cannot pre-populate local or remote sessions, only .local and .remote."
        case .isNotAdjustedForTier:
            return "Invalid SessionCountEstimationObject operation: this is a raw session estimation object that has not been adjusted for local, remote, or combined"
        case .cannotGetMultiplierForPriceCase:
            return "Invalid SessionCountEstimationObject operation: price rateType does not have its own multiplier, because that is a sum of base and cost cases."
        }
    }
}
