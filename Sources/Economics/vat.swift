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

public enum VATInputValue {
    case vat
    case net
    case gross
}

public enum VATResultValue {
    case vat
    case revenue
    case receivable
}

public protocol ValueAddedTaxableDouble {
    func vat(
        _ rate: Double,
        using input: VATInputValue,
        returning result: VATResultValue
    ) -> Double
}

public protocol ValueAddedTaxableInt {
    func vat(
        _ rate: Double,
        using input: VATInputValue,
        returning result: VATResultValue
    ) -> Int
}

extension Double: ValueAddedTaxableDouble {
    public func vat(
        _ rate: Double = standardVAT(.netherlands),
        using input: VATInputValue = .gross,
        returning result: VATResultValue = .vat
    ) -> Double {
        let net: Double
        let vat: Double
        let gross: Double

        switch input {
        case .gross:
            gross = self
            net   = (self / (100.0 + rate)) * 100.0
            vat   = (self / (100.0 + rate)) * rate

        case .net:
            net   = self
            vat   = (net * rate) / 100.0
            gross = net + vat

        case .vat:
            vat   = self
            net   = (vat / rate) * 100.0
            gross = net + vat
        }

        switch result {
        case .vat:
            return vat
        case .revenue:
            return net
        case .receivable:
            return gross
        }
    }
}

extension Int: ValueAddedTaxableInt {
    public func vat(
        _ rate: Double = standardVAT(.netherlands),
        using input: VATInputValue = .gross,
        returning result: VATResultValue = .vat
    ) -> Int {
        let doubleValue = Double(self)
        let computed = doubleValue.vat(rate, using: input, returning: result)
        return Int(computed.rounded())
    }
}
