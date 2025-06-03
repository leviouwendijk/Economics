import Foundation

public enum SessionCountEstimationError: Error, LocalizedError, Sendable {
    case localExceedsCount(count: Int, local: Int)
    case suggestionExceedsPrognosis(prognosis: Int, suggestion: Int)

    public var errorDescription: String? {
        switch self {
        case let .localExceedsCount(count, local):
            return "Invalid SessionCountEstimationObject: local (\(local)) cannot exceed count (\(count))."
        case let .suggestionExceedsPrognosis(prognosis, suggestion):
            return "Invalid SessionCountEstimationObject: prognosis (\(prognosis)) cannot exceed count (\(suggestion))."
        }
    }
}

public enum SessionCountEstimationType: CaseIterable, Sendable {
    case prognosis
    case suggestion
}

public struct SessionCountEstimationObject: Sendable {
    public let type: SessionCountEstimationType
    public let count: Int
    public let local: Int

    public var double: Double {
        return Double(count)
    }

    public var remote: Int {
        return count - local
    }

    public init(
        type: SessionCountEstimationType,
        count: Int,
        local: Int = 0
    ) throws {
        guard local <= count else {
            throw SessionCountEstimationError.localExceedsCount(count: count, local: local)
        }
        self.type = type
        self.count = count
        self.local = local
    }
}

public struct SessionCountEstimation: Sendable {
    public let prognosis: SessionCountEstimationObject
    public let suggestion: SessionCountEstimationObject

    public init(
        prognosis: SessionCountEstimationObject,
        suggestion: SessionCountEstimationObject,
    ) throws {
        guard !(suggestion.count > prognosis.count) else {
            throw SessionCountEstimationError.suggestionExceedsPrognosis(
                prognosis: prognosis.count,
                suggestion: suggestion.count
            )
        }
        self.prognosis = prognosis
        self.suggestion = suggestion
    }

    public init(
        prognosisCount: Int,
        prognosisLocal: Int,
        suggestionCount: Int,
        suggestionLocal: Int,
    ) throws {
        let prognosis = try SessionCountEstimationObject(
            type: .prognosis,
            count: prognosisCount,
            local: prognosisLocal
        )
        let suggestion = try SessionCountEstimationObject(
            type: .suggestion,
            count: suggestionCount,
            local: suggestionLocal
        )
        try self.init(
            prognosis: prognosis, 
            suggestion: suggestion
        )
    }

    public func count(for type: SessionCountEstimationType) -> Int {
        switch type {
            case .prognosis:  
            return self.prognosis.count
            case .suggestion: 
            return self.suggestion.count
        }
    }

    public func local(for type: SessionCountEstimationType) -> Int {
        switch type {
            case .prognosis:  
            return self.prognosis.local
            case .suggestion: 
            return self.suggestion.local
        }
    }
}
