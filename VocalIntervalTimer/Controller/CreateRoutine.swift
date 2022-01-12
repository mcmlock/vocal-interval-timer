import UIKit
import CoreData

class CreateRoutineViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let intervals = Intervals()
    
    //UserDefaults
    let saveForRounds = UserDefaults.standard
    let saveTemplateName = UserDefaults.standard
    
    
    //For updating the totalTimeLabel
    var totalWorkoutTime: Int = 0
    var rounds = 1
    
    var edit = Interval()
    var toEdit: Int?
    
    //IBOutlets
    @IBOutlet weak var templateNameTextField: UITextField!
    @IBOutlet weak var roundsTextField: UITextField!
    @IBOutlet weak var reorderButton: UIButton!
    @IBOutlet weak var intervalsTableView: UITableView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up intervalsTableView
         intervalsTableView.dataSource = self
         intervalsTableView.delegate = self
         intervalsTableView.register(UINib(nibName: "IntervalsTableViewCell", bundle: nil), forCellReuseIdentifier: "IntervalCell")
         //Load core data items into tableView
         fetchIntervals()
        
        //Dismissing keyboard
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        //Loading the rounds text field with previous input
        if let roundsEntered = saveForRounds.string(forKey: "roundsEntered") {
            roundsTextField.text = roundsEntered
            if roundsTextField.text != "" && Int(roundsTextField.text!)! > 0 {
                rounds = Int(roundsTextField.text!)!
            }
        }
        
        //Loading the templateNameTextField with previous input
        if let templateName = saveTemplateName.string(forKey: "templateName") {
            templateNameTextField.text = templateName
        }
        
        
        //Setting the total time label & rounds text field
        setTotalWorkoutTime()
    }
    
    //Limits the text length
    func twoChars(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            if textField.text != "" {
            let length = textField.text!.count
                for _ in 0...(length-3) {
            textField.deleteBackward()
                }
            }

        }
    }
    
    //Allows keyboard to be dismissed by tapping somewhere else
    @objc func dismissKeyboard() {
        view.endEditing(true)
        twoChars(textField: roundsTextField!, maxLength: 2)
        if roundsTextField.text != "" && Int(roundsTextField.text!)! > 0 {
            rounds = Int(roundsTextField.text!)!
            setTotalWorkoutTime()
        } else {
            roundsTextField.text = ""
            rounds = 1
            setTotalWorkoutTime()
        }
    }
    
 //Sets label for the totalWokroutTime
    func setTotalWorkoutTime() {
        totalWorkoutTime = 0
        for interval in intervals.intervalsArray {
            totalWorkoutTime += Int(interval.timeInSeconds) * rounds
        }
        
        let hours = totalWorkoutTime / 3600
        let min: Int
        if totalWorkoutTime < 3600 {
            min = totalWorkoutTime / 60
        } else {
            min = (totalWorkoutTime % 3600) / 60
        }
        let sec = totalWorkoutTime % 60
        
        if totalWorkoutTime >= 3600 {
            totalTimeLabel.text = String(format: "%02d : %02d : %02d", hours, min, sec)
        }
        else {
            totalTimeLabel.text = String(format: "%02d : %02d", min, sec)
        }
        
    }
    
    
    //Loads the table view with the intervals stored in core data
    func fetchIntervals() {

        do {
            self.intervals.intervalsArray = try context.fetch(Interval.fetchRequest())
            
            DispatchQueue.main.async{
                self.intervalsTableView.reloadData()
            }
        }
        catch {
           
        }
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        for interval in intervals.intervalsArray {
            context.delete(interval)
            try! context.save()
        }
        
        roundsTextField.text = ""
        rounds = 1
        
        templateNameTextField.text = ""
        
        intervals.intervalsArray.removeAll()
        setTotalWorkoutTime()
        fetchIntervals()
    }
    
    @IBAction func reorderPressed(_ sender: UIButton) {
        if intervals.intervalsArray.count > 1 {
        intervalsTableView.isEditing = !intervalsTableView.isEditing
        
        switch intervalsTableView.isEditing {
        case true:
            reorderButton.setTitle("Done", for: .normal)
           // try! context.save()
        case false:
            reorderButton.setTitle("Reorder", for: .normal)
            do {
            try context.save()
            } catch {
                
            }
        }
        }
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "addInterval2", sender: self)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if templateNameTextField.text != "" && intervals.intervalsArray.count > 0 {
            if roundsTextField.text != "" {
                rounds = Int(roundsTextField.text!)!
            } 
        saveToCoreData()
        performSegue(withIdentifier: "toSavedFromCreate", sender: self)
        }
    }
    
    //Saves the template to CoreData
    func saveToCoreData() {
        let newTemplate = Template(context: self.context)
        newTemplate.name = templateNameTextField.text
        newTemplate.rounds = Int64(rounds)
        newTemplate.intervalCount = Int64(intervals.intervalsArray.count)
        var firstInterval = true
        
        //Strings to be saved to CoreData
        var intervalNamesString = ""
        var intervalTimesString = ""
        var closingAudiosString = ""
        var beginningsSelectedString = ""
        var beginningAudiosString = ""
        var midwaysSelectedString = ""
        var midwayAudiosString = ""
        var intervalColorsString = ""
        
        
        for interval in intervals.intervalsArray {
            if firstInterval {
                intervalNamesString = interval.name!
                intervalTimesString = String(interval.timeInSeconds)
                closingAudiosString = interval.closingAudio!.absoluteString
                beginningsSelectedString = String(interval.beginningSelected)
                beginningAudiosString = interval.beginningAudioString!
                midwaysSelectedString = String(interval.midwaySelected)
                midwayAudiosString = interval.midwayAudioString!
                intervalColorsString = interval.colorString!
                
            
                firstInterval = false
            } else {
                intervalNamesString.append("//?/")
                intervalNamesString.append(interval.name!)
                intervalTimesString.append("//?/")
                intervalTimesString.append(String(interval.timeInSeconds))
                closingAudiosString.append("//?/")
                closingAudiosString.append(interval.closingAudio!.absoluteString)
                beginningsSelectedString.append("//?/")
                beginningsSelectedString.append(String(interval.beginningSelected))
                beginningAudiosString.append("//?/")
                beginningAudiosString.append(interval.beginningAudioString!)
                midwaysSelectedString.append("//?/")
                midwaysSelectedString.append(String(interval.midwaySelected))
                midwayAudiosString.append("//?/")
                midwayAudiosString.append(interval.midwayAudioString!)
                intervalColorsString.append("//?/")
                intervalColorsString.append(interval.colorString!)
            }
        }
        
        newTemplate.intervalNames = intervalNamesString
        newTemplate.intervalTimes = intervalTimesString
        newTemplate.closingAudios = closingAudiosString
        newTemplate.beginningsSelected = beginningsSelectedString
        newTemplate.beginningAudios = beginningAudiosString
        newTemplate.midwaysSelected = midwaysSelectedString
        newTemplate.midwayAudios = midwayAudiosString
        newTemplate.intervalColors = intervalColorsString
        
        try! context.save()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addInterval2" {
            saveForRounds.setValue(roundsTextField.text, forKey: "roundsEntered")
            saveTemplateName.setValue(templateNameTextField.text, forKey: "templateName")
            
            
            let vc = segue.destination as! AddIntervalViewController
            vc.creatingTemplate = true
            vc.editingInterval = false
            
            vc.saveName.setValue("", forKey: "name")
            vc.saveMin.setValue("", forKey: "min")
            vc.saveSec.setValue("", forKey: "sec")
            vc.saveDups.setValue("", forKey: "duplications")
            vc.saveClosingName.setValue("", forKey: "closingName")
            vc.saveMidwayName.setValue("", forKey: "midwayName")
            vc.saveClosingURLString.setValue("", forKey: "closingURLString")
            vc.saveMidwayURLString.setValue("", forKey: "midwayURLString")
            vc.midwaySelected = false
            vc.saveIfHasMidway.setValue(false, forKey: "hasMidway")
        }
        
        if segue.identifier == "editInterval2" {
            //Set user defaults to the attributes of the selected interval
            saveForRounds.setValue(roundsTextField.text, forKey: "roundsEntered")
            saveTemplateName.setValue(templateNameTextField.text, forKey: "templateName")
            
            let vc = segue.destination as! AddIntervalViewController
            vc.creatingTemplate = true
            vc.editingInterval = true
            vc.toEdit = self.toEdit
      
            let nameTransfer = intervals.intervalsArray[toEdit!].name
            let minTransfer = String(intervals.intervalsArray[toEdit!].timeInSeconds / Int64(60))
            let secTransfer = String(intervals.intervalsArray[toEdit!].timeInSeconds % Int64(60))
            
            vc.nameTransfer = nameTransfer!
            vc.minTransfer = minTransfer
            vc.secTransfer = secTransfer
            vc.color = intervals.intervalsArray[toEdit!].color as! UIColor
            vc.saveDups.setValue("", forKey: "duplications")
        }
    }
}

