import Foundation

public func roundToTwoDecimals(_ value: Double) -> Double {
    return (value * 100).rounded() / 100
}
