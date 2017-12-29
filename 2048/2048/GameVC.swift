//
//  GameVC.swift
//  2048
//
//  Created by Jeffrey Hu on 8/3/17.
//  Copyright © 2017 Jeffrey Hu. All rights reserved.
//

import UIKit
import CoreData

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
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    
    var highScore = 0
    var currentScore = 0
    
    @IBAction func reset(_ sender: Any) {
        if let context = container?.viewContext{
            if let savedValues = fetchDatabase(with: context){
                deleteDatabase(with: savedValues, and: context)
            }
        }
        for row in 0..<4{
            for col in 0..<4{
                gridView.grid.cells[row][col].value = nil
            }
        }
        gridView.grid.generateRandom()
        gridView.grid.updateCellTitles()
        resetCurrentScore()
    }
    
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var cellArray = [[UILabel?]]()
    var saved = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupListener()
        addSwipeHandlerUp()
        addSwipeHandlerDown()
        addSwipeHandlerRight()
        addSwipeHandlerLeft()
        cellArray = [[cell00, cell01, cell02, cell03],[cell10, cell11, cell12, cell13],[cell20, cell21, cell22, cell23],
                     [cell30, cell31, cell32, cell33]]
        
        updateScoresFromDatabase()
        
        
        // Do any additional setup after loading the view.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let context = container?.viewContext{
            for row in 0..<4{
                for col in 0..<4{
                    let valueObject = GridValue(context: context)
                    valueObject.row = Int32(row)
                    valueObject.col = Int32(col)
                    if let num = gridView.grid.cells[row][col].value {
                        valueObject.value = Int32(num)
                    } else {
                        valueObject.value = Int32(0)
                    }
                }
            }
            try? context.save()
            saved = true
        }
    }
    
    func updateScoresToDatabase(){
        if let context = container?.viewContext{
            let request : NSFetchRequest<ScoreKeeper> = ScoreKeeper.fetchRequest()
            if let scores = try? context.fetch(request){
                for score in scores{
                    context.delete(score)
                }
            }
                
                
                
            let scoreObject = ScoreKeeper(context: context)
            scoreObject.currentScore = Int32(currentScore)
            scoreObject.highScore = Int32(highScore)
            try? context.save()
        }
    }
    
    func updateScoresFromDatabase(){
        if let context = container?.viewContext{
            let request : NSFetchRequest<ScoreKeeper> = ScoreKeeper.fetchRequest()
            if let scores = try? context.fetch(request){
                if scores.count > 0{
                    gridView.grid.currentScore = Int(scores[0].currentScore)
                    gridView.grid.highScore = Int(scores[0].highScore)
                }
            }
        }
    }
    
    func resetCurrentScore(){
        gridView.grid.currentScore = 0
        gridView.grid.updateCellTitles()
        if let context = container?.viewContext{
            let request : NSFetchRequest<ScoreKeeper> = ScoreKeeper.fetchRequest()
            if let scores = try? context.fetch(request){
                if scores.count > 0{
                    scores[0].currentScore = 0
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let context = container?.viewContext{
            if let savedValues = fetchDatabase(with: context){
                updateGridWithDatabase(with: savedValues)
                deleteDatabase(with: savedValues, and: context)
            }
        }

        if saved == false{
            gridView.grid.generateRandom()
        }
        gridView.grid.updateCellTitles()
    }
    
    func fetchDatabase(with context : NSManagedObjectContext) -> [GridValue]?{
            let request : NSFetchRequest<GridValue> = GridValue.fetchRequest()
            if let savedValues = try? context.fetch(request) {
                return savedValues
            }
        return nil
    }
    
    func updateGridWithDatabase(with savedValues : Array<GridValue>){
        for object in savedValues{
            if Int(object.value) != 0 {
                gridView.grid.cells[Int(object.row)][Int(object.col)].value = Int(object.value)
            }
        }
    }
    
    func deleteDatabase(with savedValues: Array<GridValue>, and context : NSManagedObjectContext){
        for object in savedValues{
            context.delete(object)
        }
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
        guard let object = notification.object as? ([[Cell]], Int, Int) else {
            return
        }
        let cells = object.0
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
        currentScore = object.1
        highScore = object.2
        currentScoreLabel.text = "Score: \(currentScore)"
        highScoreLabel.text = "Record: \(highScore)"
        if object.1 >= object.2 {
            currentScoreLabel.textColor = UIColor(displayP3Red: 0.85, green: 0.1, blue: 0.2, alpha: 1.0)
            highScoreLabel.textColor = UIColor(displayP3Red: 0.85, green: 0.1, blue: 0.2, alpha: 1.0)
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

