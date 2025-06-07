import Foundation
import plate

public enum QuotaTierType: String, CaseIterable, RawRepresentable, Sendable, Identifiable {
    case local
    case combined
    case remote

    public var id: String {
        rawValue
    }
}

public struct CustomQuota: Sendable {
    public let base: Double
    public let travelCost: TravelCost
    public let prognosis: SessionCountEstimationObject
    public let suggestion: SessionCountEstimationObject
    public let singular: SessionCountEstimationObject

    public init(
        base: Double = 350,
        travelCost: TravelCost,
        prognosis: SessionCountEstimationObject,
        suggestion: SessionCountEstimationObject,
        singular: SessionCountEstimationObject
    ) throws {
        self.base = base
        self.travelCost = travelCost
        self.prognosis = prognosis
        self.suggestion = suggestion
        self.singular = singular
    }

    public func cost(in tier: QuotaTierType, for level: QuotaLevelType) throws -> Double {
        let adjusted = try self.adjusted(to: tier, for: level)
        return try travelCost.cost(for: adjusted)
    }

    public func base(in tier: QuotaTierType, for level: QuotaLevelType) throws -> Double {
        let adjusted = try self.adjusted(to: tier, for: level)
        return try adjusted.base(using: base)
    }

    public func adjusted(to tier: QuotaTierType, for level: QuotaLevelType) throws -> SessionCountEstimationObject {
        switch tier {
        case .combined:
            switch level {
                case .singular:
                return try singular.adjust(to: .combined)
                case .suggestion:
                return try suggestion.adjust(to: .combined)
                case .prognosis:
                return try prognosis.adjust(to: .combined)
            }

        case .local:
            switch level {
                case .singular:
                return try singular.adjust(to: .local)
                case .suggestion:
                return try suggestion.adjust(to: .local)
                case .prognosis:
                return try prognosis.adjust(to: .local)
            }

        case .remote:
            switch level {
                case .singular:
                return try singular.adjust(to: .remote)
                case .suggestion:
                return try suggestion.adjust(to: .remote)
                case .prognosis:
                return try prognosis.adjust(to: .remote)
            }
        }
    }

    public func level(in tier: QuotaTierType, for level: QuotaLevelType) throws -> QuotaTierLevelContent {
        let b = try base(in: tier, for: level)
        let c = try cost(in: tier, for: level)
        let p = b + c
        return QuotaTierLevelContent(
            rate: QuotaRate(
                base: b,
                cost: c,
                price: p
            ),
            estimation: try adjusted(to: tier, for: level)
        )
    }

    public func levels(in tier: QuotaTierType) throws -> QuotaTierLevels {
        let prognosis = try self.level(in: tier, for: .prognosis)
        let suggestion = try self.level(in: tier, for: .suggestion)
        let singular = try self.level(in: tier, for: .singular)

        return try QuotaTierLevels(
            prognosis: prognosis,
            suggestion: suggestion,
            singular: singular
        )
    }

    public func tier(being type: QuotaTierType) throws -> QuotaTierContent {
        let levels = try self.levels(in: type)
        return QuotaTierContent(
            tier: type,
            levels: levels
        )
    }

    public func tiers() throws -> [QuotaTierContent] {
        var contents: [QuotaTierContent] = []
        for i in QuotaTierType.allCases {
            let tier = try self.tier(being: i)
            contents.append(tier)
        }
        return contents
    }

    public func inputs() -> String {
        let settings = """
        kilometers: \(travelCost.kilometers)
            at:
                \(travelCost.rates.time) / hr
                \(travelCost.rates.travel) / km
                \(travelCost.speed) km/hr
            for: 
                \(travelCost.traveledHours()) hours
        cost per session: \(travelCost.total())

        using base rate: \(base)

        estimation:
            prognosis: \(prognosis.count) sessions
                remote: \(prognosis.remote)
                local: \(prognosis.local)
            suggestion: \(suggestion.count) sessions
                remote: \(suggestion.remote)
                local: \(suggestion.local)
            singular: \(suggestion.count) sessions
                remote: \(singular.remote)
                local: \(singular.local)
        """

        return settings
    }

    public func shortInputs(for tier: QuotaTierType) throws -> String {
        let t = try self.tier(being: tier)

        let settings = """
        (base: \(base), kilometers: \(travelCost.kilometers))

        \(t.settingsString(for: tier))

        \(t.priceString(for: tier))
        """

        return settings
    }

    public func quotaSummary() throws -> String {
        let contents = try self.tiers()

        return """
        \(self.inputs())

        \(contents.table(by: .rate))
        """
    }
}

public struct QuotaTierContent: Sendable {
    public let tier: QuotaTierType
    public let levels: QuotaTierLevels

    public init(
        tier: QuotaTierType,
        levels: QuotaTierLevels,
    ) {
        self.tier = tier
        self.levels = levels
    }

    public func settingsString(for tier: QuotaTierType) -> String {
        let singularLocation = levels.singular.estimation.local == 1 ? "l" : "r"

        let settings = """
        for service:
            prognosis: \(levels.prognosis.estimation.count) (r: \(levels.prognosis.estimation.remote), l: \(levels.prognosis.estimation.local))
            suggestion: \(levels.suggestion.estimation.count) (r: \(levels.suggestion.estimation.remote), l: \(levels.suggestion.estimation.local))
            singular: (r/l: \(singularLocation))
        """
        return settings
    }

    public func priceString(for tier: QuotaTierType) -> String {
        let price = """
        price:
            prognosis: \(levels.prognosis.rate.price.rounded())
            suggestion: \(levels.suggestion.rate.price.rounded()) 
            singular: \(levels.singular.rate.price.rounded())
        """
        return price
    }
}
