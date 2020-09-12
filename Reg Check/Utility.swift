//
//  Utility.swift
//  Reg Check
//
//  Created by Bari Chin on 30/08/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//
import Foundation
import UIKit

extension UIViewController {
    
    
   func getID(person: Person)->Int
   {
    if person.firstName == nil || person.lastName == nil || Int(person.mobilePhone!) == nil
    {
        return 0
    }
       let firstName = person.firstName!
       var asciiFN1 = "0"
       var asciiFN2 = "0"
       var asciiFN3 = "0"
       var asciiFN4 = "0"
       var asciiFN5 = "0"
       var i = 0
    
    
       for c in firstName.asciiValues
       {
           if i > 15 {break}
           if i < 3
           {
                asciiFN1 += String(c)
           }
           else if i < 6
           {
                asciiFN2 += String(c)
           }
           else  if i < 9
           {
               asciiFN3 += String(c)
           }
           else if i < 12
           {
               asciiFN4 += String(c)
           }
           else
           {
               asciiFN5 += String(c)
           }
           i+=1
           
       }
       let intFN1 = Int(asciiFN1)!
       let intFN2 = Int(asciiFN2)!
       let intFN3 = Int(asciiFN3)!
       let intFN4 = Int(asciiFN4)!
       let intFN5 = Int(asciiFN5)!
       let intFN = intFN1 + intFN2 + intFN3 + intFN4 + intFN5
       
       
       let lastName = person.lastName!
       var asciiLN1 = "0"
       var asciiLN2 = "0"
       var asciiLN3 = "0"
       var asciiLN4 = "0"
       var asciiLN5 = "0"
       i = 0
       for c in lastName.asciiValues
       {
           if i > 15 {break}
           if i < 3
           {
               asciiLN1 += String(c)
           }
           else if i < 6
           {
               asciiLN2 += String(c)
           }
           else if i < 9
           {
               asciiLN3 += String(c)
           }
           else if i < 12
           {
               asciiLN4 += String(c)
           }
           else
           {
               asciiLN5 += String(c)
           }
           i+=1
           
       }
       
       let intLN1 = Int(asciiLN1)!
       let intLN2 = Int(asciiLN2)!
       let intLN3 = Int(asciiLN3)!
       let intLN4 = Int(asciiLN4)!
       let intLN5 = Int(asciiLN5)!
       let intLN = intLN1 + intLN2 + intLN3  + intLN4 + intLN5
       let p = Int(person.mobilePhone!)
       
       let FNLN = intFN + intLN + p!
       
       
       return Int(FNLN)
   }
    
    func hideKeyboardOnTap()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
               tap.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tap)
        
    }
    @objc func hideKeyboard()
    {
        self.view.endEditing(true)
    }

}
