//
//  tblCell.swift
//  Reg Check
//
//  Created by Bari Chin on 1/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//

import UIKit

class tblVisitorCell: UITableViewCell {

    @IBOutlet weak var celllblFullName: UILabel!
    @IBOutlet weak var celllblMobileNumber: UILabel!
    @IBOutlet weak var celllblEmail: UILabel!
    @IBOutlet weak var celllblMembershipNumber: UILabel!
    @IBOutlet weak var celllblScanDate: UILabel!
    @IBOutlet weak var celllblEvent: UILabel!
    
    
    //var localVisit = Visitor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//       // print("selected by cell")
//    }

    
    
    
    func setVisit(visitor: Visitor)
    {
        if visitor.firstName != nil && visitor.lastName != nil
        {
            celllblFullName?.text = visitor.firstName! + " " + visitor.lastName!
        }
        
        //let localVisit = visitor
        celllblMobileNumber?.text = visitor.mobilePhone
        celllblEmail?.text = visitor.email
        celllblMembershipNumber?.text = String( visitor.membershipID)
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "d MMM Y, hh:mm"
        celllblScanDate?.text = df.string(from: visitor.dateScanned!)
        celllblEvent.text = visitor.event
    }
}
