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
        padding: Int = 2,
        /// If `true`, each cell shows the full “prognosis/suggestion/base” text;
        /// if `false`, it shows only the `suggestion`.
        showAllFields: Bool = false
    ) -> String {
        let contentsByTier: [QuotaTierType: QuotaTierContent] =
            Dictionary(uniqueKeysWithValues: self.map { ($0.tier, $0) })

        var rows: [[String]] = []

        let headerRow: [String] = [""] + orderedTiers.map { $0.rawValue }
        rows.append(headerRow)

        var priceRow: [String] = ["price"]
        for tier in orderedTiers {
            if let content = contentsByTier[tier] {
                // Use your custom string(all:)
                priceRow.append(content.price.string(all: showAllFields))
            } else {
                priceRow.append("-")
            }
        }
        rows.append(priceRow)

        if includeCost {
            var costRow: [String] = ["cost"]
            for tier in orderedTiers {
                if let content = contentsByTier[tier] {
                    costRow.append(content.cost.string(all: showAllFields))
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
                    baseRow.append(content.base.string(all: showAllFields))
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
                if cell.count > maxWidths[i] {
                    maxWidths[i] = cell.count
                }
            }
        }

        var lines: [String] = []

        let padBetween = String(repeating: " ", count: padding)
        let headerCells = zip(rows[0], maxWidths).map { (cell, width) -> String in
            let extra = width - cell.count
            let left = extra / 2
            let right = extra - left
            return String(repeating: " ", count: left)
                 + cell
                 + String(repeating: " ", count: right)
        }
        lines.append(headerCells.joined(separator: padBetween))

        for rowIndex in 1..<rows.count {
            let row = rows[rowIndex]
            var paddedCells: [String] = []
            for (i, cell) in row.enumerated() {
                let paddingNeeded = maxWidths[i] - cell.count
                let leftAligned = cell + String(repeating: " ", count: paddingNeeded)
                paddedCells.append(leftAligned)
            }
            lines.append(paddedCells.joined(separator: padBetween))
        }

        return lines.joined(separator: "\n")
    }
}
