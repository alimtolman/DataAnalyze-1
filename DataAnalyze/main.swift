import Foundation

print("Temperature\t| Wind speed\t| Sensible temperature")
print("------------------------------------------------------------")

let data = [[25,10,20],[24,12,18],[26,15,15],[23,8,19],[22,7,17],[27,18,12],[28,20,10],[25,10,20],[26,14,15],[24,11,18],[23,9,17],[26,16,14],[27,17,12],[24,13,16],[25,11,15],[28,19,10],[29,22,8],[22,6,19],[23,8,17],[26,16,14],[27,18,12],[25,12,16],[24,10,18],[23,7,17],[22,6,19],[26,15,15],[27,17,12],[28,21,10],[25,11,15],[26,14,14],[24,12,16],[23,9,17],[26,17,14],[27,19,12],[24,13,16],[25,10,15],[28,20,10],[29,23,8],[22,5,19],[23,7,17],[26,16,14],[27,17,12],[25,12,16],[24,10,18],[23,8,17],[22,6,19],[26,17,15],[27,19,12],[28,20,10],[25,11,15],[26,14,14],[24,10,16],[23,8,17]]

let count = data.count
let minMax = findMinMax(data)
let values = initializeValues(data)
var x1Values = calculateNormalValues(values[0], minMax: minMax[0])
var x2Values = calculateNormalValues(values[1], minMax: minMax[1])
var yValues = calculateNormalValues(values[2], minMax: minMax[2])

x1Values = calculateFuncValues(x1Values)
x2Values = calculateFuncValues(x2Values)
yValues = calculateFuncValues(yValues)

var rules: [Rule] = []
var uniqueRules: [[String]: Rule] = [:]

for i in 0 ..< count {
    let x1 = x1Values[i]
    let x2 = x2Values[i]
    let y = yValues[i]
    
    rules.append(createFinalRule(values: [x1, x2, y]))
    print(x1.value, "\t| ", x2.value, "\t| ", y.value)
}


print("\nNormalized data")
print("Temperature\t| Wind speed\t| Sensible temperature")
print("------------------------------------------------------------")

for i in 0 ..< count {
    let x1 = x1Values[i]
    let x2 = x2Values[i]
    let y = yValues[i]
    
    print(x1.normalValue, "\t| ", x2.normalValue, "\t| ", y.normalValue)
}


print("\nRules")
print("x1\t&\tx2\t->\ty\t|\tSP")
print("------------------------------")

for rule in rules {
    if let _rule = uniqueRules[rule.xSymbols] {
        if rule.sp > _rule.sp {
            uniqueRules[rule.xSymbols] = rule
        }
    }
    else {
        uniqueRules[rule.xSymbols] = rule
    }
    
    print(rule.toString())
}


print("\nUnique Rules")
print("x1\t&\tx2\t->\ty\t|\tSP")
print("------------------------------")

for key in uniqueRules.keys {
    let rule = uniqueRules[key]!
    
    print(rule.toString())
}


print("\nDefuzzification")
print("------------------------------")

var randomX1 = [Value(normalValue: 1.24), Value(normalValue: 8.46), Value(normalValue: 3.79)]
var randomX2 = [Value(normalValue: 2.97), Value(normalValue: 5.42), Value(normalValue: 2.17)]

randomX1 = calculateFuncValues(randomX1)
randomX2 = calculateFuncValues(randomX2)

for i in 0 ..< randomX1.count {
    var numerator: Float = 0
    var denominator: Float = 0
    
    for key in uniqueRules.keys {
        let rule = uniqueRules[key]!
        let defuz = check(rule, for: [randomX1[i], randomX2[i]])
        let ySymbol = uniqueRules[defuz.xSymbols]?.ySymbol ?? "UNKNOWN"
        let yValue = solveEquation(values: defuz.mu, ySymbol: ySymbol)
        
        if yValue == -1 {
            continue
        }
         
        numerator += yValue * defuz.tau
        denominator += defuz.tau
        
        print(defuz.toString(), " | y = ", ySymbol, " |  y = ", yValue)
    }
    
    if numerator > 0 && denominator > 0 {
        print("final y = ", numerator / denominator, "\n")
    }
}
