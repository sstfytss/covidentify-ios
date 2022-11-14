//
//  AppDelegate.swift
//  covidentify-ios
//
//  Created by Shun Sakai on 10/4/22.
//

import UIKit
import UserNotifications
import HealthKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var healthStore: HKHealthStore?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Allow push notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge], completionHandler: { _, _ in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        })
        
        // Allow access to healthkit data
        let objectType = HKSampleType.quantityType(forIdentifier: .bodyMass)!

        HKHealthStore().requestAuthorization(toShare: nil, read: Set([objectType]), completion: { success, error in

        })

        // Check for updates to healthkit data
        let query = HKObserverQuery(sampleType: objectType, predicate: nil, updateHandler: {
            query, completionHandler, error in
            if error != nil {
                return
            }
            
            self.updateWorkouts {
                completionHandler()
            }
            
            // If healthkit data is update, send a notification
            let content = UNMutableNotificationContent()
            content.body = "HealthKit Data Uploaded"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "detection-test", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            completionHandler()
        })
        HKHealthStore().execute(query)

        // Allow for in background checks of healthkid data update
        HKHealthStore().enableBackgroundDelivery(for: objectType, frequency: .immediate, withCompletion: { success, error in
        })
        
        return true
    }
    
    // function to update bodymass
    func updateWorkouts(completionHandler: @escaping () -> Void) {
        guard let sampleBM = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else {
            fatalError("*** This method should never fail ***")
        }

        let queryBodyMass = HKSampleQuery(sampleType: sampleBM, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else {
                // Handle any errors here.
                print("heart rate analysis error")
                return
            }
            for sample in samples {
                let content = UNMutableNotificationContent()
                content.body = "\(sample.quantity)"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                let request = UNNotificationRequest(identifier: "detection-test", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                
                self.postHeartRateData(participantId: 0, deviceId: 0, date: formatter.string(from: sample.startDate), heartRate: Int(sample.quantity.doubleValue(for: HKUnit.pound())))
                completionHandler()
            }
            
            
            DispatchQueue.main.async {
                // Update the UI here.
                print("")
            }
        }
        HKHealthStore().execute(queryBodyMass)
    }
    
    func postHeartRateData(participantId: Int, deviceId: Int, date: String, heartRate: Int) {
        guard let url = URL(string: "http://test-ios.azurewebsites.net/api/todo"),
              let payload = "{\"id\":0,\"participant_id\":\(participantId),\"device_id\":\(deviceId),\"date\":\"\(date)\",\"heart_rate\":\(heartRate)}".data(using: .utf8)
        else {
            print("returning")
            return
        }
        print("returning2")
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

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

