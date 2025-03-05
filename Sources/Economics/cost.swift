import Foundation

public enum CostType {
    case fixed, variable 
}

public struct Cost {
    public let type: CostType
    public let value: Double
}

public struct Costs {
    public let costs: [Cost]

    public func fixed() -> Double {
        var output = 0.0
        for i in costs where i.type == .fixed {
            output += i.value
        }
        return output
    }

    public func variable(sales: Int) -> Double {
        var output = 0.0
        for i in costs where i.type == .variable {
            output += (i.value * Double(sales))
        }
        return output
    }

    public func total(sales: Int) -> Double {
        return fixed() + variable(sales: sales)
    }
}
