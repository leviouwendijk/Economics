import Foundation

public struct SessionCountEstimationObject: Sendable {
    public let count: Int
    public let local: Int
    public let adjusted: Bool

    public var double: Double {
        return Double(count)
    }

    public var remote: Int {
        return count - local
    }

    public init(
        count: Int,
        local: Int,
        adjusted: Bool = false
    ) throws {
        guard local <= count else {
            throw SessionCountEstimationError.localExceedsCount(count: count, local: local)
        }
        self.count = count
        self.local = local
        self.adjusted = adjusted
    }

    public init(
        count: Int,
        tier: QuotaTierType
    ) throws {
        self.count = count
        switch tier {
            case .combined:
            guard !(tier == .combined) else {
                throw SessionCountEstimationError.cannotUsePreInitializerForCombinedTier
            }
            self.local = 0

            case .local:
            self.local = count

            case .remote:
            self.local = 0
        }
        self.adjusted = true
    }

    public func adjust(to tier: QuotaTierType) throws -> SessionCountEstimationObject {
        guard !(tier == .combined) else {
            return try SessionCountEstimationObject(count: count, local: local, adjusted: true)
        }
        let c = self.count
        return try SessionCountEstimationObject(count: c, tier: tier)
    }

    public func multiplier(for rateType: QuotaRateType) throws -> Double {
        var multiplier = 0.0
        switch rateType {
            case .base:
            multiplier = Double(self.count)

            case .cost:
            guard adjusted == true else {
                throw SessionCountEstimationError.isNotAdjustedForTier
            }
            multiplier = Double(self.remote)

            case .price:
            throw SessionCountEstimationError.cannotGetMultiplierForPriceCase
        }
        return multiplier
    }

    public func base(using baseRate: Double) throws -> Double {
        let multiplier = try self.multiplier(for: .base)
        return multiplier * baseRate
    }
}
