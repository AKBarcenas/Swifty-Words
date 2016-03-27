//
//  ViewController.swift
//  Swifty Words
//
//  Created by Alex on 12/30/15.
//  Copyright © 2015 Alex Barcenas. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    // Labels that dispay information relevant to the game to the player.
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // Buttons that the player can press.
    var letterButtons = [UIButton]()
    // Buttons that the player has already pressed.
    var activatedButtons = [UIButton]()
    // The solutions for the current round of the game.
    var solutions = [String]()
    // The player's current score.
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    // The level that the player is currenly on.
    var level = 1

    /*
     * Function Name: viewDidLoad
     * Parameters: None
     * Purpose: This method stores all of the buttons that will be used for the current level and
     *   adds an action for when the button is pressed.
     * Return Value: None
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
        }
        loadLevel()
    }
    
    /*
     * Function Name: submitTapped
     * Parameters: sender - the button that the player tapped.
     * Purpose: This method checks if the answer that the user entered is valid. If it is valid, then
     *   the answer is displayed and the buttons useed to create the answer will be cleared from the game.
     *   If 7 valid answers have been given, then this method will prompt the user if they want to move on
     *   to the next level.
     * Return Value: None
     */
    
    @IBAction func submitTapped(sender: UIButton) {
        if let solutionPosition = solutions.indexOf(currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitClues = answersLabel.text!.componentsSeparatedByString("\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joinWithSeparator("\n")
            
            currentAnswer.text = ""
            ++score
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: levelUp))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    /*
     * Function Name: levelUp
     * Parameters: action - the action that the user chose.
     * Purpose: This method resets the game and loads the next level for the player.
     * Return Value: None
     */
    
    func levelUp(action: UIAlertAction!) {
        ++level
        solutions.removeAll(keepCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.hidden = false
        }
    }

    /*
     * Function Name: clearTapped
     * Parameters: sender - the button that the player pressed.
     * Purpose: This method clears the player's answer and makes the button that the player
     *   pressed to create their answer reappear.
     * Return Value: None
     */
    
    @IBAction func clearTapped(sender: UIButton) {
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            btn.hidden = false
        }
        
        activatedButtons.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Function Name: loadLevel
     * Parameters: None
     * Purpose: This method processes all of the words from a text file that will be used for the
     *   current level of the game. This method will then set up the game level associated with these
     *   words so that the player can start playing.
     * Return Value: None
     */
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        // Checks if the level can be found.
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt") {
            // Checks if the file for the level has words.
            if let levelContents = try? String(contentsOfFile: levelFilePath, usedEncoding: nil) {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                // This proccesses each line in the file to retrieve the words and clues used for the current level.
                for (index, line) in lines.enumerate() {
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        
        // Sets up the answer and clue labels for the level.
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        // Randomizes the button and word bits.
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterBits) as! [String]
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        // Assigns words bits to the buttons.
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
    
    /*
     * Function Name: letterTapped
     * Parameters: btn - the button that the player tapped.
     * Purpose: This method appends the letters displayed on the button to the player's solution and hides
     *   the button from the player's view.
     * Return Value: None
     */
    
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.hidden = true
    }

}

