//
//  ViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 29/08/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class RegViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filter: UITextField!
    @IBOutlet weak var addNEw: UIButton!
    @IBOutlet weak var Export: UIButton!
    
    
    var people = [Person]()
    var currentPerson = Person()
    var filteredPeople = [Person]()
    var filtered = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.hideKeyboardOnTap()
        
        tableView.delegate = self
        tableView.dataSource = self
        filter.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationAddPerson(_:)), name: Notification.Name("AddPerson"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationEmailPerson(_:)), name: Notification.Name("EmailPerson"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationEditPerson(_:)), name: Notification.Name("EditPerson"), object: nil)
        self.fetchPeople()
    }
    
    func fetchPeople()
    {
        let fetchRequest: NSFetchRequest  <Person> = Person.fetchRequest()
        let sort = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do
        {
            self.people = try PersistenceService.context.fetch(fetchRequest)
            
        }
        catch
        {
                
        }
    }
    
    @objc func didGetNotificationAddPerson(_ notification: Notification)
    {
        guard let person = notification.object as! Person? else { return  }
        people.append(person)
        PersistenceService.saveContext()
        self.tableView.reloadData()
    }
    @objc func didGetNotificationEmailPerson(_ notification: Notification)
    {
        guard let person = notification.object as! Person? else { return  }
        showMailComposer(person: person)
    }
    @objc func didGetNotificationEditPerson(_ notification: Notification)
    {
        guard let person = notification.object as! Person? else { return  }
        person.membershipID = getID(person: person)
        PersistenceService.saveContext()
        tableView.reloadData()
    }
   
    
    @IBAction func btnAddNew()
    {
        let vc = storyboard?.instantiateViewController(identifier: "NewPerson") as! AddPersonViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func editingChanged(_ sender: UITextField)
    {
        filteredPeople.removeAll()
        if sender.text != ""
        {
            filterPeople(sender.text!)
            filtered = true
        }
        else
        {
            filtered = false
            tableView.reloadData()
        }
    }
    
    @IBAction func btnExport(_ sender: Any) {
        ExportCSV()
    }
    
    func ExportCSV()
    {
        let filePath = self.getDocumentsDirectory().appendingPathComponent("customers.csv")
        do
        {
            var content = "MembershipID, First Name, Last Name,  Email, Mobile Phone, Phone\n"
            for p in people
            {
                if p.mobilePhone == nil  { p.mobilePhone = ""}
                if p.email == nil { p.email = ""}
                if p.phone == nil { p.phone = ""}
                
                p.phone = p.phone?.trimmingCharacters(in: .whitespacesAndNewlines)
                p.mobilePhone = p.mobilePhone?.trimmingCharacters(in: .whitespacesAndNewlines)
                let line  = String(p.membershipID) + "," + p.firstName! + "," + p.lastName! + "," + p.email! + "," + p.mobilePhone! + "," + p.phone! + "\n"
                content += line
                PersistenceService.saveContext()
            }
            try content.write(to: filePath, atomically: true, encoding: .utf8)
        }
        catch{}
    }
    
    @IBAction func btnImport(_ sender: Any)
    {
        let documentsPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
        documentsPicker.delegate = self
        documentsPicker.allowsMultipleSelection = false
        documentsPicker.modalPresentationStyle = .fullScreen
        self.present(documentsPicker, animated: true, completion: nil)
        //ImportCSV()
    }
    func ImportCSV(url: URL)
    {
        let filePath = url// self.getDocumentsDirectory()
        do
        {
                 let textContent = try String(contentsOf: filePath,encoding: .utf8 )
                 let rows = textContent.components(separatedBy:  "\n")
                 var firstone = true
                 for row in rows
                 {
                     if !firstone//header row
                     {
                         let columns = row.split(separator: ",")
                         let importFullName = String(columns[0]) + " " + String(columns[1])
                         if !searchFullName(importFullName)
                         {
                            let person = Person(context: PersistenceService.context)
                            person.firstName = String(columns[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                            person.lastName = String(columns[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                             person.email = String(columns[2]).trimmingCharacters(in: .whitespacesAndNewlines)
                            person.mobilePhone = String(columns[3]).trimmingCharacters(in: .whitespacesAndNewlines)
                           
                            person.membershipID =  self.getID(person: person)
                            person.imported = NSDate.now
                         
                            person.importedImg = #imageLiteral(resourceName: "new-icon-free-16").pngData()
                            PersistenceService.saveContext()
                            people.append(person)
                         }
                     }
                     firstone = false
                 }
                 tableView.reloadData()
        }
        catch{}
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func filterPeople(_ query: String)
    {
        for person in people
        {
            let fullName = person.firstName!  + " " + person.lastName!
            
            if (fullName.lowercased().contains(query.lowercased()))
            {
                filteredPeople.append(person)
                filtered = true
            }
        }
        tableView.reloadData()
    }
    
    func searchFullName(_ query: String)->Bool
    {
        for person in people
        {
            let fullName = person.firstName!  + " " + person.lastName!
            
            if (fullName.lowercased().contains(query.lowercased()))
            {
                return true
            }
        }
        return false
    }
    
    
    func showMailComposer(person: Person)
    {
        currentPerson = person
        guard MFMailComposeViewController.canSendMail() else
        {
           //show alert
           return
        }
        let composer = MFMailComposeViewController()
        //let qrcode :NSData = person.image! as NSData
        var body = "<html><body>Hi  "
        body.append(person.firstName!)
        body.append(",<br> It's Kizomba Time!! <br>Here is your kizomba membership QR Code <br> Store your code somewhere safe and handy <br><br>MembershipID: ")
        body.append(String(person.membershipID))
        body.append("</body></html>")
        
        composer.mailComposeDelegate    = self
        composer.setToRecipients([person.email!])
        composer.setSubject( "Kizomba Time!")
        composer.setMessageBody(body, isHTML: true)
        composer.addAttachmentData(person.image!, mimeType: "image/png", fileName: "DancaMembershipQRCode.Png")
        
        present(composer, animated: true, completion:nil)
    }
}
extension RegViewController: MFMailComposeViewControllerDelegate
{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        if let _ = error
        {
            controller.dismiss(animated: true)
        }
        
        switch result
        {
        case .cancelled:
        print("cancel")
        case .failed:
        print("fail")
        case .saved:
        print("saved")
        case .sent:
            currentPerson.emailed =  NSDate.now
            
            currentPerson.emailedImg = #imageLiteral(resourceName: "envelope").pngData()
            PersistenceService.saveContext()
            tableView.reloadData()
        default:
        print("default")
        }
        controller.dismiss(animated: true)
    }
}

extension RegViewController: UIDocumentPickerDelegate
{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .open, let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
        ImportCSV(url: url)
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
             }

        
        controller.dismiss(animated: true)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
//extension RegViewController: UITableViewDelegate
extension RegViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if !filteredPeople.isEmpty
                   {
                       return filteredPeople.count
                   }
            return filtered ? 0 :  people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell
    {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:   indexPath  ) as! tblPeopleCell
        
        var currentPerson = Person()
        if filteredPeople.count > 0
        {
            currentPerson = filteredPeople[indexPath.row]
        }
        else
        {
            currentPerson = people[indexPath.row]
        }
         cell.setPerson(person: currentPerson)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselected")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:  IndexPath)
    {
//        print("selected by view controller")
//        people.remove(at: indexPath.row)//let selectIndex = indexPath.row
//        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            
            PersistenceService.context.delete(people[indexPath.row])
            PersistenceService.saveContext()
            self.fetchPeople()
            tableView.reloadData()
            
        }
    }
}

extension StringProtocol{
    var asciiValues:[UInt8] {
        compactMap(\.asciiValue)
    }
}
