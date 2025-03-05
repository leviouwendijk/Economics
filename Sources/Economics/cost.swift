import Foundation

public enum CostType {
    case fixed, variable 
}

public struct Cost {
    public let type: CostType
    public let value: Double

    public init(type: CostType, value: Double) {
        self.type = type
        self.value = value
    }
}

public struct Costs {
    public let costs: [Cost]
    public let rounding: Bool

    public init(costs: [Cost], rounding: Bool = false) {
        self.costs = costs
        self.rounding = rounding
    }

    public func fixed() -> Double {
        var output = 0.0
        for i in costs where i.type == .fixed {
            output += i.value
        }
        return rounding ? roundToTwoDecimals(output) : output
    }

    public func variable(sales: Int) -> Double {
        var output = 0.0
        for i in costs where i.type == .variable {
            output += (i.value * Double(sales))
        }
        return rounding ? roundToTwoDecimals(output) : output
    }

    public func total(sales: Int) -> Double {
        let result = fixed() + variable(sales: sales)
        return rounding ? roundToTwoDecimals(result) : result
    }
}
