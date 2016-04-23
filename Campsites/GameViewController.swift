//
//  GameViewController.swift
//  Campsites
//
//  Created by Ryan Kreiter on 4/20/16.
//  Copyright (c) 2016 Ryan Kreiter. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var tentNumberLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var clearErrorsButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var yourTimeLabel: UILabel!
    @IBOutlet weak var winView: UIView!
    
    // The scene draws the tiles and cookie sprites, and handles swipes.
    var scene: GameScene!
    var level: Level!
    var gridSize: Int!
    var difficulty: String!
    var startTime: CFAbsoluteTime!
    var playingGame = true
    var playTime = 0
    
    // Tile colors
    let green = SKColor(red: 211.0/255.0, green: 234.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    let greenHeader = SKColor(red: 123.0/255.0, green: 149.0/255.0, blue: 99.0/255.0, alpha: 1.0)
    let red = SKColor(red: 187.0/255.0, green: 86.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    let grey = SKColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    
    // Font sizes
    let smallFont = CGFloat(30)
    let mediumFont = CGFloat(40)
    let largeFont = CGFloat(50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation bar for the view
        let button = UIBarButtonItem(title: "Restart", style: .Plain, target: self, action: #selector(GameViewController.restart))
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.title = "Campsites"
        
        // Configure the view.
        let skView = self.view as! SKView
        scene = GameScene(size: skView.bounds.size)
        scene.viewController = self
        scene.gridSize = gridSize
        
        // Set up the level and draw the puzzle
        level = Level(levelName: difficulty, size: gridSize)
        startTime = CFAbsoluteTimeGetCurrent()
        tentNumberLabel.text = "\(level.tentsRemaining)"
        timerLabel.text = "0"
        clearErrorsButton.addTarget(self, action: #selector(GameViewController.clearErrors), forControlEvents: UIControlEvents.TouchUpInside)
        undoButton.addTarget(self, action: #selector(GameViewController.undo), forControlEvents: UIControlEvents.TouchUpInside)
        
        if(gridSize == 11){
            scene.drawBoard(level.grid, treeColor: green, fontSize: largeFont)
        }
        else if(gridSize == 16){
            scene.drawBoard(level.grid, treeColor: green, fontSize: mediumFont)
        }
        else{
            scene.drawBoard(level.grid, treeColor: green, fontSize: smallFont)
        }
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        startTimer()
        
        skView.presentScene(scene)
    }

    func startTimer(){
        if(playingGame){
            let wait = SKAction.waitForDuration(1)
            let run = SKAction.runBlock {
                self.playTime += 1
                self.timerLabel.text = "\(self.playTime)"
            }
            scene.runAction(SKAction.repeatActionForever(SKAction.sequence([wait, run])))
        }
    }
    
    func restart() {
        for row in 0..<gridSize-1 {
            for col in 0..<gridSize-1 {
                if(level.grid[row][col] != 1){
                    level.removeObject(col, row: row)
                    scene.removeGamePiece("(\(row+1),\(col+1))")
                }
                scene.changeTileColor("(\(gridSize),\(col))", color: grey)
            }
            scene.changeTileColor("(\(row),\(gridSize))", color: grey)
        }
        playTime = 0
        tentNumberLabel.text = "\(level.tentsRemaining)"
    }
    
    func handleTouch(tile: String){
        let location = getLocation(tile)
        let col = location.col-1
        let row = location.row-1
        
        // Tapping on header row and column does nothing
        if(location.col == gridSize || location.row == gridSize){
            return
        }
        
        // Determine piece to place
        if(level.grid[row][col] == 0){
            // Place tent
            if(level.addObject(col, row: row, obj: 2)){
                scene.addGamePiece(tile, spriteName: "tent", color: green)
            }
            else{
                scene.addGamePiece(tile, spriteName: "tent", color: red)
            }
        }
        else if(level.grid[row][col] == 2){
            // Place sand
            level.addObject(col, row: row, obj: 3)
            scene.addGamePiece(tile, spriteName: "sand", color: green)
        }
        else{
            // Empty tile
            level.removeObject(col, row: row)
            scene.removeGamePiece(tile)
        }
        
        // Update row and column headers
        updateHeaders(row, col: col)
        
        // Update buttons and counters
        tentNumberLabel.text = "\(level.tentsRemaining)"
        if(level.moves.size() > 0 && undoButton.hidden){
            undoButton.hidden = false
        }
        if(level.tilesFilled > 0 && clearErrorsButton.hidden){
            clearErrorsButton.hidden = false
        }
        else if(level.tilesFilled == 0 && !clearErrorsButton.hidden){
            clearErrorsButton.hidden = true
        }
        
        // Check solution only if all tents placed
        if(level.tentsRemaining == 0){
            if(level.solved()){
                // Winner popup
                playingGame = false
                yourTimeLabel.text = timerLabel.text! + " seconds"
                winView.hidden = false
                let wait = SKAction.waitForDuration(5)
                let run = SKAction.runBlock {
                    // Go back to home screen
                    self.navigationController?.popViewControllerAnimated(true)
                }
                scene.runAction(SKAction.sequence([wait, run]))
            }
        }
    }
    
    // Gets row and column number from tile name
    func getLocation(name: String) -> (row: Int, col: Int) {
        let res = name.componentsSeparatedByString(",")
        let sRow = res[0].componentsSeparatedByString("(")[1]
        let sCol = res[1].componentsSeparatedByString(")")[0]
        return (row: Int(sRow)!, col: Int(sCol)!)
    }
    
    // Change header colors
    func updateHeaders(row: Int, col: Int){
        if(level.checkCol(col) == 0){
            scene.changeTileColor("(\(gridSize),\(col+1))", color: greenHeader)
        }
        else if(level.checkCol(col) < 0){
            scene.changeTileColor("(\(gridSize),\(col+1))", color: red)
        }
        else{
            scene.changeTileColor("(\(gridSize),\(col+1))", color: grey)
        }
        if(level.checkRow(row) == 0){
            scene.changeTileColor("(\(row+1),\(gridSize))", color: greenHeader)
        }
        else if(level.checkRow(row) < 0){
            scene.changeTileColor("(\(row+1),\(gridSize))", color: red)
        }
        else{
            scene.changeTileColor("(\(row+1),\(gridSize))", color: grey)
        }
    }
    
    // Removes incorrect icons from board
    func clearErrors(sender:UIButton!)
    {
        for row in 0..<gridSize-1 {
            for col in 0..<gridSize-1 {
                if(level.grid[row][col] != level.fullGrid[row][col] &&
                   level.grid[row][col] != 0) {
                    level.removeObject(col, row: row)
                    scene.removeGamePiece("(\(row+1),\(col+1))")
                    updateHeaders(row, col: col)
                    playTime += 30
                    tentNumberLabel.text = "\(level.tentsRemaining)"
                }
            }
        }
    }
    
    // Undoes last move made
    func undo(sender:UIButton!)
    {
        if let res = level.undoMove() {
            if(res.prev == 0){
                scene.removeGamePiece("(\(res.row+1),\(res.col+1))")
            }
            else if(res.prev == 2) {
                if(level.checkTent(res.col, row: res.row)){
                    scene.addGamePiece("(\(res.row+1),\(res.col+1))", spriteName: "tent", color: green)
                }
                else{
                    scene.addGamePiece("(\(res.row+1),\(res.col+1))", spriteName: "tent", color: red)
                }
            }
            else if(res.prev == 3) {
                scene.addGamePiece("(\(res.row+1),\(res.col+1))", spriteName: "sand", color: green)
            }
            
            if(level.moves.size() == 0){
                undoButton.hidden = true
            }
            updateHeaders(res.row, col: res.col)
            tentNumberLabel.text = "\(level.tentsRemaining)"
        }
        else {
            undoButton.hidden = true
        }
        
        if(level.tilesFilled == 0 && !clearErrorsButton.hidden){
            clearErrorsButton.hidden = true
        }
    }
    
    // Provided
    override func shouldAutorotate() -> Bool {
        return true
    }

    // Provided
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    // Provided
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
