import UIKit
import AVFoundation

class WorkoutViewController: UIViewController {
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var audioPlayer = AVAudioPlayer()
    var silentURL = Bundle.main.url(forResource: "silence", withExtension: "mp3")
    
    
    var rounds = 1
    var duration = 0
    
    //For making the app run in the background
    var intervalTimeLeft = 0
    var hr = 0
    var min = 0
    var sec = 0
    
    var intervals:[WOInterval] = []
    
    //Variables needed for countdown function
    var timer = Timer()
    var position = 0
    var seconds = 0
    let indexPath = IndexPath(item: 0, section: 0)
    var timesArray: [Int] = []
    
    //for the total time label
    var totalWorkoutTime: Int = 0
    
    //for setting up custom audio to play
    var closingAudioDuration: CMTime?
    var closingAudioDurationInSec = 0
    var whenToPlayClose = 0
    var beginningAudioDuration: CMTime?
    var beginningAudioDurationInSec = 0
    var beginningOver: Int?
    var beginningWasSelected = false
    var midwayAudioDuration: CMTime?
    var midwayAudioDurationInSec = 0
    var whenToPlayMidway: Int?
    var midwayOver: Int?
    var midwayIsSelected = false
    var nextClosingURL = Bundle.main.url(forResource: "Default", withExtension: "wav")
    
    //For the pause function
    @IBOutlet weak var pauseButton: UIButton!
    var paused = false
    
    @IBOutlet weak var intervalsTableView: UITableView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti: )), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    
       //Make sure the user's music stays on
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.isOtherAudioPlaying {
            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
        } else {
            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
        }
        
        
        intervalsTableView.dataSource = self
        intervalsTableView.register(UINib(nibName: "IntervalsTableViewCell", bundle: nil), forCellReuseIdentifier: "IntervalCell")
        
        self.intervalsTableView.rowHeight = 120
        
        //Perform the countdowns
        appendTime()
        for _ in timesArray {
            countdown(position: position)
            intervalsTableView.reloadData()
            //Total Workout Time
            setTotalWorkoutTime(totalWorkoutTime)
        
        }
        
        let shared = UserDefaults.standard
        shared.set(Date(), forKey: "savedTime")
        
        nextClosingURL = intervals[0].closingAudio
        let closingAudioAsset = AVURLAsset.init(url: nextClosingURL!, options: nil)
        closingAudioDuration = closingAudioAsset.duration
        closingAudioDurationInSec = Int(CMTimeGetSeconds(closingAudioDuration!))
        whenToPlayClose = Int(intervals[0].timeInSeconds) - (Int(intervals[0].timeInSeconds) - closingAudioDurationInSec)
        
        if intervals[0].midwaySelected {
            let midwayAudioAsset = AVURLAsset.init(url: Foundation.URL(string: intervals[0].midwayAudioString)!)
            midwayAudioDuration = midwayAudioAsset.duration
            midwayAudioDurationInSec = Int(CMTimeGetSeconds(midwayAudioDuration!))
            whenToPlayMidway = Int(intervals[0].timeInSeconds) / 2
            midwayOver = whenToPlayMidway! + midwayAudioDurationInSec
            midwayIsSelected = true
        }
        
        if intervals[0].beginningSelected {
            let beginningAudioAsset = AVURLAsset.init(url: Foundation.URL(string: intervals[0].beginningAudioString)!)
            beginningAudioDuration = beginningAudioAsset.duration
            beginningAudioDurationInSec = Int(CMTimeGetSeconds(beginningAudioDuration!))
            beginningOver = Int(intervals[0].timeInSeconds) - beginningAudioDurationInSec
            beginningWasSelected = true
        }
        
    }
    
    @objc func pauseWhenBackground(noti: Notification) {
        let shared = UserDefaults.standard
        shared.set(Date(), forKey: "savedTime")
        
        backgroundPlay()
    }
    
    @objc func willEnterForeground(noti: Notification) {
      //Updates the timeleft in the array, the total time label, deletes from and updates the intervalsTableView
   /*     if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
            (hr, min, sec) = WorkoutViewController.getTimeDifference(startDate: savedDate)
            let timePassed = (hr * 3600) + (min * 60) + sec
            updateIntervals(timePassed)
            setTotalWorkoutTime(totalWorkoutTime)
            intervalsTableView.reloadData()
        } */
   /*
         
        if intervals.count > 0 {
            backgroundPlay()
        }*/
        
        
    }
    
