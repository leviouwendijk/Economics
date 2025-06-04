import Foundation

public enum TableOrganizationStructureType {
    case level
    case rate
}

extension QuotaTierContent {
    func levelContent(_ level: QuotaLevelType) -> QuotaTierLevelContent {
        switch level {
        case .prognosis:  return levels.prognosis
        case .suggestion: return levels.suggestion
        case .singular:   return levels.singular
        }
    }
}

extension Array where Element == QuotaTierContent {
    public func table(by structure: TableOrganizationStructureType) -> String {
        switch structure {
            case .level:
            return self.tableByLevel()
            case .rate:
            return self.tableByRate()
        }
    }

    public func tableByLevel(
        orderedTiers: [QuotaTierType] = [.local, .combined, .remote],
        padding: Int = 8
    ) -> String {
        var allLines: [String] = []

        for levelCase in QuotaLevelType.allCases {
            allLines.append("\(levelCase.rawValue):")

            var rows: [[String]] = []
            rows.append([""] + orderedTiers.map { $0.rawValue })

            let makeRow: (String, (QuotaTierLevelContent) -> Double) -> [String] = { label, extractor in
                var row = [label]
                for tier in orderedTiers {
                    guard let content = self.first(where: { $0.tier == tier }) else {
                        row.append("-")
                        continue
                    }
                    let lvl = content.levelContent(levelCase)
                    row.append(String(format: "%.2f", extractor(lvl)))
                }
                return row
            }

            rows.append(makeRow("price") { $0.rate.price })
            rows.append(makeRow("cost")  { $0.rate.cost  })
            rows.append(makeRow("base")  { $0.rate.base  })

            let rendered = renderTable(rows, padding: padding)
            allLines.append(contentsOf: rendered)
            allLines.append("")
        }

        return allLines.joined(separator: "\n")
    }

    public func tableByRate(
        orderedTiers: [QuotaTierType] = [.local, .combined, .remote],
        padding: Int = 8
    ) -> String {
        var allLines: [String] = []

        for rateKey in ["price", "cost", "base"] {
            allLines.append("\(rateKey):")

            var rows: [[String]] = []
            rows.append([""] + orderedTiers.map { $0.rawValue })

            let makeRow: (QuotaLevelType) -> [String] = { levelCase in
                var row = [levelCase.rawValue]
                for tier in orderedTiers {
                    guard let content = self.first(where: { $0.tier == tier }) else {
                        row.append("-")
                        continue
                    }
                    let lvl = content.levelContent(levelCase)
                    let value: Double = {
                        switch rateKey {
                        case "price": return lvl.rate.price
                        case "cost":  return lvl.rate.cost
                        default:      return lvl.rate.base
                        }
                    }()
                    row.append(String(format: "%.2f", value))
                }
                return row
            }

            for levelCase in QuotaLevelType.allCases {
                rows.append(makeRow(levelCase))
            }

            let rendered = renderTable(rows, padding: padding)
            allLines.append(contentsOf: rendered)
            allLines.append("")
        }

        return allLines.joined(separator: "\n")
    }
}

///   func tableByLevel returns:
///
///   prognosis:
///                local          combined        remote
///   -------------------------------------------------------
///   price         1050.00        1065.62         1096.88
///   cost          0.00           15.62           46.88
///   base          1050.00        1050.00         1050.00
///
///   suggestion:
///                local          combined        remote
///   -------------------------------------------------------
///   price         1050.00        1065.62         1096.88
///   cost          0.00           15.62           46.88
///   base          1050.00        1050.00         1050.00
///
///   singular:
///                local          combined        remote
///   -------------------------------------------------------
///   price         1050.00        1065.62         1096.88
///   cost          0.00           15.62           46.88
///   base          1050.00        1050.00         1050.00


///   func tableByRate returns:
///   
///   price:
///                local          combined        remote
///   -------------------------------------------------------
///   prognosis     1050.00        1065.62         1096.88
///   suggestion    0.00           15.62           46.88
///   singular      1050.00        1050.00         1050.00
///
///   cost:
///                local          combined        remote
///   -------------------------------------------------------
///   prognosis     1050.00        1065.62         1096.88
///   suggestion    0.00           15.62           46.88
///   singular      1050.00        1050.00         1050.00
///
///   base:
///                local          combined        remote
///   -------------------------------------------------------
///   prognosis     1050.00        1065.62         1096.88
///   suggestion    0.00           15.62           46.88
///   singular      1050.00        1050.00         1050.00
