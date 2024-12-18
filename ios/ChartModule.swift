import Foundation
import React

struct DataPoint: Encodable {
    let value: Int
}

@objc(ChartModule)
class ChartModule: NSObject {
  
  func generateRandomDataPoints(count: Int = 30, range: ClosedRange<Int> = 0...10) -> [[String: Any]] {
    var data: [[String: Any]] = []
        
    for _ in 1...count {
      let randomValue = Int.random(in: range)
      data.append(["value": randomValue])
    }

    return data
  }
  
  @MainActor @objc
  func fetchOpenAttemptsData(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    
    let randomData = generateRandomDataPoints()
    
    resolve([
      "dailyAverage": 100,
      "percentage": "30%",
      "data": randomData
    ])
  }
}
