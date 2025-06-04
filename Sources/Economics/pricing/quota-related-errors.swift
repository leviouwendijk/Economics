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
        }
    }
}
