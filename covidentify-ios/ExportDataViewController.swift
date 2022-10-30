//
//  ExportDataViewController.swift
//  covidentify-ios
//
//  Created by James Wang on 10/22/22.
//

import UIKit

class ExportDataViewController: UIViewController {

    @IBOutlet weak var readCounter: UILabel!
    
    @IBOutlet weak var writeCounter: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    var dataImporter = HKimporter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func start(_ sender: Any) {
        dataImporter = HKimporter {
            if let path = Bundle.main.url(forResource: "export", withExtension: "xml") {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self.dataImporter
                    self.dataImporter.readCounterLabel  = self.readCounter
                    self.dataImporter.writeCounterLabel = self.writeCounter
                    parser.parse()
                    self.dataImporter.saveAllSamples()
                }
            } else {
                print ("file not found")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
