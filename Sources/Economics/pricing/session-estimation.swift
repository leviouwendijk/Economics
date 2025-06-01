import Foundation

public enum SessionCountEstimationError: Error, LocalizedError {
    case localExceedsCount(count: Int, local: Int)

    public var errorDescription: String? {
        switch self {
        case let .localExceedsCount(count, local):
            return "Invalid SessionCountEstimationObject: local (\(local)) cannot exceed count (\(count))."
        }
    }
}

public enum SessionCountEstimationType: CaseIterable {
    case prognosis
    case suggestion
}

public struct SessionCountEstimationObject {
    public let type: SessionCountEstimationType
    public let count: Int
    public let local: Int

    public var double: Double {
        return Double(count)
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

public struct SessionCountEstimation {
    public let prognosis: SessionCountEstimationObject
    public let suggestion: SessionCountEstimationObject

    public init(
        prognosis: SessionCountEstimationObject,
        suggestion: SessionCountEstimationObject,
    ) {
        self.prognosis = prognosis
        self.suggestion = suggestion
    }

    public init(
        prognosisCount: Int,
        prognosisLocal: Int,
        suggestionCount: Int,
        suggestionLocal: Int,
    ) throws {
        self.prognosis = try SessionCountEstimationObject(
            type: .prognosis,
            count: prognosisCount,
            local: prognosisLocal
        )

        self.suggestion = try SessionCountEstimationObject(
            type: .suggestion,
            count: suggestionCount,
            local: suggestionLocal
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
