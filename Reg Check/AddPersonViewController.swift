//
//  AddPersonViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 5/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import Foundation
import UIKit

class AddPersonViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var txtMembershipID:UITextField!
    @IBOutlet weak var txtFirstName:UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobilePhone: UITextField!
    @IBOutlet weak var qrImage:UIImageView!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAddPerson(_ sender: Any)
    {
        let person = Person(context: PersistenceService.context)
        person.firstName = txtFirstName.text
        person.lastName = txtLastName.text
        person.email  = txtEmail.text
        person.mobilePhone = txtMobilePhone.text
        person.imported = NSDate.now
       
        person.importedImg =  #imageLiteral(resourceName: "new-icon-free-16").pngData()
        
        if txtMembershipID.text!.isEmpty
        {
            person.membershipID = self.getID(person: person)
        }
        else
        {
            person.membershipID = Int((txtMembershipID.text! as NSString).integerValue)
        }
        
        person.image = qrImage.image?.pngData()
        
        NotificationCenter.default.post(name: Notification.Name("AddPerson"), object: person)
        dismiss(animated: true, completion: nil)
    }
      
    
      
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(false)
        
    }

    @IBAction func btnGenerateQRCode(_ sender:Any)
    {
        if let qrString = txtMembershipID.text
        {
            let data = qrString.data(using: .ascii, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            let ciImage = filter?.outputImage
            let transform = CGAffineTransform (scaleX: 10, y: 10)
            let transformImage = ciImage?.transformed(by: transform)
            
            let img = UIImage(ciImage: transformImage!)
            qrImage.image = img
        }
    }
}