extension CreateRoutineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.intervalsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //this let is for the cell
        let intervalCell = intervalsTableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath) as! IntervalsTableViewCell
      
        
        //this let is for the data of the particular interval in the array
        let interval = self.intervals.intervalsArray[indexPath.row]
        
        intervalCell.nameLabel.text = interval.name
        let min = interval.timeInSeconds / 60
        let sec = interval.timeInSeconds % 60
        intervalCell.durationLabel.text = String(format: "%02d : %02d", min, sec)
        intervalCell.cellBackground.backgroundColor = interval.color as? UIColor
                                                   
        return intervalCell
    }
    
}

extension CreateRoutineViewController: UITableViewDelegate {
   //Swipe to delete capablility
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Swipe to delete action
        let swipeDelete = UIContextualAction(style: .destructive, title: "") { [self] (action, view, completionHandler) in
            //The interval to be removed:
            let intervalToDelete = intervals.intervalsArray[indexPath.row]
            //Updating the totalTime label
            self.totalWorkoutTime -= Int(intervalToDelete.timeInSeconds)
            //Removing the interval
            self.context.delete(intervalToDelete)
            //Save the action
            do {
                try self.context.save()
                self.setTotalWorkoutTime()
            } catch {
                
            }
            //Re-fetch data
            self.fetchIntervals()
        }
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
    
