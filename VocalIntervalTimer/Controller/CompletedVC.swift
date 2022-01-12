import UIKit
import CoreData
import AVFoundation

class CompletedViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.isOtherAudioPlaying {
                _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! HomeViewController
        vc.fetchIntervals()
    
    }
    
    @IBAction func homePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "homeFromCompleted", sender: self)
    }
    
}
