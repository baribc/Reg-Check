//
//  AddPersonViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 5/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import Foundation
import UIKit

class AddPersonViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    @IBOutlet weak var txtMembershipID:UITextField!
    @IBOutlet weak var txtFirstName:UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobilePhone: UITextField!
    @IBOutlet weak var qrImage:UIImageView!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerOptions: [[String]] = [[String]]()
    
    var person : Person?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        pickerOptions = [["Kizomba Casual","Kizomba Package"],
                         ["Semba Casual","Semba Package"],
                         ["Afro Casual","Afro Package"],
                         ["Tarraxinha Casual","Tarraxinha Package"]]
        print("pick option")
        print(pickerOptions.count)
        if person == nil
        {
            
            self.person = Person.init(context: PersistenceService.context)
        }
        else
        {
            txtMembershipID.text = String(person!.membershipID)
            txtFirstName.text = person?.firstName
            txtLastName.text = person?.lastName
            txtEmail.text = person?.email
            txtMobilePhone.text = person?.mobilePhone
            pickerView.selectRow(person!.memKizomba, inComponent: 0, animated: true)
            pickerView.selectRow(person!.memSemba, inComponent: 1, animated: true)
            pickerView.selectRow(person!.memAfro, inComponent: 2, animated: true)
            pickerView.selectRow(person!.memTarraxinha, inComponent: 3, animated: true)
            qrImage.image = UIImage(data: (person?.image)!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        person?.firstName = txtFirstName.text
        person?.lastName = txtLastName.text
        person?.email  = txtEmail.text
        person?.mobilePhone = txtMobilePhone.text
        person?.imported = NSDate.now
        person?.importedImg =  #imageLiteral(resourceName: "new-icon-free-16").pngData()
        person?.memKizomba = pickerView.selectedRow(inComponent: 0)
        person?.memSemba = pickerView.selectedRow(inComponent: 1)
        person?.memAfro = pickerView.selectedRow(inComponent: 2)
        person?.memTarraxinha = pickerView.selectedRow(inComponent: 3)
        
        if txtMembershipID.text!.isEmpty
        {
            person?.membershipID = self.getID(person: person!)
        }
        else
        {
            person?.membershipID = Int((txtMembershipID.text! as NSString).integerValue)
        }
        person?.image = qrImage.image?.pngData()
    }
    
//    @IBAction func Cancel(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
//    @IBAction func btnAddPerson(_ sender: Any)
//    {
//        let person = Person(context: PersistenceService.context)
//        person.firstName = txtFirstName.text
//        person.lastName = txtLastName.text
//        person.email  = txtEmail.text
//        person.mobilePhone = txtMobilePhone.text
//        person.imported = NSDate.now
//
//        person.importedImg =  #imageLiteral(resourceName: "new-icon-free-16").pngData()
//
//        if txtMembershipID.text!.isEmpty
//        {
//            person.membershipID = self.getID(person: person)
//        }
//        else
//        {
//            person.membershipID = Int((txtMembershipID.text! as NSString).integerValue)
//        }
//
//        person.image = qrImage.image?.pngData()
//
////        NotificationCenter.default.post(name: Notification.Name("AddPerson"), object: person)
//        dismiss(animated: true, completion: nil)
//    }
      
    
      
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
