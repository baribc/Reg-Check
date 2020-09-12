//
//  KioskViewController.swift
//  Reg Check
//
//  Created by Bari Chin on 30/08/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class KioskViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var kioskSubView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var responseTick: UIView!
    @IBOutlet weak var imgTick: UIImageView!
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var scannedMessage: UILabel!
    
    let defaults = UserDefaults.standard
    var KioskFail = ""
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var people = [Person]()
    var visits = [Visitor]()
    var timer = Timer()
    var scanFound = false
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let _ = defaults.value(forKey: "CODE") as? String else {
            self.tabBarController?.selectedIndex = 3
            return
        }
        getDefaults()
        fetchData()
        captureSession.startRunning()
        
    }
       
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        getDefaults()
        self.tabBarController?.delegate = self
        self.responseTick.isHidden = true
        imgTick.isHidden = true
        imgCross.isHidden = true
        //Setup video stream
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position:  .front) else { return  }
        
        let videoInput: AVCaptureDeviceInput
        do
        {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        }
        catch
        { return }
        
        if (captureSession.canAddInput(videoInput))
        {
            captureSession.addInput(videoInput)
        }
        else
        {
               failed()
               return
        }
    
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417, .code128, .dataMatrix, .upce , .aztec, .code39, .code93, .interleaved2of5]
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(cameraView)
        captureSession.startRunning()
    }
    
    
    func fetchData()
    {
        let fetchPeople: NSFetchRequest  <Person> = Person.fetchRequest()
        do
        {
            self.people = try PersistenceService.context.fetch(fetchPeople)
        }
        catch{}
        let fetchVisits: NSFetchRequest <Visitor> = Visitor.fetchRequest()
        do
        {
            self.visits = try PersistenceService.context.fetch(fetchVisits)
        }
        catch{}
    }
    
    @objc func scannerStart()
    {
        responseTick.isHidden = true
        imgTick.isHidden = true
        imgCross.isHidden = true
        captureSession.startRunning()
        
    }
    
    func scanResponse(pass: Bool, name: String)
    {
        if pass
        {
            imgTick.isHidden = false
            scannedMessage.text = "Welcome " + name
            AudioServicesPlaySystemSound(1308)
        }
        else
        {
            imgCross.isHidden = false
            scannedMessage.text = KioskFail
             AudioServicesPlaySystemSound(1301)
        }
        responseTick.isHidden=false
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        captureSession.stopRunning()
        timer = Timer.scheduledTimer(timeInterval: 2,  target:self, selector: #selector(scannerStart), userInfo: nil, repeats: false)
        
        if let metadataObject = metadataObjects.first
        {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let memberID = readableObject.stringValue else { return }
            
            var foundPerson = Person ()
            
            for person in people
            {
                if person.membershipID == Int(memberID)
                {
                    scanFound = true
                    foundPerson = person
                }
            }
            
            if scanFound
            {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                let currentVisitor = Visitor(context: PersistenceService.context)
                //Session()
                currentVisitor.membershipID = foundPerson.membershipID
                currentVisitor.dateScanned = NSDate.now
                currentVisitor.firstName  = foundPerson.firstName
                currentVisitor.lastName  = foundPerson.lastName
                currentVisitor.email = foundPerson.email
                currentVisitor.mobilePhone = foundPerson.mobilePhone
                currentVisitor.phone    = foundPerson.phone
                visits.append(currentVisitor)
                scanResponse(pass: true, name: foundPerson.firstName!)
                PersistenceService.saveContext()
                
            }
            else
            {
                scanResponse(pass: false, name: "")
            }
        }
        scanFound = false
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if NavigationStack.previousTabIndex != 0 {
            return
        }
        
        print(tabBarController.selectedIndex)
        NavigationStack.currentTabIndex = tabBarController.selectedIndex
        tabBarController.selectedIndex = NavigationStack.previousTabIndex!
        
        if let code = UserDefaults.standard.value(forKey: "CODE") as? String
        {

            let alert = UIAlertController(title: "Authentication", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: {textField in
                textField.placeholder = "Enter Code"; textField.keyboardType = UIKeyboardType.numberPad
            })

            alert.addAction(UIAlertAction(title: "Verify", style: .default, handler: { _ in

                let textField = alert.textFields![0]

                if (code == textField.text!)
                    {
                        tabBarController.selectedIndex = NavigationStack.currentTabIndex!
                    }

                }
            ))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                     tabBarController.selectedIndex = NavigationStack.previousTabIndex!
                }
            ))

            self.present(alert, animated: true, completion: nil)

        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
    
    NavigationStack.previousTabIndex = tabBarController.selectedIndex
    return true
    }
    
    func getDefaults()
    {
        if defaults.value(forKey: "KioskFail") == nil
        {
          KioskFail = "Please see reception"
        }
        else
        {
          KioskFail = defaults.value(forKey: "KioskFail") as! String
        }
        
    }

}
class NavigationStack {
    
    public static var currentTabIndex : Int?
    public static var previousTabIndex : Int?
    
}

