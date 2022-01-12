import UIKit
import CoreData

class AddIntervalViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var intervals = Intervals()
    
    var color: UIColor?
    var colorString = "red"
    var duplications = 1
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    @IBOutlet weak var duplicateTextField: UITextField!
    @IBOutlet weak var closingAudioName: UIButton!
    @IBOutlet weak var midwayAudioName: UIButton!
    @IBOutlet weak var beginningAudioName: UIButton!
    
    var toEdit: Int?
    var editingInterval = false
    var nameTransfer = ""
    var minTransfer = ""
    var secTransfer = ""
    
    var creatingTemplate = false
    
    var beginningSelected = false
    var beginningSoundName = "N/A"
    var beginningSoundString = ""
    var midwaySelected = false
    var midwaySoundName = "N/A"
    var midwaySoundString = ""
    var closingSoundName = "Default"
    var soundLink: URL = Bundle.main.url(forResource: "Default", withExtension: "wav")!
    
    var colorData: Data?
    
    //User defaults
    let saveName = UserDefaults.standard
    let saveMin = UserDefaults.standard
    let saveSec = UserDefaults.standard
    let saveDups = UserDefaults.standard
    let saveClosingName = UserDefaults.standard
    let saveClosingURLString = UserDefaults.standard
    let saveIfHasMidway = UserDefaults.standard
    let saveMidwayName = UserDefaults.standard
    let saveMidwayURLString = UserDefaults.standard
    let saveIfHasBeginning = UserDefaults.standard
    let saveBeginningName = UserDefaults.standard
    let saveBeginningURLString = UserDefaults.standard
    let saveColorString = UserDefaults.standard
    
    
    //Color IBOutlets
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var darkBlueButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var lightBlueButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var greyButton: UIButton!
    @IBOutlet weak var brownButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //Dismissing keyboard
    let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
        
        //Setting the user defaults
        if let name = saveName.string(forKey: "name") {
            if nameTransfer == "" {
                nameTextField.text = name
            } else {
                nameTextField.text = nameTransfer
            }
        }
        
        if let min = saveMin.string(forKey: "min") {
            if minTransfer == "" {
                minutesTextField.text = min
            } else {
                minutesTextField.text = minTransfer
                addAZero(minutesTextField)
            }
        }
        
        if let sec = saveMin.string(forKey: "sec") {
            if secTransfer == "" {
                secondsTextField.text = sec
            } else {
                secondsTextField.text = secTransfer
                addAZero(secondsTextField)
            }
        }
        
        if let dups = saveDups.string(forKey: "duplications") {
            duplicateTextField.text = dups
            if dups != "" {
                duplications = Int(dups)!
            }
        }
        
        if let bn = saveBeginningName.string(forKey: "beginningName") {
            if bn != "" {
                beginningSoundName = bn
            }
        }
        
        if let mn = saveMidwayName.string(forKey: "midwayName") {
            if mn != "" {
            midwaySoundName = mn
            }
        }
        
        if let cn = saveClosingName.string(forKey: "closingName") {
            if cn != "" {
            closingSoundName = cn
            }
        }
        
        if let bURL = saveBeginningURLString.string(forKey: "beginningURLString") {
            beginningSoundString = bURL
        }
        
        if let mURL = saveMidwayURLString.string(forKey: "midwayURLString") {
            midwaySoundString = mURL
        }
        
        if let cURL = saveClosingURLString.string(forKey: "closingURLString") {
            if cURL != "" {
            soundLink = Foundation.URL(string: cURL)!
            }
        }
        
        if let beginningQuestion = saveIfHasBeginning.string(forKey: "hasBeginning") {
            if beginningQuestion == "true" {
                beginningSelected = true
            } else {
                beginningSelected = false
            }
        }
        
        if let midwayQuestion = saveIfHasMidway.string(forKey: "hasMidway") {
            if midwayQuestion == "true" {
                midwaySelected = true
            } else {
                midwaySelected = false
            }
        }
        
        if let cs = saveColorString.string(forKey: "colorString") {
            colorString = cs
        }
        
        beginningAudioName.setTitle(beginningSoundName, for: .normal)
        midwayAudioName.setTitle(midwaySoundName, for: .normal)
        closingAudioName.setTitle(closingSoundName, for: .normal)
        
        //Rehighlights the previously selected color
        if color == redButton.backgroundColor {
            redButton.layer.borderColor = UIColor.black.cgColor
            redButton.layer.borderWidth = 4
        } else if color == orangeButton.backgroundColor {
            orangeButton.layer.borderColor = UIColor.black.cgColor
            orangeButton.layer.borderWidth = 4
        } else if color == yellowButton.backgroundColor {
            yellowButton.layer.borderColor = UIColor.black.cgColor
            yellowButton.layer.borderWidth = 4
        } else if color == pinkButton.backgroundColor {
            pinkButton.layer.borderColor = UIColor.black.cgColor
            pinkButton.layer.borderWidth = 4
        } else if color == darkBlueButton.backgroundColor {
            darkBlueButton.layer.borderColor = UIColor.black.cgColor
            darkBlueButton.layer.borderWidth = 4
        } else if color == greenButton.backgroundColor {
            greenButton.layer.borderColor = UIColor.black.cgColor
            greenButton.layer.borderWidth = 4
        } else if color == purpleButton.backgroundColor {
            purpleButton.layer.borderColor = UIColor.black.cgColor
            purpleButton.layer.borderWidth = 4
        } else if color == lightBlueButton.backgroundColor {
               lightBlueButton.layer.borderColor = UIColor.black.cgColor
               lightBlueButton.layer.borderWidth = 4
        } else if color == blackButton.backgroundColor {
            blackButton.layer.borderColor = UIColor.black.cgColor
            blackButton.layer.borderWidth = 4
        } else if color == whiteButton.backgroundColor {
            whiteButton.layer.borderColor = UIColor.black.cgColor
            whiteButton.layer.borderWidth = 4
        } else if color == greyButton.backgroundColor {
            greyButton.layer.borderColor = UIColor.black.cgColor
            greyButton.layer.borderWidth = 4
        } else if color == brownButton.backgroundColor {
            brownButton.layer.borderColor = UIColor.black.cgColor
            brownButton.layer.borderWidth = 4
        }
    }
    
    //Allows keyboard to be dismissed by tapping somewhere else
    @objc func dismissKeyboard() {
        view.endEditing(true)
        twoChars(textField: minutesTextField!, maxLength: 2)
        twoChars(textField: secondsTextField!, maxLength: 2)
        
        if secondsTextField.text!.count < 2 && secondsTextField.text != "" {
            secondsTextField.text = "0" + secondsTextField.text!
        }
        
        if minutesTextField.text!.count < 2 && minutesTextField.text != "" {
            minutesTextField.text = "0" + minutesTextField.text!
        }

        if duplicateTextField.text!.count < 2 && duplicateTextField.text != "" {
            duplicateTextField.text = "0" + duplicateTextField.text!
        }
        
        if duplicateTextField.text! != "" && Int(duplicateTextField.text!) != 0 {
            duplications = Int(duplicateTextField.text!)!
        } else {
            duplications = 1
        }

    }
    
    func addAZero(_ tf: UITextField) {
        if tf.text!.count < 2 && tf.text != "" {
            tf.text = "0" + tf.text!
        }
        
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
    
    @IBAction func donePressed(_ sender: UIButton) {
        if !creatingTemplate {
            if !editingInterval {
                if nameTextField.text != "" && (minutesTextField.text! != "" || secondsTextField.text != "") {
                    for _ in 1...duplications {
                        if color == nil {
                            color = redButton.backgroundColor
                        }
                        //Creating an Interval
                        if nameTextField.text != "" && minutesTextField.text != "" && secondsTextField.text != "" {
                            let newInterval = Interval(context: self.context)
                            newInterval.name = nameTextField.text
                            newInterval.timeInSeconds = Int64(minutesTextField.text!)! * 60 + Int64(secondsTextField.text!)!
                            newInterval.color = color
                            newInterval.closingAudio = soundLink
                            newInterval.midwaySelected = midwaySelected
                            newInterval.midwayAudioString = midwaySoundString
                            newInterval.beginningSelected = beginningSelected
                            newInterval.beginningAudioString = beginningSoundString
                            newInterval.colorString = colorString
                            //Save the interval
                            try! self.context.save()
                            
                        } else if nameTextField.text != "" && secondsTextField.text != "" {
                            let newInterval = Interval(context: self.context)
                            newInterval.name = nameTextField.text
                            newInterval.timeInSeconds = Int64(secondsTextField.text!)!
                            newInterval.color = color
                            newInterval.closingAudio = soundLink
                            newInterval.midwaySelected = midwaySelected
                            newInterval.midwayAudioString = midwaySoundString
                            newInterval.beginningSelected = beginningSelected
                            newInterval.beginningAudioString = beginningSoundString
                            newInterval.colorString = colorString
                            //Save the interval
                            try! self.context.save()
                        } else if nameTextField.text != "" && minutesTextField.text != "" {
                            let newInterval = Interval(context: self.context)
                            newInterval.name = nameTextField.text
                            newInterval.timeInSeconds = Int64(minutesTextField.text!)! * 60
                            newInterval.color = color
                            newInterval.closingAudio = soundLink
                            newInterval.midwaySelected = midwaySelected
                            newInterval.midwayAudioString = midwaySoundString
                            newInterval.beginningSelected = beginningSelected
                            newInterval.beginningAudioString = beginningSoundString
                            newInterval.colorString = colorString
                            //Save the interval
                            try! self.context.save()
                        }
                    }
                    //Segue out
                    performSegue(withIdentifier: "intervalAdded", sender: self)
                    
                }
            } else {
                editIntervals()
                performSegue(withIdentifier: "editMade", sender: self)
            }
        } else {
            if !editingInterval {
                if nameTextField.text != "" && (minutesTextField.text! != "" || secondsTextField.text != "") {
                    for _ in 1...duplications {
                        if color == nil {
                            color = redButton.backgroundColor
                        }
                        //Creating an Interval
                        if nameTextField.text != "" && minutesTextField.text != "" && secondsTextField.text != "" {
                            let newInterval = Interval(context: self.context)
                            newInterval.name = nameTextField.text
                            newInterval.timeInSeconds = Int64(minutesTextField.text!)! * 60 + Int64(secondsTextField.text!)!
                            newInterval.color = color
                            newInterval.closingAudio = soundLink
                            newInterval.midwaySelected = midwaySelected
                            newInterval.midwayAudioString = midwaySoundString
                            newInterval.beginningSelected = beginningSelected
                            newInterval.beginningAudioString = beginningSoundString
                            newInterval.colorString = colorString
                            //Save the interval
                            try! self.context.save()
                        } else if nameTextField.text != "" && secondsTextField.text != "" {
                            let newInterval = Interval(context: self.context)
                            newInterval.name = nameTextField.text
                            newInterval.timeInSeconds = Int64(secondsTextField.text!)!
                            newInterval.color = color
                            newInterval.closingAudio = soundLink
                            newInterval.midwaySelected = midwaySelected
                            newInterval.midwayAudioString = midwaySoundString
                            newInterval.beginningSelected = beginningSelected
                            newInterval.beginningAudioString = beginningSoundString
                            newInterval.colorString = colorString
                            //Save the interval
                            try! self.context.save()
                        } else if nameTextField.text != "" && minutesTextField.text != "" {
                            let newInterval = Interval(context: self.context)
                            newInterval.name = nameTextField.text
                            newInterval.timeInSeconds = Int64(minutesTextField.text!)! * 60
                            newInterval.color = color
                            newInterval.closingAudio = soundLink
                            newInterval.midwaySelected = midwaySelected
                            newInterval.midwayAudioString = midwaySoundString
                            newInterval.beginningSelected = beginningSelected
                            newInterval.beginningAudioString = beginningSoundString
                            newInterval.colorString = colorString
                            //Save the interval
                            try! self.context.save()
                        }
                    }
                    //Segue out
                    performSegue(withIdentifier: "intervalAdded2", sender: self)
                    
                }
            } else {
                if duplicateTextField.text != "" {
                    if Int(duplicateTextField.text!)! > 1 {
                        duplications = Int(duplicateTextField.text!)!
                    }
                }
                editIntervals()
                performSegue(withIdentifier: "editMade2", sender: self)
            }
        }
        
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        if creatingTemplate {
            performSegue(withIdentifier: "cancelToCreate", sender: self)
        } else {
            performSegue(withIdentifier: "cancelToHome", sender: self)
        }
    }
    

   //Color Select Actions
    @IBAction func colorSelected(_ sender: UIButton) {
        redButton.layer.borderColor = UIColor.clear.cgColor
        yellowButton.layer.borderColor = UIColor.clear.cgColor
        orangeButton.layer.borderColor = UIColor.clear.cgColor
        pinkButton.layer.borderColor = UIColor.clear.cgColor
        darkBlueButton.layer.borderColor = UIColor.clear.cgColor
        greenButton.layer.borderColor = UIColor.clear.cgColor
        purpleButton.layer.borderColor = UIColor.clear.cgColor
        lightBlueButton.layer.borderColor = UIColor.clear.cgColor
        blackButton.layer.borderColor = UIColor.clear.cgColor
        whiteButton.layer.borderColor = UIColor.clear.cgColor
        greyButton.layer.borderColor = UIColor.clear.cgColor
        brownButton.layer.borderColor = UIColor.clear.cgColor
        
        
        color = sender.backgroundColor!
        sender.showsTouchWhenHighlighted = true
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.borderWidth = 4
        
        if redButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "red"
        } else if orangeButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "orange"
        } else if yellowButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "yellow"
        } else if pinkButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "pink"
        } else if darkBlueButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "darkBlue"
        } else if greenButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "green"
        } else if purpleButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "purple"
        } else if lightBlueButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "lightBlue"
        } else if blackButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "black"
        } else if whiteButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "white"
        } else if greyButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "grey"
        } else if brownButton.layer.borderColor == UIColor.black.cgColor {
            colorString = "brown"
        }
    }
    
    @IBAction func closingSelectPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectClosingAudio", sender: self)
    }
    
    @IBAction func midwaySelectPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "selectMidwayAudio", sender: self)
    }
    
    @IBAction func beginningSelectPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "selectBeginningAudio", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     //   if segue.identifier == "editMade" || segue.identifier == "intervalAdded" {
        saveName.setValue(nameTextField.text, forKey: "name")
        saveMin.setValue(minutesTextField.text, forKey: "min")
        saveSec.setValue(secondsTextField.text, forKey: "sec")
        saveDups.setValue(duplicateTextField.text, forKey: "duplications")
        saveColorString.setValue(colorString, forKey: "colorString")
        
        if beginningSelected {
            saveIfHasBeginning.setValue("true", forKey: "hasBeginning")
        } else {
            saveIfHasBeginning.setValue("false", forKey: "hasBeginning")
        }
        
        if midwaySelected {
            saveIfHasMidway.setValue("true", forKey: "hasMidway")
        } else {
            saveIfHasMidway.setValue("false", forKey: "hasMidway")
        }
        
        UserDefaults.standard.set(color, forKey: "color")
        
        if segue.identifier == "selectClosingAudio" {
            let vc = segue.destination as! SelectViewController
            vc.selectMidway = false
            vc.selectBeginning = false
            vc.creatingTemplate = creatingTemplate
            vc.editingInterval = editingInterval
            vc.toEdit = toEdit
            saveMidwayName.setValue(midwayAudioName.currentTitle, forKey: "midwayName")
            saveMidwayURLString.setValue(midwaySoundString, forKey: "midwayURLString")
            saveBeginningName.setValue(beginningAudioName.currentTitle, forKey: "beginningName")
            saveBeginningURLString.setValue(beginningSoundString, forKey: "beginningURLString")
        } else if segue.identifier == "selectMidwayAudio" {
            let vc = segue.destination as! SelectViewController
            vc.selectMidway = true
            vc.selectBeginning = false
            vc.creatingTemplate = creatingTemplate
            vc.editingInterval = editingInterval
            vc.toEdit = toEdit
            saveClosingName.setValue(closingAudioName.currentTitle, forKey: "closingName")
            saveClosingURLString.setValue(soundLink.absoluteString, forKey: "closingURLString")
            saveBeginningName.setValue(beginningAudioName.currentTitle, forKey: "beginningName")
            saveBeginningURLString.setValue(beginningSoundString, forKey: "beginningURLString")
        } else if segue.identifier == "selectBeginningAudio" {
            let vc = segue.destination as! SelectViewController
            vc.selectBeginning = true
            vc.selectMidway = false
            vc.creatingTemplate = creatingTemplate
            vc.editingInterval = editingInterval
            vc.toEdit = toEdit
            saveClosingName.setValue(closingAudioName.currentTitle, forKey: "closingName")
            saveClosingURLString.setValue(soundLink.absoluteString, forKey: "closingURLString")
            saveMidwayName.setValue(midwayAudioName.currentTitle, forKey: "midwayName")
            saveMidwayURLString.setValue(midwaySoundString, forKey: "midwayURLString")
        }
       //}
        
    }
    
    func editIntervals() {
        var intNum = 0
        fetchIntervals()
        for interval in intervals.intervalsArray {
            //  fetchIntervals()
            if intNum != toEdit! {
                let newInterval = Interval(context: self.context)
                newInterval.name = interval.name
                newInterval.color = interval.color
                newInterval.timeInSeconds = interval.timeInSeconds
                newInterval.closingAudio = interval.closingAudio
                newInterval.midwaySelected = interval.midwaySelected
                newInterval.midwayAudioString = interval.midwayAudioString
                newInterval.beginningSelected = interval.beginningSelected
                newInterval.beginningAudioString = interval.beginningAudioString
                newInterval.colorString = interval.colorString
                context.delete(interval)
                try! self.context.save()
            } else {
                if nameTextField.text != "" && (minutesTextField.text! != "" && secondsTextField.text != "") {
                    for _ in 1...duplications {
                        let editedInterval = Interval(context: self.context)
                        editedInterval.name = nameTextField.text
                        editedInterval.timeInSeconds = Int64(minutesTextField.text!)! * 60 + Int64(secondsTextField.text!)!
                        editedInterval.color = color
                        editedInterval.closingAudio = soundLink
                        editedInterval.midwaySelected = midwaySelected
                        editedInterval.midwayAudioString = midwaySoundString
                        editedInterval.beginningSelected = beginningSelected
                        editedInterval.beginningAudioString = beginningSoundString
                        editedInterval.colorString = colorString
                    }
                    context.delete(interval)
                    //Save the interval
                    try! self.context.save()
                } else if nameTextField.text != "" && minutesTextField.text! != "" {
                    for _ in 1...duplications {
                        let editedInterval = Interval(context: self.context)
                        editedInterval.name = nameTextField.text
                        editedInterval.timeInSeconds = Int64(minutesTextField.text!)! * 60
                        editedInterval.color = color
                        editedInterval.closingAudio = soundLink
                        editedInterval.midwaySelected = midwaySelected
                        editedInterval.midwayAudioString = midwaySoundString
                        editedInterval.beginningSelected = beginningSelected
                        editedInterval.beginningAudioString = beginningSoundString
                        editedInterval.colorString = colorString
                    }
                    
                    context.delete(interval)
                    //Save the interval
                    try! self.context.save()
                } else if nameTextField.text != "" && secondsTextField.text! != "" {
                    let editedInterval = Interval(context: self.context)
                    for _ in 1...duplications {
                        editedInterval.name = nameTextField.text
                        editedInterval.timeInSeconds = Int64(secondsTextField.text!)!
                        editedInterval.color = color
                        editedInterval.closingAudio = soundLink
                        editedInterval.midwaySelected = midwaySelected
                        editedInterval.midwayAudioString = midwaySoundString
                        editedInterval.beginningSelected = beginningSelected
                        editedInterval.beginningAudioString = beginningSoundString
                        editedInterval.colorString = colorString
                    }
                    context.delete(interval)
                    //Save the interval
                    try! self.context.save()
                }
            
            }
            intNum += 1
        }
    }


    func fetchIntervals() {
        do {
            self.intervals.intervalsArray = try context.fetch(Interval.fetchRequest())
        }
        catch {
           
        }
    }
    
    
}

extension UserDefaults {

    func color(forKey key: String) -> UIColor? {

        guard let colorData = data(forKey: key) else { return nil }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }

    }

    func set(_ value: UIColor?, forKey key: String) {

        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }

    }

}
