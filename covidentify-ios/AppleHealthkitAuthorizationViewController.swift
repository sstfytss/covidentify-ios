//
//  AppleHealthkitAuthorizationViewController.swift
//  covidentify-ios
//
//  Created by James Wang on 10/13/22.
//

import UIKit
import HealthKit

class AppleHealthkitAuthorizationViewController: UIViewController {
    var healthStore: HKHealthStore?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func AuthorizationTapped(_ sender: Any) {
        requestAuthorization()
    }
    
    func requestAuthorization() -> Void {
        healthStore = HKHealthStore()
        if HKHealthStore.isHealthDataAvailable() {
            print("healthkit is available")
            let allTypes = Set([HKObjectType.workoutType(),
                                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                HKObjectType.quantityType(forIdentifier: .vo2Max)!,
                                HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                                HKObjectType.quantityType(forIdentifier: .respiratoryRate)!])

            healthStore!.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                    print("cannot authorize")
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "dashboardSegue", sender: self)


            }
        }

    }
    



}
