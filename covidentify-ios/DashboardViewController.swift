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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func buttonTapped(_ sender: Any) {
        healthStore = HKHealthStore()
        queryStepCount()
        querySleepAnalysis()
        
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
            print("check here")
            for sample in samples {
                // Process each sample here.
                print(sample)
                print(sample.startDate)
                print(sample.endDate)
                print()
            }
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                // Update the UI here.
                print("")
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
            
            for sample in samples {
                // Process each sample here.
                print(sample)
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
    
    func queryActivity() -> Void {
        
        let calendar = NSCalendar.current
        let endDate = Date()
         
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            fatalError("*** Unable to create the start date ***")
        }

        let units: Set<Calendar.Component> = [.day, .month, .year, .era]

        var startDateComponents = calendar.dateComponents(units, from: startDate)
        startDateComponents.calendar = calendar

        var endDateComponents = calendar.dateComponents(units, from: endDate)
        endDateComponents.calendar = calendar

        // Create the predicate for the query
        let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
        
        
        
        let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summariesOrNil, errorOrNil) -> Void in
            
            guard let summaries = summariesOrNil else {
                // Handle any errors here.
                print("no summary")
                return
            }
            
            for summary in summaries {
                // Process each summary here.
                print(summary)
            }
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                // Update the UI here.
            }
        }
        healthStore!.execute(query)
    }
    
 
}

