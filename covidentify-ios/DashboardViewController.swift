//
//  ViewController.swift
//  covidentify-ios
//
//  Created by Shun Sakai on 10/4/22.
//

import UIKit
import HealthKit

class DashboardViewController: UIViewController {
    
    
    
    var healthStore: HKHealthStore?
    
    @IBOutlet weak var ShareHealthDataButton: UIButton!
    
    @IBOutlet weak var lastTimeShared: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func buttonTapped(_ sender: Any) {
        healthStore = HKHealthStore()
        queryHeartRate()
        queryStepCount()
        querySleepAnalysis()
    
    }
    
    func postJsonData(jsonString: String) {
        guard let url = URL(string: "https://ios-http-db.azurewebsites.net/api/HttpTrigger-ios"),
              let payload = jsonString.data(using: .utf8)
        else {
            print("URL error")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("text/plain", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        request.timeoutInterval = 1000
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("request, \(response)")
            guard error == nil else { print(error!.localizedDescription); return }
            guard let data = data else { print("Empty data"); return }

            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }.resume()
        
        
    }

    
    func querySleepAnalysis() -> Void {
        guard let sampleSleep = HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            fatalError("*** This method should never fail ***")
        }
        let querySleep = HKSampleQuery(sampleType: sampleSleep, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            
            guard let samples = results as? [HKCategorySample] else {
                // Handle any errors here.
                print("sleep analysis error")
                return
            }
            var myNewDictArray: [Dictionary<String, String>] = []
            var dataType: [String:String] = ["health_data_type": "sleep"]
            myNewDictArray.append(dataType)
            
            for sample in samples {
                // Process each sample here.
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let deviceType : String = sample.device?.hardwareVersion ?? "Watch6,6"
                if (deviceType == "Watch6,6" || deviceType == "Watch6,7" || deviceType == "Watch6,8" || deviceType == "Watch6,9") {
                    if (myNewDictArray.count == 1) {
                        var deviceType: [String:String] = ["apple_watch_type": "series_7"]
                        myNewDictArray.append(deviceType)
                    }
                    var dictEntry: [String:String] = ["participant_id":"8888","device_id": "6666", "start_time":formatter.string(from: sample.startDate), "end_time":formatter.string(from: sample.endDate)]
                    myNewDictArray.append(dictEntry)
                    
                }

            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: myNewDictArray, options: [])
                let theJSONText = String(data: jsonData, encoding: .ascii)
                    print("JSON string = \(theJSONText!)")
                self.postJsonData(jsonString: theJSONText!)
                
            } catch {
                print("error in converting data to json")
            }
            
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                // Update the UI here.
                let date = Date()
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = df.string(from: date)
                self.lastTimeShared.text = dateString
            }
        }
        
        healthStore!.execute(querySleep)
        
    }
    
    
    func queryStepCount() -> Void {
        guard let sampleStep = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** This method should never fail ***")
        }
        let queryStep = HKSampleQuery(sampleType: sampleStep, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
   
            guard let samples = results as? [HKQuantitySample] else {
                // Handle any errors here.
                print("step analysis error")
                return
            }
            
            var myNewDictArray: [Dictionary<String, String>] = []
            var dataType: [String:String] = ["health_data_type": "step_count"]
            myNewDictArray.append(dataType)
            
            for sample in samples {
                // Process each sample here.
                //print("Step quantity: " + "\(sample.quantity)" + " Start Time: " + "\(sample.startDate)" + " End Time: " + "\(sample.endDate)")
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let deviceType : String = sample.device?.hardwareVersion ?? "Watch6,6"
                if (deviceType == "Watch6,6" || deviceType == "Watch6,7" || deviceType == "Watch6,8" || deviceType == "Watch6,9") {
                    if (myNewDictArray.count == 1) {
                        var deviceType: [String:String] = ["apple_watch_type": "series_7"]
                        myNewDictArray.append(deviceType)
                    }
                    var dictEntry: [String:String] = ["participant_id":"8888","device_id": "6666",  "step_count":"\(Int(sample.quantity.doubleValue(for: HKUnit.count())))", "start_time":formatter.string(from: sample.startDate), "end_time":formatter.string(from: sample.endDate)]
                    myNewDictArray.append(dictEntry)
                    
                }

            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: myNewDictArray, options: [])
                let theJSONText = String(data: jsonData, encoding: .ascii)
                    print("JSON string = \(theJSONText!)")
                self.postJsonData(jsonString: theJSONText!)
                
            } catch {
                print("error in converting data to json")
            }
            
            
            
            
            
            
      
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                // Update the UI here.
                print("")
            }
        }
        healthStore!.execute(queryStep)
    }
    
    func queryHeartRate() -> Void {
        guard let sampleHeartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            fatalError("*** This method should never fail ***")
        }
        let queryHeartRate = HKSampleQuery(sampleType: sampleHeartRate, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
   
            guard let samples = results as? [HKQuantitySample] else {
                // Handle any errors here.
                print("heart rate analysis error")
                return
            }
            var myNewDictArray: [Dictionary<String, String>] = []
            var dataType: [String:String] = ["health_data_type": "heart_rate"]
            myNewDictArray.append(dataType)
            
            for sample in samples {
                // Process each sample here.
                // start time and end time should be same for each heart rate sample
//                print("Heart Rate: " + "\(sample.quantity)" + " Start Time: " + "\(sample.startDate)" + " End Time: " + "\(sample.endDate)")
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let deviceType : String = sample.device?.hardwareVersion ?? "Watch6,6"
                if (deviceType == "Watch6,6" || deviceType == "Watch6,7" || deviceType == "Watch6,8" || deviceType == "Watch6,9") {
                    if (myNewDictArray.count == 1) {
                        var deviceType: [String:String] = ["apple_watch_type": "series_7"]
                        myNewDictArray.append(deviceType)
                    }
                    var dictEntry: [String:String] = ["device_id": "6666",  "date":formatter.string(from: sample.startDate), "heart_rate":"\(Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))))", "participant_id":"8888"]
                    myNewDictArray.append(dictEntry)
                    
                }

            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: myNewDictArray, options: [])
                let theJSONText = String(data: jsonData, encoding: .ascii)
                    print("JSON string = \(theJSONText!)")
                self.postJsonData(jsonString: theJSONText!)
                
            } catch {
                print("error in converting data to json")
            }

            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                // Update the UI here.
                print("")
            }
        }
        healthStore!.execute(queryHeartRate)
    }
    
//    func queryActivity() -> Void {
//
//        let calendar = NSCalendar.current
//        let endDate = Date()
//
//        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
//            fatalError("*** Unable to create the start date ***")
//        }
//
//        let units: Set<Calendar.Component> = [.day, .month, .year, .era]
//
//        var startDateComponents = calendar.dateComponents(units, from: startDate)
//        startDateComponents.calendar = calendar
//
//        var endDateComponents = calendar.dateComponents(units, from: endDate)
//        endDateComponents.calendar = calendar
//
//        // Create the predicate for the query
//        let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
//
//
//
//        let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summariesOrNil, errorOrNil) -> Void in
//
//            guard let summaries = summariesOrNil else {
//                // Handle any errors here.
//                print("no summary")
//                return
//            }
//
//            for summary in summaries {
//                // Process each summary here.
//                print(summary)
//            }
//
//            // The results come back on an anonymous background queue.
//            // Dispatch to the main queue before modifying the UI.
//
//            DispatchQueue.main.async {
//                // Update the UI here.
//            }
//        }
//        healthStore!.execute(query)
//    }
//
    
//    @IBAction func clickBlob(_ sender: Any) {
//
//
//    }
    
 
}

