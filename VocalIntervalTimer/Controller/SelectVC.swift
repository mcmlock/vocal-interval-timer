import UIKit

class SelectViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var audioPaths = AudioPaths()
    
    @IBOutlet weak var audioTableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    //These hold data tha's transferred over back to the AddIntervalScreen.
    var selectBeginning = false
    var selectMidway = false
    var soundLink: URL?
    var soundFileName = ""
    var beginningString = ""
    var midwayString = ""
    var creatingTemplate = false
    var editingInterval = false
    var toEdit: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up intervalsTableView
        audioTableView.dataSource = self
        audioTableView.delegate = self
        audioTableView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioCell")
         //Load core data items into tableView
         fetchAudioCells()
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Select", attributes: underlineAttribute)
       titleLabel.attributedText = underlineAttributedString
        
    }
    
    func fetchAudioCells() {

        do {
            self.audioPaths.pathsArray = try context.fetch(AudioPath.fetchRequest())
            
            DispatchQueue.main.async{
                self.audioTableView.reloadData()
            }
        }
        catch {
           
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddIntervalViewController

        vc.creatingTemplate = creatingTemplate
        vc.editingInterval = editingInterval
        vc.toEdit = toEdit
        
        if selectBeginning {
            vc.beginningSelected = true
            vc.saveBeginningName.setValue(self.soundFileName, forKey: "beginningName")
            vc.saveBeginningURLString.setValue(self.beginningString, forKey: "beginningURLString")
            vc.saveIfHasBeginning.setValue("true", forKey: "hasBeginning")
        } else if selectMidway {
            vc.midwaySelected = true
            vc.saveMidwayName.setValue(self.soundFileName, forKey: "midwayName")
            vc.saveMidwayURLString.setValue(self.midwayString, forKey: "midwayURLString")
            vc.saveIfHasMidway.setValue("true", forKey: "hasMidway")
        } else {
            vc.saveClosingName.setValue(self.soundFileName, forKey: "closingName")
            vc.saveClosingURLString.setValue(self.soundLink?.absoluteString, forKey: "closingURLString")
        }
        
        vc.color = UserDefaults.standard.color(forKey: "color")
    }
}

extension SelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioPaths.pathsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //this let is for the cell
        let audioCell = audioTableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioTableViewCell
      
        
        //this let is for the data of the particular interval in the array
        let audioPath = self.audioPaths.pathsArray[indexPath.row]
        
        audioCell.nameLabel.text = audioPath.name
                                                   
        return audioCell
    }
    
}

extension SelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectMidway {
            soundFileName = self.audioPaths.pathsArray[indexPath.row].name!
            midwayString = self.audioPaths.pathsArray[indexPath.row].link!.absoluteString
            performSegue(withIdentifier: "closingAudioSelected", sender: self)
        } else if selectBeginning {
            soundFileName = self.audioPaths.pathsArray[indexPath.row].name!
            beginningString = self.audioPaths.pathsArray[indexPath.row].link!.absoluteString
            performSegue(withIdentifier: "beginningAudioSelected", sender: self)
        } else {
            soundFileName = self.audioPaths.pathsArray[indexPath.row].name!
            soundLink = self.audioPaths.pathsArray[indexPath.row].link
            performSegue(withIdentifier: "midwayAudioSelected", sender: self)
        }
    }
}
