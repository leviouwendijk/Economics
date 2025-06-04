import Foundation

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

    /// Print three little “horizontal” tables—one for each QuotaLevelType (.prognosis, .suggestion, .singular).
    /// Each sub‐table has columns [local, combined, remote] and rows [price, cost, base].
    ///
    /// - Parameters:
    ///   - orderedTiers: in what order to show the columns (default: [.local, .combined, .remote])
    ///   - padding: how many spaces between columns (default: 8)
    ///
    /// - Returns: One big multiline String, e.g.:
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
    public func table(
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
}
