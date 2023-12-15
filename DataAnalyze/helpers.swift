import Foundation

let indexSymbols = ["S", "ML", "MR", "L"]
let normalUpper: Float = 10
let normalHalf: Float = 5


func findMinMax(_ data: [[Int]]) -> [MinMax] {
    var minMax: [MinMax] = []
    
    for item in data[0] {
        minMax.append(MinMax(min: item, max: item))
    }
    
    for row in data {
        for i in 0 ..< row.count {
            let item = row[i]
            
            minMax[i].min = min(minMax[i].min, item)
            minMax[i].max = max(minMax[i].max, item)
        }
    }
    
    return minMax
}

func initializeValues(_ data: [[Int]]) -> [[Value]] {
    var values: [[Value]] = Array(repeating: [], count: data[0].count)
    
    for row in data {
        for i in 0 ..< row.count {
            values[i].append(Value(value: row[i], normalValue: 0, small: 0, mediumLeft: 0, mediumRight: 0, large: 0))
        }
    }
    
    return values
}

func calculateNormalValues(_ data: [Value], minMax: MinMax) -> [Value] {
    var result = data
    
    for i in 0 ..< result.count {
        result[i].normalValue = Float(result[i].value - minMax.min) / Float(minMax.max - minMax.min)
        result[i].normalValue *= normalUpper
    }
    
    return result
}

func calculateFuncValues(_ data: [Value]) -> [Value] {
    var result = data
    
    for i in 0 ..< result.count {
        let normalValue = result[i].normalValue
        let small = (normalHalf - normalValue) / normalHalf
        let mediumLeft = normalValue / normalHalf
        let mediumRight = (normalUpper - normalValue) / normalHalf
        let large = (normalValue - normalHalf) / normalHalf
        
        result[i].small = (small < 0.0 || small > 1.0) ? 0.0 : small
        result[i].mediumLeft = (mediumLeft < 0.0 || mediumLeft > 1.0) ? 0.0 : mediumLeft
        result[i].mediumRight = (mediumRight < 0.0 || mediumRight > 1.0) ? 0.0 : mediumRight
        result[i].large = (large < 0.0 || large > 1.0) ? 0.0 : large
    }
    
    return result
}

func findMaxSymbol(in value: Value) -> MaxSymbol {
    var result = MaxSymbol(max: value.small, symbol: indexSymbols[0])
    
    if value.mediumLeft >= result.max {
        result.max = value.mediumLeft
        result.symbol = indexSymbols[1]
    }
    
    if value.mediumRight >= result.max {
        result.max = value.mediumRight
        result.symbol = indexSymbols[2]
    }
    
    if value.large >= result.max {
        result.max = value.large
        result.symbol = indexSymbols[3]
    }
    
    return result
}

func createFinalRule(values: [Value]) -> Rule {
    var rule = Rule(xSymbols: [], ySymbol: String(), sp: 1.0)
    
    for i in 0 ..< values.count {
        let value = values[i]
        let maxSymbol = findMaxSymbol(in: value)
        
        if i < values.count - 1 {
            rule.xSymbols.append(maxSymbol.symbol)
        } else {
            rule.ySymbol = maxSymbol.symbol
        }
        
        rule.sp *= maxSymbol.max
    }

    return rule
}

func check(_ rule: Rule, for values: [Value]) -> Defuz {
    let valuesCount = values.count
    var result = Defuz(xSymbols: [], mu: [], tau: 1)
    
    for i in 0 ..< valuesCount {
        let xSymbol = rule.xSymbols[i]
        let value = values[i]
        
        switch xSymbol {
        case indexSymbols[0]: // S
            let small = value.small
            
            result.xSymbols += small > 0 ? [xSymbol] : []
            result.mu += small > 0 ? [small] : []
            result.tau *= small > 0 ? small : 1
        case indexSymbols[1]: // ML
            let mediumLeft = value.mediumLeft
            
            result.xSymbols += mediumLeft > 0 ? [xSymbol] : []
            result.mu += mediumLeft > 0 ? [mediumLeft] : []
            result.tau *= mediumLeft > 0 ? mediumLeft : 1
        case indexSymbols[2]: // MR
            let mediumRight = value.mediumRight
            
            result.xSymbols += mediumRight > 0 ? [xSymbol] : []
            result.mu += mediumRight > 0 ? [mediumRight] : []
            result.tau *= mediumRight > 0 ? mediumRight : 1
        case indexSymbols[3]: // L
            let large = value.large
            
            result.xSymbols += large > 0 ? [xSymbol] : []
            result.mu += large > 0 ? [large] : []
            result.tau *= large > 0 ? large : 1
        default:
            result.xSymbols = []
            result.mu = []
            result.tau = 0
        }
    }
    
    return result
}

func solveEquation(values: [Float], ySymbol: String) -> Float {
    var minVal = Float.infinity
    var result: Float = 0
    
    for value in values {
        minVal = min(minVal, value)
    }
    
    switch ySymbol {
    case indexSymbols[0]: // S
        result = normalHalf - normalHalf * minVal
    case indexSymbols[1]: // ML
        result = normalHalf * minVal
    case indexSymbols[2]: // MR
        result = normalUpper - normalHalf * minVal
    case indexSymbols[3]: // L
        result = normalHalf * minVal + normalHalf
    default:
        result = -1
    }
    
    return result
}
