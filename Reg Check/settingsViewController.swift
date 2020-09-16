//
//  settingsViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 9/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class settingsViewController: UIViewController
{
    @IBOutlet weak var txtKioskBGColour: UITextField!
    @IBOutlet weak var txtKioskNonMemberMessage: UITextField!
    
    @IBOutlet weak var saveSettings: UIButton!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var tableView: UITableView!
       
    var events = [Event]()
    var event = Event()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getEvents()
        self.tableView.reloadData()
        
        if let code = defaults.value(forKey: "CODE") as? String {
            codeField.text = code
        }
        
        if let KioskBGColour = defaults.value(forKey: "KioskBGColour") as? String {
            txtKioskBGColour.text = KioskBGColour
        }
        
        if let KioskFail = defaults.value(forKey: "KioskFail") as? String {
            txtKioskNonMemberMessage.text = KioskFail
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        getEvents()
        //PersistenceService.saveContext()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "event"
        {
            if let vc = segue.destination as? ManageEventVC
            {
                vc.event = (sender as! Event)
            }
        }
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveEvent(_ unwindSegue: UIStoryboardSegue)
    {
        if let vc = unwindSegue.source as? ManageEventVC
        {
            var notFound = true
            for (index, old) in events.enumerated() {
                if old.eventName == vc.event?.eventName
                {
                    events[index] = vc.event!
                    notFound = false
                    break
                }
               
            }
            
            if notFound {events.append(vc.event!)}
            
            PersistenceService.saveContext()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func SaveSettings(_ sender: Any)
    {
        defaults.set(txtKioskBGColour.text, forKey: "KioskBGColour")
        
        //PinCode
        if codeField.text!.count < 4 {
            print("Weak Code")
            return
        }
        defaults.set(codeField.text!, forKey: "CODE")
        defaults.set(txtKioskNonMemberMessage.text, forKey:"KioskFail")
        self.tabBarController?.selectedIndex = 0
    }
    
    func getEvents()
    {
        let fetchEvents: NSFetchRequest <Event> = Event.fetchRequest()
        do
        {
           self.events = try PersistenceService.context.fetch(fetchEvents)
        }
         catch{}
    }
}
    
    


extension settingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let df = DateFormatter()
               df.locale = .current
               df.dateFormat = "EEEE hh:mm a"
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let startDate = df.string(from: events[indexPath.row].eventStartTime!)
        let endDate = df.string(from: events[indexPath.row].eventEndTime!)
        cell.textLabel?.text = events[indexPath.row].eventName! + " - " + startDate + " - " + endDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "event", sender: events[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        PersistenceService.context.delete(events[indexPath.row])
        PersistenceService.saveContext()
        events.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        
    }
    
    
}
