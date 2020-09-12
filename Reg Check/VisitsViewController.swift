//
//  VisitsViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 6/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//


import UIKit
import CoreData

class VisitsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filter: UITextField!
    @IBOutlet weak var btnExport: UIButton!
    
    var visits = [Visitor]()
    var filteredVisits = [Visitor]()
    var filtered = false
    
    override func viewDidLoad()
   {
       super.viewDidLoad()
       self.hideKeyboardOnTap()
       tableView.delegate = self
       tableView.dataSource = self
       filter.delegate = self
       self.fetchVisits()
   }
    override func viewWillAppear(_ animated: Bool)
    {
        
    fetchVisits()
        
    }
    
    func fetchVisits()
    {
        let fetchRequest: NSFetchRequest  <Visitor> = Visitor.fetchRequest()
        do
        {
            self.visits = try PersistenceService.context.fetch(fetchRequest)
            tableView.reloadData()
        }
        catch
        {
        }
    }
    @IBAction func editingChanged(_ sender: UITextField)
    {
        filteredVisits.removeAll()
        if sender.text != ""
        {
            filterVisits(sender.text!)
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
        let filePath = self.getDocumentsDirectory().appendingPathComponent("visitors.csv")
        do
        {
            var content = "MembershipID, First Name, Last Name, Mobile Phone, Email, Phone, Date, Time\n"
            for p in visits
            {
                if p.mobilePhone == nil  { p.mobilePhone = ""}
                if p.email == nil { p.email = ""}
                if p.phone == nil { p.phone = ""}
                let df = DateFormatter()
                df.locale = .current
                df.dateFormat = "d/MM/Y, hh:mm a"
                let dateScanned = df.string(from: p.dateScanned!)
                let line  = String(p.membershipID) + ", " + p.firstName! + ", " + p.lastName! + ", " + p.mobilePhone! + ", " + p.email! + ", " + p.phone! + ", " + dateScanned + "\n"
                content += line
            }
            try content.write(to: filePath, atomically: true, encoding: .utf8)
        }
        catch{}
    }
    
    func getDocumentsDirectory() -> URL
       {
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           return paths[0]
       }
    
    func filterVisits(_ query: String)
    {
        for visitor in visits
        {
            let fullName = visitor.firstName!  + " " + visitor.lastName!
            
            if (fullName.lowercased().contains(query.lowercased()))
            {
                filteredVisits.append(visitor)
                filtered = true
            }
        }
        tableView.reloadData()
    }
}
    
extension VisitsViewController
{
                
    func numberOfSections(in tableView: UITableView) -> Int
    {
       return 1
    }
               
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if !filteredVisits.isEmpty
        {
            return filteredVisits.count
        }
    return filtered ? 0 :  visits.count
    }
                
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "visitorcell", for:   indexPath  ) as! tblVisitorCell

        var currentVisitor = Visitor()
        if filteredVisits.count > 0
        {
            currentVisitor = filteredVisits[indexPath.row]
        }
        else
        {
            currentVisitor = visits[indexPath.row]
        }
        cell.setVisit(visitor: currentVisitor)
        return cell
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
            PersistenceService.context.delete(visits[indexPath.row])
            PersistenceService.saveContext()
            self.fetchVisits()
            tableView.reloadData()
            
        }
    }
    
}
