// import Foundation

// public enum ConversionError: Error {
//     case unknownCase(String)
// }

// public protocol ConvertibleEnum {
//     associatedtype Other
//     init(from other: Other) throws
//     var asOther: Other { get }
// }

// extension SessionCountEstimationType: ConvertibleEnum {
//     public typealias Other = QuotaRateLevel

//     public init(from other: QuotaRateLevel) throws {
//         switch other {
//         case .prognosis:
//             self = .prognosis
//         case .suggestion:
//             self = .suggestion
//         case .singular:
//             self = .singular
//         }
//     }

//     public var asOther: QuotaRateLevel {
//         switch self {
//         case .prognosis:
//             return .prognosis
//         case .suggestion:
//             return .suggestion
//         case .singular:
//             return .singular
//         }
//     }
// }

// extension QuotaRateLevel: ConvertibleEnum {
//     public typealias Other = SessionCountEstimationType

//     public init(from other: SessionCountEstimationType) throws {
//         switch other {
//         case .prognosis:
//             self = .prognosis
//         case .suggestion:
//             self = .suggestion
//         case .singular:
//             self = .singular
//         }
//     }

//     public var asOther: SessionCountEstimationType {
//         switch self {
//         case .prognosis:
//             return .prognosis
//         case .suggestion:
//             return .suggestion
//         case .singular:
//             return .singular
//         }
//     }
// }
