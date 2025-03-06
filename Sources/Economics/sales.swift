import Foundation

public struct Product {
    public let name: String
    public let price: Double
    public let sales: Int

    public init(name: String, price: Double, sales: Int) {
        self.name = name
        self.price = price
        self.sales = sales
    }
}

public struct Sales {
    public let products: [Product]

    public init(products: [Product]) {
        self.products = products
    }

    public func revenue() -> Double {
        return products.reduce(0) { $0 + ($1.price * Double($1.sales)) }
    }

    public func sales() -> Int {
        return products.reduce(0) { $0 + $1.sales }
    }

    public func averageSaleValue() -> Double {
        let salesVolume = sales()
        return salesVolume > 0 ? revenue() / Double(salesVolume) : 0
    }
}
