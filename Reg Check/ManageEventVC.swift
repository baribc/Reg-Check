import UIKit
import Foundation
import CoreData

class ManageEventVC: UIViewController
{

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startDataPicker: UIDatePicker!
    @IBOutlet weak var endDataPicker: UIDatePicker!
    
    var event: Event?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if event == nil
        {
            
            self.event = Event.init(context: PersistenceService.context)
        }
        else
        {
            nameField?.text = event?.eventName
            startDataPicker?.date = event?.eventStartTime ?? Date()
            endDataPicker?.date = event?.eventEndTime ?? Date()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if nameField.text!.count < 3 {
            print("Please enter event name")
            return
        }
        event?.eventName = nameField.text!
        event?.eventStartTime = startDataPicker?.date ?? Date()
        event?.eventEndTime = endDataPicker?.date ?? Date()        
    }
    
//    @IBAction func saveEvent (_ sender: UIButton)
//    {
//        
//        
//        self.dismiss(animated: true, completion: nil)
//    }
    
//    @IBAction func back (_ sender: UIButton)
//    {
//        self.dismiss(animated: true, completion: nil)
//    }
}
