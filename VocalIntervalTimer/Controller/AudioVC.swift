import UIKit
import MobileCoreServices
import AVFoundation

class AudioViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var numOfRecordings = 0
    var totalEver = 0
    
    var audioPlayer: AVAudioPlayer?
    
    var audioPaths = AudioPaths()
    
    //IBOutlets
    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reorderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up intervalsTableView
        audioTableView.dataSource = self
        audioTableView.delegate = self
        audioTableView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioCell")
         //Load core data items into tableView
         fetchAudioCells()
        
        
        //Keeping numOfRecordings & totalRecorded up to date:
        if let number: Int = UserDefaults.standard.object(forKey: "number") as? Int {
            numOfRecordings = number
        }
        
        if let totalRecorded: Int = UserDefaults.standard.object(forKey: "totalEver") as? Int {
            totalEver = totalRecorded
        }
     
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Your Recordings", attributes: underlineAttribute)
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
    
    
    @IBAction func backHomePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "homeFromAudio", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if audioPlayer != nil {
        audioPlayer!.stop()
        }
    }
    
    //Allows user to delete all sound files and sets UserDefaults for numOfRecordings back to 0
    @IBAction func deleteAllPressed(_ sender: UIButton) {
    //NOTE //Add in an alert for the user to confirm they're gonna delete all their audio files
        
        for sound in audioPaths.pathsArray {
            context.delete(sound)
            try! context.save()
        }
        
        numOfRecordings = 0
        UserDefaults.standard.set(numOfRecordings, forKey: "num")
        totalEver = 0
        UserDefaults.standard.set(totalEver, forKey: "total")
        
        audioPaths.pathsArray.removeAll()
        fetchAudioCells()
    }
    
    //Saves the sound file to CoreData
    func saveToCoreData(_ audioFileName: URL) {
        let newAudio = AudioPath(context: self.context)
        newAudio.link = audioFileName
        let nameToStrip = audioFileName.lastPathComponent
        newAudio.name = stripFileExtension(nameToStrip)
        try! context.save()
        
    }
    
    func stripFileExtension ( _ filename: String ) -> String {
        var components = filename.components(separatedBy: ".")
        guard components.count > 1 else { return filename }
        components.removeLast()
        return components.joined(separator: ".")
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
       let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeAudio as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    //Allows user to rearrange pre-existing intervals
    @IBAction func reorderPressed(_ sender: Any) {
        if audioPaths.pathsArray.count > 1 {
        audioTableView.isEditing = !audioTableView.isEditing
        
        switch audioTableView.isEditing {
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
}

extension AudioViewController: UITableViewDataSource {
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

extension AudioViewController: UITableViewDelegate {
   //Swipe to delete capablility
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Swipe to delete action
        let swipeDelete = UIContextualAction(style: .destructive, title: "") { [self] (action, view, completionHandler) in
            //The interval to be removed:
            let soundToDelete = audioPaths.pathsArray[indexPath.row]
            //Removing the interval
            self.context.delete(soundToDelete)
            //Save the action
            do {
                try self.context.save()
            } catch {
                
            }
            //Re-fetch data
            self.fetchAudioCells()
        }
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
    
    //FOR ALLOWING USERS TO DRAG AND DROP CELLS IN THE TABLE VIEW
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let soundInsert = audioPaths.pathsArray[sourceIndexPath.row]
      //  context.delete(intervals.intervalsArray[sourceIndexPath.row])
        audioPaths.pathsArray.remove(at: sourceIndexPath.row)
        //context.insert(intervalInsert)
        audioPaths.pathsArray.insert(soundInsert, at: destinationIndexPath.row)
        
        for sound in audioPaths.pathsArray {
            let newAudio = AudioPath(context: self.context)
            newAudio.name = sound.name
            newAudio.link = sound.link
            context.delete(sound)
            try! context.save()
            self.fetchAudioCells()
            
        }

        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //FOR PLAYING THE AUDIO OF A CELL WHEN IT IS CLICKED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        
        let soundPath = self.audioPaths.pathsArray[indexPath.row].link
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.isOtherAudioPlaying {
                _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
            } else {
                _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: soundPath!)
            audioPlayer!.play()
        } catch {
            
        }
    }
}

extension AudioViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            numOfRecordings += 1
            totalEver += 1
            
            saveToCoreData(selectedFileURL)
            fetchAudioCells()
        } else {
            do {
                numOfRecordings += 1
                totalEver += 1
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                saveToCoreData(selectedFileURL)
                fetchAudioCells()
            }
            catch {
                
            }
        }
        
        
    }
}
