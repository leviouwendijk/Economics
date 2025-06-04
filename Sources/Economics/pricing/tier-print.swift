import Foundation

public enum TableOrganizationStructureType {
    case level
    case rate
}

extension Array where Element == QuotaTierContent {
    // public func string(
    //     cost: Bool = true,
    //     base: Bool = true
    // ) -> String {
    //     var str = ""
    //     for t in self {
    //         str.append(t.string())
    //         str.append("\n")
    //     }
    //     return str.trimmingCharacters(in: .whitespacesAndNewlines)
    // }

    public func table(by structure: TableOrganizationStructureType) -> String {
        switch structure {
            case .level:
            return self.tableByLevel()
            case .rate:
            return self.tableByRate()
        }
    }

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
    public func tableByLevel(
        orderedTiers: [QuotaTierType] = [.local, .combined, .remote],
        padding: Int = 8
    ) -> String {
        var allLines: [String] = []

        for levelCase in QuotaLevelType.allCases {
            allLines.append("\(levelCase.rawValue):")

            var rows: [[String]] = []

            let headerRow: [String] = [""] + orderedTiers.map { $0.rawValue }
            rows.append(headerRow)

            var priceRow: [String] = ["price"]
            for tier in orderedTiers {
                if let content = self.first(where: { $0.tier == tier }),
                   let lvl = content.levels.first(where: { $0.level == levelCase })
                {
                    priceRow.append(String(format: "%.2f", lvl.rate.price))
                } else {
                    priceRow.append("-")
                }
            }
            rows.append(priceRow)

            var costRow: [String] = ["cost"]
            for tier in orderedTiers {
                if let content = self.first(where: { $0.tier == tier }),
                   let lvl = content.levels.first(where: { $0.level == levelCase })
                {
                    costRow.append(String(format: "%.2f", lvl.rate.cost))
                } else {
                    costRow.append("-")
                }
            }
            rows.append(costRow)

            var baseRow: [String] = ["base"]
            for tier in orderedTiers {
                if let content = self.first(where: { $0.tier == tier }),
                   let lvl = content.levels.first(where: { $0.level == levelCase })
                {
                    baseRow.append(String(format: "%.2f", lvl.rate.base))
                } else {
                    baseRow.append("-")
                }
            }
            rows.append(baseRow)

            let columnCount = rows.first?.count ?? 0
            var maxWidths = [Int](repeating: 0, count: columnCount)
            for row in rows {
                for (i, cell) in row.enumerated() {
                    maxWidths[i] = Swift.max(maxWidths[i], cell.count)
                }
            }

            let padBetween = String(repeating: " ", count: padding)
            let headerCells = zip(rows[0], maxWidths).map { (cell, width) -> String in
                let extra = width - cell.count
                let left  = extra / 2
                let right = extra - left
                return String(repeating: " ", count: left)
                     + cell
                     + String(repeating: " ", count: right)
            }
            allLines.append(headerCells.joined(separator: padBetween))

            let separatorLine = String(repeating: "-", count: headerCells.joined(separator: padBetween).count)
            allLines.append(separatorLine)

            for rowIndex in 1..<rows.count {
                let row = rows[rowIndex]
                let padded = row.enumerated().map { (i, cell) in
                    let extra = maxWidths[i] - cell.count
                    return cell + String(repeating: " ", count: extra)
                }
                allLines.append(padded.joined(separator: padBetween))
            }

            allLines.append("")
        }
        return allLines.joined(separator: "\n")
    }


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
    public func tableByRate(
        orderedTiers: [QuotaTierType] = [.local, .combined, .remote],
        padding: Int = 8
    ) -> String {
        var allLines: [String] = []

        for rateKey in ["price", "cost", "base"] {
            allLines.append("\(rateKey):")

            var rows: [[String]] = []

            let headerRow: [String] = [""] + orderedTiers.map { $0.rawValue }
            rows.append(headerRow)

            for levelCase in QuotaLevelType.allCases {
                var row: [String] = [levelCase.rawValue]

                for tier in orderedTiers {
                    if let content = self.first(where: { $0.tier == tier }),
                       let lvl = content.levels.first(where: { $0.level == levelCase })
                    {
                        let value: Double
                        switch rateKey {
                        case "price": value = lvl.rate.price
                        case "cost":  value = lvl.rate.cost
                        default:      value = lvl.rate.base
                        }
                        row.append(String(format: "%.2f", value))
                    } else {
                        row.append("-")
                    }
                }

                rows.append(row)
            }

            let columnCount = rows.first?.count ?? 0
            var maxWidths = [Int](repeating: 0, count: columnCount)
            for row in rows {
                for (i, cell) in row.enumerated() {
                    maxWidths[i] = Swift.max(maxWidths[i], cell.count)
                }
            }

            let padBetween = String(repeating: " ", count: padding)
            let headerCells = zip(rows[0], maxWidths).map { (cell, width) -> String in
                let extra = width - cell.count
                let left  = extra / 2
                let right = extra - left
                return String(repeating: " ", count: left)
                     + cell
                     + String(repeating: " ", count: right)
            }
            allLines.append(headerCells.joined(separator: padBetween))

            let separatorLine = String(
                repeating: "-",
                count: headerCells.joined(separator: padBetween).count
            )
            allLines.append(separatorLine)

            for rowIndex in 1..<rows.count {
                let row = rows[rowIndex]
                let padded = row.enumerated().map { (i, cell) in
                    let extra = maxWidths[i] - cell.count
                    return cell + String(repeating: " ", count: extra)
                }
                allLines.append(padded.joined(separator: padBetween))
            }

            allLines.append("")
        }
        return allLines.joined(separator: "\n")
    }
}
