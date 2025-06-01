import Foundation

public enum TravelCostRateType {
    case travel
    case time
}

public struct TravelCostRates {
    public let travel: Double
    public let time: Double

    public init(
        travel: Double,
        time: Double
    ) {
        self.travel = travel
        self.time = time
    }
}

public struct TravelCost {
    public let kilometers: Double
    public let speed: Double
    public let rates: TravelCostRates
    public let roundTrip: Bool

    public init(
        kilometers: Double,
        speed: Double = 80.0,
        rates: TravelCostRates,
        roundTrip: Bool
    ) {
        self.kilometers = kilometers
        self.speed = speed
        self.rates = rates
        self.roundTrip = roundTrip
    }

    public func calculate(for type: TravelCostRateType) -> Double {
        switch type {
            case .travel: 
            return rates.travel * kilometers
            case .time:
            return rates.time * traveledHours()
        }
    }

    public func traveledHours() -> Double {
        return kilometers / speed
    }
}

public func timeCost(hours: Double, rate: Double) -> Double {
    return hours * rate
}
