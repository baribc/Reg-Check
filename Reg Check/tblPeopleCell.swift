//
//  tblCell.swift
//  Reg Check
//
//  Created by Bari Chin on 1/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class tblPeopleCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var imgNew: UIImageView!
    @IBOutlet weak var imgEmail: UIImageView!
    
    @IBOutlet weak var cellbtnSendMail: UIButton!
    @IBOutlet weak var cellbtnEditPerson: UIButton!
    
    @IBOutlet weak var celllblID: UILabel!
    @IBOutlet weak var celltxtFullName: UITextField!
    @IBOutlet weak var celllblMobile: UILabel!
    @IBOutlet weak var celllblEmail: UILabel!
    @IBOutlet weak var celllbldateImported: UILabel!
    @IBOutlet weak var celllbldateEmailed: UILabel!
    
    
    var localPerson = Person()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//       // print("selected by cell")
//    }

    @IBAction func cellbtnSendMail(_ sender: Any)
    {
        
        let person = localPerson
        if person.email == nil
        {
            return
        }
        NotificationCenter.default.post(name: Notification.Name("EmailPerson"), object: person)
    }
    @IBAction func btnEdit(_ sender: Any)
    {
       let person = localPerson
       NotificationCenter.default.post(name: Notification.Name("EditPerson"), object: person)
    }
    func clear()
    {
        cellImage.image = nil
        imgNew.image = nil
        imgEmail.image = nil
        celltxtFullName.text = ""
        celllblID.text = ""
        celllblMobile.text = ""
        celllblEmail.text = ""
        celllbldateImported.text = ""
        celllbldateEmailed.text = ""
    }
    func setPerson(person: Person)
    {
        localPerson = person
        clear()
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "d/MM/Y, hh:mm a"
        

        
        if person.imported != nil
        {
            celllbldateImported.text = df.string(from: person.imported!)
            let fiveDaysAgo = Date().add(.day,-5)!
          
            let imported = person.imported!
            if imported.isGreaterThan(fiveDaysAgo)
            {
                if (person.importedImg != nil) {
                imgNew?.image = UIImage(data: person.importedImg!)
                }
            }
            else
            {
                imgNew?.image = nil
            }
        }
        else
        {
            imgNew?.image = nil
        }
        
        if person.emailed != nil
        {
            celllbldateEmailed.text = df.string(from: person.emailed!)
            if (person.emailedImg != nil)
            {
                imgEmail?.image = UIImage(data: person.emailedImg!)
            }
        }
        else
        {
            celllbldateEmailed.text = ""
        }
        
        if person.firstName != nil && person.lastName != nil
        {
            celltxtFullName?.text = person.firstName! + " " + person.lastName!
        }
                  
        celllblID.text = String( person.membershipID)
        celllblMobile.text = person.mobilePhone
        celllblEmail.text = person.email
        
        if person.image != nil
        {cellImage?.image =  UIImage(data: person.image!)}
        else
        {
            generateCode(person: person)
        }
        
    }
    
    func generateCode (person: Person)
    {
        print(person.membershipID)
        let myInt = Int(person.membershipID)
        let qrString = String(myInt)
        if qrString != ""
        {
            let data = qrString.data(using: .ascii, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            let ciImage = filter?.outputImage
            let transform = CGAffineTransform (scaleX: 10, y: 10)
            let transformImage = ciImage?.transformed(by: transform)
            
            let img = UIImage(ciImage: transformImage!)
            cellImage.image = img
            person.image = img.pngData()
            PersistenceService.saveContext()
        }
    }
}
extension Date
{
    func isEqualTo(_ date: Date)-> Bool{
        return self == date
    }
    
    func isGreaterThan(_ date: Date)-> Bool{
        return self > date
    }
    
    func isLessThan(_ date: Date)-> Bool{
        return self < date
    }
    
    func add (_ component: Calendar.Component, _ value: Int)->Date?
    {
        Calendar.current.date(byAdding: component, value: value, to: self)
        
    }
    
}