/*    static func getTimeDifference(startDate: Date) -> (Int, Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
        return (components.hour!, components.minute!, components.second!)
    } */
    
    func updateIntervals(_ timePassed: Int) {
        var timePassedx = timePassed
        if timePassedx < totalWorkoutTime {
            while timePassedx > 0 {
                if timePassedx > seconds {
                    totalWorkoutTime -= seconds
                    timePassedx -= seconds
                    position += 1
                    seconds = timesArray[position]
                    intervals.remove(at: 0)
                    intervalsTableView.reloadData()
                } else {
                    timesArray[position] -= timePassedx
                    seconds = timesArray[position]
                    totalWorkoutTime -= timePassedx
                    intervals[0].timeInSeconds -= Int64(timesArray[position])
                    timePassedx = 0
                    intervalsTableView.reloadData()
                }
            }
        } else {
            seconds = -1
            timesArray = []
            totalWorkoutTime = 0
            setTotalWorkoutTime(totalWorkoutTime)
            intervals = []
            intervalsTableView.reloadData()
        }
        
    }
    
    //Sets totalWorkoutTime Label
    func setTotalWorkoutTime(_ totalTime: Int) {
        let hours = totalWorkoutTime / 3600
        let min: Int
        if totalWorkoutTime < 3600 {
            min = totalWorkoutTime / 60
        } else {
            min = (totalWorkoutTime % 3600) / 60
        }
        let sec = totalWorkoutTime % 60
        
        if totalWorkoutTime >= 3600 {
            totalTimeLabel.text = String(format: "%02d : %02d :%02d", hours, min, sec)
        }
        else {
            totalTimeLabel.text = String(format: "%02d : %02d", min, sec)
        }
        
    }
    
    //FUNCTIONS RELATED TO COUNTDOWN
    //Appends total time of an interval to timesArray. //Also finds the total time of the workout
    func appendTime() {
        for interval in intervals {
            timesArray.append(Int(interval.timeInSeconds))
            totalWorkoutTime += Int(interval.timeInSeconds)
        }
    }
    
    func countdown(position: Int) {
        timer.invalidate()
        seconds = timesArray[position]
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        }
        
    @objc func updateTimer() {
        if paused == false {
            if seconds > 0 {

                if intervals[0].beginningSelected {
                    do {
                        let audioSession = AVAudioSession.sharedInstance()
                        if audioSession.isOtherAudioPlaying {
                            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                        } else {
                            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                        }
                        audioPlayer = try AVAudioPlayer(contentsOf: Foundation.URL(string: intervals[0].beginningAudioString)!)
                        audioPlayer.play()
                    } catch {
                        print("Error")
                    }
                    intervals[0].beginningSelected = false
                    beginningWasSelected = true
                } else {
                    beginningOver = timesArray[0]
                }
                
        
                
                
                seconds -= 1
                timesArray[0] -= 1
                //Updates durationLabel in the cell
                intervals[0].timeInSeconds = Int64(seconds)
                intervalsTableView.reloadData()
                totalWorkoutTime -= 1
                setTotalWorkoutTime(totalWorkoutTime)
               
                if midwayIsSelected {
                    if whenToPlayMidway == seconds {
                        print(intervals[0].midwayAudioString)
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            if audioSession.isOtherAudioPlaying {
                                _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                            } else {
                                _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                            }
                            audioPlayer = try AVAudioPlayer(contentsOf: Foundation.URL(string: intervals[0].midwayAudioString)!)
                            audioPlayer.play()
                        } catch {
                            print("Error")
                        }
                    }
                }
                
                if whenToPlayClose == seconds {
                    //For the sound
               //     audioPlayer.stop()
                    do {
                        let audioSession = AVAudioSession.sharedInstance()
                        if audioSession.isOtherAudioPlaying {
                            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                        } else {
                            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                        }
                        audioPlayer = try AVAudioPlayer(contentsOf: nextClosingURL!)
                        audioPlayer.play()
                    } catch {
                        
                    }
                }
                
                if !audioPlayer.isPlaying {
                    do {
                        let audioSession = AVAudioSession.sharedInstance()
                        if audioSession.isOtherAudioPlaying {
                            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                        } else {
                            _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                        }
                    }
                    backgroundPlay()
                }
                
            } else if self.position < timesArray.count - 1 {
                //This is here to turn the music back up after the audio plays
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    if audioSession.isOtherAudioPlaying {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    } else {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
                    }
                }
                
                nextClosingURL = intervals[1].closingAudio
                let audioAsset = AVURLAsset.init(url: nextClosingURL!, options: nil)
                closingAudioDuration = audioAsset.duration
                closingAudioDurationInSec = Int(CMTimeGetSeconds(closingAudioDuration!))
                whenToPlayClose = Int(intervals[0].timeInSeconds) - (Int(intervals[0].timeInSeconds) - closingAudioDurationInSec)
                
                if intervals[1].midwaySelected {
                    let midwayAudioAsset = AVURLAsset.init(url: Foundation.URL(string: intervals[1].midwayAudioString)!)
                    midwayAudioDuration = midwayAudioAsset.duration
                    midwayAudioDurationInSec = Int(CMTimeGetSeconds(midwayAudioDuration!))
                    whenToPlayMidway = Int(intervals[1].timeInSeconds) / 2
                    midwayOver = whenToPlayMidway! + midwayAudioDurationInSec
                    midwayIsSelected = true
                    } else {
                        midwayIsSelected = false
                        whenToPlayMidway = nil
                }
                
                if intervals[1].beginningSelected {
                    let beginningAudioAsset = AVURLAsset.init(url: Foundation.URL(string: intervals[1].beginningAudioString)!)
                    beginningAudioDuration = beginningAudioAsset.duration
                    beginningAudioDurationInSec = Int(CMTimeGetSeconds(beginningAudioDuration!))
                    beginningOver = Int(intervals[1].timeInSeconds) - beginningAudioDurationInSec
                }
                
                self.position += 1
                intervals.remove(at: 0)
                intervalsTableView.deleteRows(at: [indexPath], with: .none)
                seconds = timesArray[position]
                
                    backgroundPlay()
                
                
            } else if seconds == 0 {
       
                intervals.remove(at: 0)
                intervalsTableView.deleteRows(at: [indexPath], with: .none)
                seconds = -1
                performSegue(withIdentifier: "workoutComplete", sender: self)
            }
        } else {
            seconds -= 0

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "endWorkout" {
            let vc = segue.destination as! HomeViewController
            vc.fetchIntervals()
        }
    }
    
    //Stops the current timer counting down or restarts it
    @IBAction func pausePressed(_ sender: UIButton) {
        if paused == false {
            paused = true
            pauseButton.setTitle("Resume", for: .normal)
        //    if audioPlayer != nil {
                audioPlayer.pause()
      //      }
        } else {
            paused = false
            pauseButton.setTitle("Paused", for: .normal)
         //   if audioPlayer != nil {
                audioPlayer.play()
         //   }
        }
        
        

    }
    
    //Ends workout & switches screens
    @IBAction func endPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "endWorkout", sender: self)
        timer.invalidate()
       // if audioPlayer != nil {
            audioPlayer.stop()
     //   }
        
    }
    
    func backgroundPlay() {
        if beginningWasSelected && midwayIsSelected {
            if seconds < beginningOver! && seconds > whenToPlayMidway! {
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    if audioSession.isOtherAudioPlaying {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    } else {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    }
                    audioPlayer = try AVAudioPlayer(contentsOf: silentURL!)
                    audioPlayer.play()
                    audioPlayer.numberOfLoops =  -1
                } catch {
                    print("Error")
                }
                
                print("First Statement")
            }
        } else if beginningWasSelected {
            if seconds < beginningOver! {
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    if audioSession.isOtherAudioPlaying {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    } else {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    }
                    audioPlayer = try AVAudioPlayer(contentsOf: silentURL!)
                    audioPlayer.play()
                    audioPlayer.numberOfLoops =  -1
                } catch {
                    print("Error")
                }
                
                print("Second Statement")
            }
        } else if midwayIsSelected {
            if ((seconds < midwayOver! && seconds > whenToPlayClose) || seconds > whenToPlayMidway!) {
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    if audioSession.isOtherAudioPlaying {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    } else {
                        _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                    }
                    audioPlayer = try AVAudioPlayer(contentsOf: silentURL!)
                    audioPlayer.play()
                    audioPlayer.numberOfLoops =  -1
                } catch {
                    print("Error")
                }
                print("Third Statement")
            }
        } else if seconds > whenToPlayClose {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                if audioSession.isOtherAudioPlaying {
                    _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                } else {
                    _ = try? audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                }
                audioPlayer = try AVAudioPlayer(contentsOf: silentURL!)
                audioPlayer.play()
                audioPlayer.numberOfLoops =  -1
            } catch {
                print("Error")
            }
            print("Fourth Statement")
        }
        
    }
    
}

extension WorkoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //this let is for the cell
        let intervalCell = intervalsTableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath) as! IntervalsTableViewCell
      
        //this let is for the data of the particular interval in the array
        let interval = self.intervals[indexPath.row]
            
        intervalCell.nameLabel.text = interval.name
        duration = Int(interval.timeInSeconds)
        let min = duration / 60
        let sec = duration % 60
        intervalCell.durationLabel.text = String(format: "%02d : %02d", min, sec)
        intervalCell.cellBackground.backgroundColor = interval.color
        
        return intervalCell
    
    }
}
