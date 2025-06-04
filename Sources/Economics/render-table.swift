import Foundation

public func renderTable(
    _ rows: [[String]],
    padding: Int
) -> [String] {
    let columnCount = rows.first?.count ?? 0
    var maxWidths = [Int](repeating: 0, count: columnCount)
    for row in rows {
        for (i, cell) in row.enumerated() {
            maxWidths[i] = Swift.max(maxWidths[i], cell.count)
        }
    }

    let padBetween = String(repeating: " ", count: padding)

    let header = zip(rows[0], maxWidths).map { cell, width -> String in
        let extra = width - cell.count
        let left  = extra / 2
        let right = extra - left
        return String(repeating: " ", count: left)
             + cell
             + String(repeating: " ", count: right)
    }.joined(separator: padBetween)

    let separator = String(
        repeating: "-",
        count: header.count
    )

    var output = [header, separator]
    for rowIndex in 1..<rows.count {
        let row = rows[rowIndex]
        let padded = row.enumerated().map { i, cell in
            let extra = maxWidths[i] - cell.count
            return cell + String(repeating: " ", count: extra)
        }
        output.append(padded.joined(separator: padBetween))
    }
    return output
}
