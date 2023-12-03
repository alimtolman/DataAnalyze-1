import Foundation

struct Value {
    public var value: Int
    public var normalValue: Float
    public var small: Float
    public var mediumLeft: Float
    public var mediumRight: Float
    public var large: Float
    
    init(value: Int, normalValue: Float, small: Float, mediumLeft: Float, mediumRight: Float, large: Float) {
        self.value = value
        self.normalValue = normalValue
        self.small = small
        self.mediumLeft = mediumLeft
        self.mediumRight = mediumRight
        self.large = large
    }
    
    init(normalValue: Float) {
        self.value = 0
        self.normalValue = normalValue
        self.small = 0
        self.mediumLeft = 0
        self.mediumRight = 0
        self.large = 0
    }
}

struct MinMax {
    public var min: Int
    public var max: Int
}

struct MaxSymbol {
    public var max: Float
    public var symbol: String
}

struct Rule {
    public var xSymbols: [String]
    public var ySymbol: String
    public var sp: Float
    
    public func toString() -> String {
        var result = String()
        
        result = xSymbols.joined(separator: "\t&\t")
        
        if !ySymbol.isEmpty {
            result += "\t->\t" + ySymbol
        }
        
        result += " | sp = " + String(sp)
        
        return result
    }
}

struct Defuz {
    public var xSymbols: [String]
    public var mu: [Float]
    public var tau: Float
    
    public func toString() -> String {
        var result = String()
        
        result = xSymbols.joined(separator: "\t&\t")
        result += " | mu = " + mu.description
        result += " | tau = " + String(tau)
        
        return result
    }
}
