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
    var nodeName: String = ""

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
            nodeName = self.nodeAtPoint(touch.locationInNode(self)).name!
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if touch.tapCount == 1 {
                print("Touched \(nodeName)")
            } else if touch.tapCount == 2 {
                print("Double touched \(nodeName)")
            }
        }
        nodeName = ""
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        nodeName = ""
    }
    
    func drawBoard(gridSize: Int) {
        // Board parameters
        let screenSize = self.frame.size
        let size = (screenSize.width-40)/CGFloat(gridSize)
        let squareSize = CGSizeMake(size, size)
        let xOffset:CGFloat = size/2 + 20
        let yOffset:CGFloat = self.frame.size.height - (viewController.navigationController?.navigationBar.frame.size.height)! - (CGFloat(gridSize)*squareSize.height)

        for row in 0...gridSize-1 {
            for col in 0...gridSize-1 {
                // Determine the color of square
                var color = SKColor.blackColor()
                let square = SKSpriteNode(color: color, size: squareSize)
                square.position = CGPointMake(CGFloat(col) * squareSize.width + xOffset,
                                              CGFloat(row) * squareSize.height + yOffset)
                // Set sprite's name (e.g., (1,8), (3,5), (4,1))
                square.name = "(\(col),\(11-row))"
                self.gameLayer.addChild(square)
                
                //Inner square
                if(row == 0 && col == gridSize-1){
                    color = SKColor.blackColor()
                }
                else if(row == 0 || col == gridSize-1){
                    color = SKColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
                }
                else{
                    color = SKColor.whiteColor()
                }
                let inSize = CGSizeMake(squareSize.width-1, squareSize.height-1)
                let inSquare = SKSpriteNode(color: color, size: inSize)
                inSquare.position = CGPointMake(CGFloat(col) * squareSize.width + xOffset + 0.5,
                                                CGFloat(row) * squareSize.height + yOffset - 0.5)
                inSquare.name = "(\(col+1),\(11-row))"
                self.tileLayer.addChild(inSquare)
            }
        }
        
        // Add a game piece to the board
        if let square = squareWithName("(2,7)") {
            let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
            gamePiece.size = CGSizeMake(24, 24)
            square.addChild(gamePiece)
        }
        if let square = squareWithName("(5,3)") {
            let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
            gamePiece.size = CGSizeMake(24, 24)
            square.addChild(gamePiece)
        }
    }
    
    func squareWithName(name:String) -> SKSpriteNode? {
        let square:SKSpriteNode? = tileLayer.childNodeWithName(name) as! SKSpriteNode?
        return square
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
