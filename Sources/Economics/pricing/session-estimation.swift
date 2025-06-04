import Foundation

// public enum SessionCountEstimationType: CaseIterable, Sendable {
//     case prognosis
//     case suggestion
//     case singular // experimentally adding base (singular session in the estimation count/local)
// }

public struct SessionCountEstimationObject: Sendable {
    // public let type: QuotaLevelType
    public let count: Int
    public let local: Int

    public var double: Double {
        return Double(count)
    }

    public var remote: Int {
        return count - local
    }

    public init(
        // type: QuotaLevelType,
        count: Int,
        local: Int = 0
    ) throws {
        guard local <= count else {
            throw SessionCountEstimationError.localExceedsCount(count: count, local: local)
        }
        // self.type = type
        self.count = count
        self.local = local
    }
}

// public struct SessionCountEstimation: Sendable {
//     public let prognosis: SessionCountEstimationObject
//     public let suggestion: SessionCountEstimationObject
//     public let singular: SessionCountEstimationObject
//     public let restriction: SessionCountEstimationInitializerRestriction

//     public init(
//         prognosis: SessionCountEstimationObject,
//         suggestion: SessionCountEstimationObject,
//         singular: SessionCountEstimationObject,
//         restriction: SessionCountEstimationInitializerRestriction = .incremental
//     ) throws {
//         self.restriction = restriction
//         if restriction == .equal {
//             guard !(suggestion.count > prognosis.count) else {
//                 throw SessionCountEstimationError.suggestionExceedsPrognosis(
//                     prognosis: prognosis.count,
//                     suggestion: suggestion.count
//                 )
//             }
//         } else {
//             guard prognosis.count > suggestion.count else {
//                 throw SessionCountEstimationError.prognosisNotHigherThanSuggestion(
//                     prognosis: prognosis.count,
//                     suggestion: suggestion.count
//                 )
//             }
//         }
//         self.prognosis = prognosis
//         self.suggestion = suggestion
//         self.singular = singular
//     }

//     public init(
//         prognosisCount: Int,
//         prognosisLocal: Int,
//         suggestionCount: Int,
//         suggestionLocal: Int,
//         singularCount: Int = 1,
//         singularLocal: Int = 0,
//     ) throws {
//         let prognosis = try SessionCountEstimationObject(
//             type: .prognosis,
//             count: prognosisCount,
//             local: prognosisLocal
//         )
//         let suggestion = try SessionCountEstimationObject(
//             type: .suggestion,
//             count: suggestionCount,
//             local: suggestionLocal
//         )
//         let singular = try SessionCountEstimationObject(
//             type: .singular,
//             count: singularCount,
//             local: singularLocal
//         )
//         try self.init(
//             prognosis: prognosis, 
//             suggestion: suggestion,
//             singular: singular
//         )
//     }

//     public func count(for level: QuotaLevelType) -> Int {
//         switch level {
//             case .prognosis:  
//             return self.prognosis.count
//             case .suggestion: 
//             return self.suggestion.count
//             case .singular: 
//             return self.singular.count
//         }
//     }

//     public func local(for level: QuotaLevelType) -> Int {
//         switch level {
//             case .prognosis:  
//             return self.prognosis.local
//             case .suggestion: 
//             return self.suggestion.local
//             case .singular: 
//             return self.singular.local
//         }
//     }

//     public func travelable(in tier: QuotaTierType, for level: QuotaLevelType) -> Int {
//         switch tier {
//             case .local:
//             return 0
//             case .combined:
//             switch level {
//                 case .prognosis:
//                 return self.prognosis.remote
//                 case .suggestion:
//                 return self.suggestion.remote
//                 case .singular:
//                 return self.singular.remote
//             }
//             case .remote:
//             switch level {
//                 case .prognosis:
//                 return self.prognosis.count
//                 case .suggestion:
//                 return self.suggestion.count
//                 case .singular:
//                 return self.singular.count
//             }
//         }
//     }
// }
