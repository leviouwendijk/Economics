import Foundation

public enum StandardVAT {
    case netherlands, belgium
    case unitedKingdom, france
    case germany
    case luxembourg, israel
    case norway, croatia, denmark, sweden
    case portugal, poland

    var rate: Double {
        switch self {
        case .netherlands, .belgium: return 21
        case .unitedKingdom, .france: return 20
        case .germany: return 19
        case .luxembourg, .israel: return 17
        case .norway, .croatia, .denmark, .sweden: return 25
        case .portugal, .poland: return 23
        }
    }
}

public func standardVAT(_ country: StandardVAT) -> Double {
    return country.rate
}

public enum VAT {
    case vat
    case revenue
}

public protocol ValueAddedTaxableDouble {
    func vat(_ vatRate: Double, _ calculatedValue: VAT) -> Double
}

public protocol ValueAddedTaxableInt {
    func vat(_ vatRate: Double, _ calculatedValue: VAT) -> Int
}

extension Double: ValueAddedTaxableDouble {
    public func vat(_ vatRate: Double = standardVAT(.netherlands), _ calculatedValue: VAT = .vat) -> Double {
        switch calculatedValue {
        case .vat:
            return (self / (100.0 + vatRate)) * vatRate
        case .revenue:
            return (self / (100.0 + vatRate)) * 100.0
        }
    }
}

extension Int: ValueAddedTaxableInt {
    public func vat(_ vatRate: Double = standardVAT(.netherlands), _ calculatedValue: VAT = .vat) -> Int {
        let doubleValue = Double(self)
        let result: Double
        
        switch calculatedValue {
        case .vat:
            result = (doubleValue / (100.0 + vatRate)) * vatRate
        case .revenue:
            result = (doubleValue / (100.0 + vatRate)) * 100.0
        }
        
        return Int(result.rounded())
    }
}
