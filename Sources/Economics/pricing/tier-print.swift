import Foundation

extension Array where Element == QuotaTierContent {
    public func string(
        cost: Bool = true,
        base: Bool = true
    ) -> String {
        var str = ""
        for t in self {
            str.append(t.string())
            str.append("\n")
        }
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func table(
        orderedTiers: [QuotaTierType] = [.local, .combined, .remote],
        includeCost: Bool = true,
        includeBase: Bool = true,
        padding: Int = 2
    ) -> String {
        let contentsByTier: [QuotaTierType: QuotaTierContent] =
            Dictionary(uniqueKeysWithValues: self.map { ($0.tier, $0) })

        var rows: [[String]] = []

        let headerRow: [String] = [""] + orderedTiers.map { $0.rawValue }
        rows.append(headerRow)

        var priceRow: [String] = ["price"]
        for tier in orderedTiers {
            if let content = contentsByTier[tier] {
                priceRow.append("\(content.price)")
            } else {
                priceRow.append("-") // or ""
            }
        }
        rows.append(priceRow)

        if includeCost {
            var costRow: [String] = ["cost"]
            for tier in orderedTiers {
                if let content = contentsByTier[tier] {
                    costRow.append("\(content.cost)")
                } else {
                    costRow.append("-")
                }
            }
            rows.append(costRow)
        }

        if includeBase {
            var baseRow: [String] = ["base"]
            for tier in orderedTiers {
                if let content = contentsByTier[tier] {
                    baseRow.append("\(content.base)")
                } else {
                    baseRow.append("-")
                }
            }
            rows.append(baseRow)
        }

        let columnCount = rows.first?.count ?? 0
        var maxWidths: [Int] = [Int](repeating: 0, count: columnCount)

        for row in rows {
            for (i, cell) in row.enumerated() {
                let length = cell.count
                if length > maxWidths[i] {
                    maxWidths[i] = length
                }
            }
        }

        var lines: [String] = []
        for row in rows {
            var paddedCells: [String] = []
            for (i, cell) in row.enumerated() {
                let paddingNeeded = maxWidths[i] - cell.count
                let padded = cell + String(repeating: " ", count: paddingNeeded)
                paddedCells.append(padded)
            }
            let pad = String(repeating: " ", count: padding)
            let line = paddedCells.joined(separator: pad)
            lines.append(line)
        }

        return lines.joined(separator: "\n")
    }
}