    //FOR ALLOWING USERS TO DRAG AND DROP CELLS IN THE TABLE VIEW
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let intervalInsert = intervals.intervalsArray[sourceIndexPath.row]
      //  context.delete(intervals.intervalsArray[sourceIndexPath.row])
        intervals.intervalsArray.remove(at: sourceIndexPath.row)
        //context.insert(intervalInsert)
        intervals.intervalsArray.insert(intervalInsert, at: destinationIndexPath.row)
        
        for interval in intervals.intervalsArray {
            let newInterval = Interval(context: self.context)
            newInterval.name = interval.name
            newInterval.color = interval.color
            newInterval.colorString = interval.colorString
            newInterval.timeInSeconds = interval.timeInSeconds
            newInterval.closingAudio = interval.closingAudio
            newInterval.midwaySelected = interval.midwaySelected
            newInterval.midwayAudioString = interval.midwayAudioString
            newInterval.beginningSelected = interval.beginningSelected
            newInterval.beginningAudioString = interval.beginningAudioString
            context.delete(interval)
            try! context.save()
            fetchIntervals()
            
        }
    }

        //FOR ALLOWING USERS TO EDIT INTERVALS WHEN TAPPED
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            edit = intervals.intervalsArray[indexPath.row]
            toEdit = indexPath.row
            performSegue(withIdentifier: "editInterval2", sender: self)
        }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CreateRoutineViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        view.endEditing(false)
        if touch.view?.isDescendant(of: self.intervalsTableView) == true {
            return false
        } else {
            return true
        }
    }
    
}

