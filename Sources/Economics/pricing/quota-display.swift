import Foundation
import Extensions
import plate

public enum QuotaPriceDisplayPolicy: Sendable {
    case raw
    case rounded(
            multiple: Double = 10,
            direction: RoundingOffsetDirection = .down,
            offset: Double = 1.0,
            integer: Bool = true
        )
}
