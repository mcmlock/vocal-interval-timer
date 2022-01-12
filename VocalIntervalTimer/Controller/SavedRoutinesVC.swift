import UIKit
import CoreData

class SavedRoutinesViewController: UIViewController {
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var templates = Templates()
    var intervals = Intervals()
    
    @IBOutlet weak var templatesTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var templateToLoad: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up intervalsTableView
        templatesTableView.dataSource = self
        templatesTableView.delegate = self
        templatesTableView.register(UINib(nibName: "SavedRoutineTableViewCell", bundle: nil), forCellReuseIdentifier: "TemplateCell")
         //Load core data items into tableView
         fetchTemplates()
         fetchIntervals()
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Your Routines", attributes: underlineAttribute)
       titleLabel.attributedText = underlineAttributedString
    }
    
    func fetchTemplates() {

        do {
            self.templates.templatesArray = try context.fetch(Template.fetchRequest())
            
            DispatchQueue.main.async{
                self.templatesTableView.reloadData()
            }
        }
        catch {
           
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "homeFromRoutines", sender: self)
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "createTemplate", sender: self)
    }
    
    //Loads the table view with the intervals stored in core data
    func fetchIntervals() {

        do {
            self.intervals.intervalsArray = try context.fetch(Interval.fetchRequest())

        }
        catch {
           
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadTemplate" {
            let vc = segue.destination as! HomeViewController
            //Clears out any currently loaded intervals.
            for interval in intervals.intervalsArray {
                context.delete(interval)
                try! context.save()
            }
            intervals.intervalsArray.removeAll()
            
            if templates.templatesArray[templateToLoad!].rounds > 1 {
                vc.saveForRounds.setValue(String(templates.templatesArray[templateToLoad!].rounds), forKey: "roundsEntered")
            }
            
            
            //Loads in the ones from template
            loadFromTemplate(templateToLoad!)
        }
        
        if segue.identifier == "createTemplate" {
            let vc = segue.destination as! CreateRoutineViewController
            
            vc.saveTemplateName.setValue("", forKey: "templateName")
        }
    }
    
    func loadFromTemplate(_ whichTemplate: Int) {
        for intervalSpot in 1...templates.templatesArray[whichTemplate].intervalCount {
            let newInterval = Interval(context: self.context)
            
            //Assigning the name to the new interval
            let namesComponents = templates.templatesArray[whichTemplate].intervalNames?.components(separatedBy: "//?/")
            newInterval.name = namesComponents?[Int(intervalSpot - 1)]
            
            //Assigning the timeInSeconds to the new interval
            let timeComponents = templates.templatesArray[whichTemplate].intervalTimes?.components(separatedBy: "//?/")
            newInterval.timeInSeconds = Int64(Int((timeComponents?[Int(intervalSpot - 1)])!)!)
            
            //Assigning the closingAudio to the new interval
            let closingAudiosComponents = templates.templatesArray[whichTemplate].closingAudios?.components(separatedBy: "//?/")
            newInterval.closingAudio = URL(string: (closingAudiosComponents?[Int(intervalSpot - 1)])!)
            
            let beginningsSelectedComponents = templates.templatesArray[whichTemplate].beginningsSelected?.components(separatedBy: "//?/")
            newInterval.beginningSelected = Bool((beginningsSelectedComponents?[Int(intervalSpot - 1)])!)!
            
            let beginningAudiosComponents = templates.templatesArray[whichTemplate].beginningAudios?.components(separatedBy: "//?/")
            newInterval.beginningAudioString = beginningAudiosComponents?[Int(intervalSpot - 1)]

            
            let midwaysSelectedComponents = templates.templatesArray[whichTemplate].midwaysSelected?.components(separatedBy: "//?/")
            newInterval.midwaySelected = Bool((midwaysSelectedComponents?[Int(intervalSpot - 1)])!)!
            
            let midwayAudiosComponents = templates.templatesArray[whichTemplate].midwayAudios?.components(separatedBy: "//?/")
            newInterval.midwayAudioString = midwayAudiosComponents?[Int(intervalSpot - 1)]
            
            let colorsComponents = templates.templatesArray[whichTemplate].intervalColors?.components(separatedBy: "//?/")
            newInterval.color = figureColor((colorsComponents?[Int(intervalSpot - 1)])!)
            
            let intervalColorsComponents = templates.templatesArray[whichTemplate].intervalColors?.components(separatedBy: "//?/")
            newInterval.colorString = intervalColorsComponents?[Int(intervalSpot - 1)]
            
            try! self.context.save()
            
        }
    }
    
    func figureColor(_ colorString: String) -> UIColor {
        if colorString == "red" {
            return UIColor.init(red: CGFloat(214.0/255.0), green: CGFloat(1.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "orange" {
            return UIColor.init(red: CGFloat(254.0/255.0), green: CGFloat(144.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "yellow" {
            return UIColor.init(red: CGFloat(254.0/255.0), green: CGFloat(221.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "pink" {
            return UIColor.init(red: CGFloat(255.0/255.0), green: CGFloat(86.0/255.0), blue: CGFloat(188.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "darkBlue" {
            return UIColor.init(red: CGFloat(12.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(204.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "green" {
          //  return UIColor.init(red: CGFloat(0.0/255.0), green: CGFloat(197.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0))
            return(UIColor.init(named: "correctGreen")!)
        } else if colorString == "purple" {
            return UIColor.init(red: CGFloat(183.0/255.0), green: CGFloat(19.0/255.0), blue: CGFloat(237.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "lightBlue" {
            return UIColor.init(red: CGFloat(23.0/255.0), green: CGFloat(165.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "black" {
            return UIColor.init(red: CGFloat(35.0/255.0), green: CGFloat(32.0/255.0), blue: CGFloat(30.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "white" {
            return UIColor.init(red: CGFloat(218.0/255.0), green: CGFloat(218.0/255.0), blue: CGFloat(218.0/255.0), alpha: CGFloat(1.0))
        } else if colorString == "grey" {
            return UIColor.init(red: CGFloat(82.0/255.0), green: CGFloat(78.0/255.0), blue: CGFloat(78.0/255.0), alpha: CGFloat(1.0))
        }
        
       return UIColor.init(red: CGFloat(139.0/255.0), green: CGFloat(71.0/255.0), blue: CGFloat(50.0/255.0), alpha: CGFloat(1.0))
    }
    
}



extension SavedRoutinesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.templatesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //this let is for the cell
        let templateCell = templatesTableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath) as! SavedRoutineTableViewCell
      
        
        //this let is for the data of the particular interval in the array
        let template = self.templates.templatesArray[indexPath.row]
        
        templateCell.nameLabel.text = template.name
                                                   
        return templateCell
    }
    
}

extension SavedRoutinesViewController: UITableViewDelegate {
   //Swipe to delete capablility
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Swipe to delete action
        let swipeDelete = UIContextualAction(style: .destructive, title: "") { [self] (action, view, completionHandler) in
            //The interval to be removed:
            let templateToDelete = templates.templatesArray[indexPath.row]
            //Removing the interval
            self.context.delete(templateToDelete)
            //Save the action
            do {
                try self.context.save()
            } catch {
                
            }
            //Re-fetch data
            self.fetchTemplates()
        }
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
    
    //FOR ALLOWING USERS TO DRAG AND DROP CELLS IN THE TABLE VIEW
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let templateInsert = templates.templatesArray[sourceIndexPath.row]
      //  context.delete(intervals.intervalsArray[sourceIndexPath.row])
        templates.templatesArray.remove(at: sourceIndexPath.row)
        //context.insert(intervalInsert)
        templates.templatesArray.insert(templateInsert, at: destinationIndexPath.row)
        
        for template in templates.templatesArray {
            let newTemplate = Template(context: self.context)
            newTemplate.name = template.name
            newTemplate.intervalNames = template.intervalNames
            newTemplate.rounds = template.rounds
            context.delete(template)
            try! context.save()
            self.fetchTemplates()
            
        }

        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    //FOR LOADING TEMPLATES WHEN TAPPED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        templateToLoad = indexPath.row
        performSegue(withIdentifier: "loadTemplate", sender: self)
    }
}
