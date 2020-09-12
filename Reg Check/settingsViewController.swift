//
//  settingsViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 9/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import Foundation
import UIKit

class settingsViewController: UIViewController
{
    @IBOutlet weak var txtKioskBGColour: UITextField!
    @IBOutlet weak var txtKioskNonMemberMessage: UITextField!
    
    @IBOutlet weak var saveSettings: UIButton!
    @IBOutlet weak var codeField: UITextField!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtKioskBGColour.text = defaults.string(forKey: "KioskBGColour") ?? "Orange"
        txtKioskNonMemberMessage.text = defaults.string(forKey: "KioskFail") ?? "Please see reception"
        if let code = defaults.value(forKey: "CODE") as? String {
            codeField.text = code
        }
        
        
    }
    @IBAction func SaveSettings(_ sender: Any) {
        defaults.set(txtKioskBGColour.text, forKey: "KioskBGColour")
        
        //PinCode
        if codeField.text!.count < 4 {
            print("Weak Code")
            return
        }
        defaults.set(codeField.text!, forKey: "CODE")
        self.tabBarController?.selectedIndex = 0
        
        defaults.set(txtKioskNonMemberMessage.text, forKey:"KioskFail")
        
        
    }
}
