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
        rates: TravelCostRates = TravelCostRates(travel: 0.25, time: 105),
        roundTrip: Bool = true
    ) {
        self.kilometers = kilometers
        self.speed = speed
        self.rates = rates
        self.roundTrip = roundTrip
    }

    public func calculate(for type: TravelCostRateType) -> Double {
        var result = 0.0
        switch type {
            case .travel: 
            result = rates.travel * kilometers
            case .time:
            result = rates.time * traveledHours()
        }

        return roundTrip ? (result * 2) : result
    }

    public func traveledHours() -> Double {
        return kilometers / speed
    }
}

public func timeCost(hours: Double, rate: Double) -> Double {
    return hours * rate
}
