//
//  GameVC.swift
//  2048
//
//  Created by Jeffrey Hu on 8/3/17.
//  Copyright © 2017 Jeffrey Hu. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    @IBOutlet weak var cell00: UILabel!
    @IBOutlet weak var cell01: UILabel!
    @IBOutlet weak var cell02: UILabel!
    @IBOutlet weak var cell03: UILabel!
    @IBOutlet weak var cell10: UILabel!
    @IBOutlet weak var cell11: UILabel!
    @IBOutlet weak var cell12: UILabel!
    @IBOutlet weak var cell13: UILabel!
    @IBOutlet weak var cell20: UILabel!
    @IBOutlet weak var cell21: UILabel!
    @IBOutlet weak var cell22: UILabel!
    @IBOutlet weak var cell23: UILabel!
    @IBOutlet weak var cell30: UILabel!
    @IBOutlet weak var cell31: UILabel!
    @IBOutlet weak var cell32: UILabel!
    @IBOutlet weak var cell33: UILabel!
    @IBOutlet weak var gridView: GridView!
    
    var cellArray = [[UILabel?]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupListener()
        cellArray = [[cell00, cell01, cell02, cell03],[cell10, cell11, cell12, cell13],[cell20, cell21, cell22, cell23],
                     [cell30, cell31, cell32, cell33]]
        gridView.grid.updateCellTitles()
        gridView.grid.generateRandom()
        addSwipeHandlerUp()
        addSwipeHandlerDown()
        addSwipeHandlerRight() 
        addSwipeHandlerLeft()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//handles notifications
extension GameVC {
    func setupListener() {
        let notificationSelector = #selector(updateCellTitles(notification:))
        NotificationCenter.default.addObserver(self,
                                                selector: notificationSelector,
                                                name: Names.cellValues,
                                                object: nil)
    }
    
    func updateCellTitles(notification: Notification) {
        guard let cells = notification.object as? [[Cell]] else {
            return
        }
        for x in 0..<4 {
            for y in 0..<4 {
                if let value = cells[x][y].value {
                    cellArray[x][y]?.text = ("\(String(describing: value))")
                    cellArray[x][y]?.shadowColor = UIColor.brown
                } else {
                    cellArray[x][y]?.text = ("")
                }
            }
        }
    }
}

//recognizes gestures for swiping up, down, left, right
extension GameVC {
    func addSwipeHandlerUp() {
        let handler = #selector(userSwipedUp(recognizer:))
        let SwipeRecognizer = UISwipeGestureRecognizer(target: self, action: handler)
        SwipeRecognizer.direction = .up
        SwipeRecognizer.numberOfTouchesRequired = 1
        gridView.addGestureRecognizer(SwipeRecognizer)
    }
    
    func userSwipedUp(recognizer: UISwipeGestureRecognizer) {
        gridView.grid.up()
    }
    
    func addSwipeHandlerDown() {
        let handler = #selector(userSwipedDown(recognizer:))
        let SwipeRecognizer = UISwipeGestureRecognizer(target: self, action: handler)
        SwipeRecognizer.direction = .down
        SwipeRecognizer.numberOfTouchesRequired = 1
        gridView.addGestureRecognizer(SwipeRecognizer)
    }
    
    func userSwipedDown(recognizer: UISwipeGestureRecognizer) {
        gridView.grid.down()
    }
    
    func addSwipeHandlerRight() {
        let handler = #selector(userSwipedRight(recognizer:))
        let SwipeRecognizer = UISwipeGestureRecognizer(target: self, action: handler)
        SwipeRecognizer.direction = .right
        SwipeRecognizer.numberOfTouchesRequired = 1
        gridView.addGestureRecognizer(SwipeRecognizer)
    }
    
    func userSwipedRight(recognizer: UISwipeGestureRecognizer) {
        gridView.grid.right()
    }
    
    func addSwipeHandlerLeft() {
        let handler = #selector(userSwipedLeft(recognizer:))
        let SwipeRecognizer = UISwipeGestureRecognizer(target: self, action: handler)
        SwipeRecognizer.direction = .left
        SwipeRecognizer.numberOfTouchesRequired = 1
        gridView.addGestureRecognizer(SwipeRecognizer)
    }
    
    func userSwipedLeft(recognizer: UISwipeGestureRecognizer) {
        gridView.grid.left()
    }
}

