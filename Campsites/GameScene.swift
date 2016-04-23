//
//  GameScene.swift
//  Campsites
//
//  Created by Ryan Kreiter on 4/20/16.
//  Copyright (c) 2016 Ryan Kreiter. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var viewController: GameViewController!
    var touchedTile: SKSpriteNode?
    var gridSize: Int!
    var tileSize: CGSize!

    let gameLayer = SKNode()
    let tileLayer = SKNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //Add layers
        let bSize = CGSizeMake(size.width, size.height)
        let background = SKSpriteNode(color: SKColor.whiteColor(), size: bSize)
        background.position = CGPointMake(size.width/2, size.height/2)
        addChild(background)
        addChild(gameLayer)
        addChild(tileLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        for touch in touches{
            if (tileLayer.nodeAtPoint(touch.locationInNode(tileLayer)).name) != nil {
                touchedTile = tileLayer.nodeAtPoint(touch.locationInNode(tileLayer)) as? SKSpriteNode
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if (tileLayer.nodeAtPoint(touch.locationInNode(tileLayer)) == touchedTile) {
                viewController.handleTouch((touchedTile?.name)!)
            }
        }
        touchedTile = nil
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchedTile = nil
    }
    
    func drawBoard(grid: [[Int]], treeColor: SKColor, fontSize: CGFloat) {
        // Board parameters
        let screenSize = self.frame.size
        let size = (screenSize.width-40)/CGFloat(gridSize)
        let squareSize = CGSizeMake(size, size)
        self.tileSize = CGSizeMake(size-1, size-1)
        let xOffset:CGFloat = size/2 + 20
        let yOffset:CGFloat = screenSize.height - (viewController.navigationController?.navigationBar.frame.size.height)! - (CGFloat(gridSize)*size)
        
        for row in 0...gridSize-1 {
            for col in 0...gridSize-1 {
                // Background squares
                var color = SKColor.blackColor()
                let background = SKSpriteNode(color: color, size: squareSize)
                background.position = CGPointMake(CGFloat(col) * squareSize.width + xOffset,
                                                  CGFloat(row) * squareSize.height + yOffset)
                self.gameLayer.addChild(background)
                
                //Tile
                if(row == 0 && col == gridSize-1){
                    color = SKColor.blackColor()
                }
                else if(row == 0 || col == gridSize-1){
                    color = SKColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
                }
                else{
                    color = SKColor.whiteColor()
                }
                let square = SKSpriteNode(color: color, size: self.tileSize)
                square.position = CGPointMake(CGFloat(col) * squareSize.width + xOffset + 0.5,
                                              CGFloat(row) * squareSize.height + yOffset - 0.5)
                square.name = "(\(gridSize-row),\(col+1))"
                self.tileLayer.addChild(square)
                
                let gridRow = gridSize - row - 1
                if(row == 0 && col == gridSize-1){
                    continue
                }
                else if(row == 0 || col == gridSize-1){
                    let gamePiece = SKLabelNode(text: "\(grid[gridRow][col])")
                    gamePiece.fontSize = fontSize
                    gamePiece.fontColor = SKColor.whiteColor()
                    gamePiece.fontName = "Helvetica"
                    gamePiece.horizontalAlignmentMode = .Center
                    gamePiece.verticalAlignmentMode = .Center
                    if(grid[gridRow][col] == 0){
                        square.color = viewController.greenHeader
                    }
                    square.addChild(gamePiece)
                }
                else if(grid[gridRow][col] == 1){
                    let gamePiece = SKSpriteNode(imageNamed: "tree")
                    gamePiece.size = self.tileSize
                    square.color = treeColor
                    square.addChild(gamePiece)
                }
            }
        }
    }
    
    func addGamePiece(tile: String, spriteName: String, color: SKColor){
        if let square = squareWithName(tile) {
            let gamePiece = SKSpriteNode(imageNamed: spriteName)
            gamePiece.size = self.tileSize
            gamePiece.name = square.name
            square.removeAllChildren()
            square.color = color
            square.addChild(gamePiece)
        }
    }
    
    func removeGamePiece(tile: String){
        if let square = squareWithName(tile){
            square.removeAllChildren()
            square.color = SKColor.whiteColor()
        }
    }
    
    func changeTileColor(name: String, color: SKColor){
        if let square = squareWithName(name) {
            square.color = color
        }
    }
    
    func squareWithName(name:String) -> SKSpriteNode? {
        for child in tileLayer.children{
            if(child.name == name){
                return child as? SKSpriteNode
            }
        }
        return nil
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //viewController.changeTime()
    }
}
