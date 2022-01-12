//
//  SavedRoutineTableViewCell.swift
//  VocalIntervalTimer
//
//  Created by Miles Morlock on 12/17/20.
//

import UIKit
import CoreData

class SavedRoutineTableViewCell: UITableViewCell {

    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
