//
//  Level.swift
//  Campsites
//
//  Created by Ryan Kreiter on 4/21/16.
//  Copyright © 2016 Ryan Kreiter. All rights reserved.
//

import UIKit

struct Stack<Element> {
    var items = [Element]()
    mutating func push(item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element? {
        return items.popLast()
    }
    mutating func size() -> Int {
        return items.count
    }
}

class Level {
    
    var grid = [[Int]]()
    var fullGrid = [[Int]]()
    var moves = Stack<(col: Int, row: Int, prev: Int)>()
    var gridSize: Int
    var tentsRemaining: Int = -1
    var tilesFilled: Int = 0
    
    init(levelName: String, size: Int){
        gridSize = size
        
        // Read in levelName json file
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(levelName) {
            
            // The dictionary contains an array named "tiles". This array contains
            // one element for each row of the level. Each of those row elements in
            // turn is also an array describing the columns in that row. If a column
            // is 1, it means there is a tile at that location, 0 means there is not.
            if let obj: AnyObject = dictionary["\(gridSize-1)x\(gridSize-1)"] {
                self.grid = obj["grid"] as! [[Int]]
                self.fullGrid = obj["fullGrid"] as! [[Int]]
                self.tentsRemaining = obj["numTrees"] as! Int
            }
        }
        
        assert(grid.count != 0)
        assert(tentsRemaining != -1)
    }
    
    // Add object (2=tent, 3=sand) to grid location
    // Return true for green background, false for red
    func addObject(col: Int, row: Int, obj: Int) -> Bool {
        assert(obj == 2 || obj == 3)
        assert(grid[row][col] != 1)
        
        // Location was empty
        if(grid[row][col] == 0){
            tilesFilled += 1
        }
        
        // Removing tent
        if(grid[row][col] == 2){
            tentsRemaining += 1
        }
        
        moves.push((col: col, row: row, prev: grid[row][col]))
        grid[row][col] = obj
        
        if(obj == 2){
            tentsRemaining -= 1
            return checkTent(col, row: row)
        }
        return true
    }
    
    // Remove object at grid location
    func removeObject(col: Int, row: Int) {
        // Removing tent
        if(grid[row][col] == 2){
            tentsRemaining += 1
        }
        
        // Can't remove trees
        if(grid[row][col] != 1){
            tilesFilled -= 1
            moves.push((col: col, row: row, prev: grid[row][col]))
            grid[row][col] = 0
        }
    }
    
    // Undo last move
    func undoMove() -> (col: Int, row: Int, prev: Int)? {
        if let move = moves.pop() {
            // Removing tent
            if(grid[move.row][move.col] == 2){
                tentsRemaining += 1
            }
            // Adding tent
            if(move.prev == 2){
                tentsRemaining -= 1
            }
            // Adding empty
            if(move.prev == 0){
                tilesFilled -= 1
            }
            // Removing empty
            if(grid[move.row][move.col] == 0){
                tilesFilled += 1
            }
            
            grid[move.row][move.col] = move.prev
            return move
        }
        return nil
    }
    
    // Checks tents placement to see if its valid
    func checkTent(col: Int, row: Int) -> Bool {
        var nextToTree = false
        
        // Orthogonal Checks
        if(col+1 < gridSize-1){
            if(grid[row][col+1] == 1){
                nextToTree = true
            }
            else if(grid[row][col+1] == 2){
                return false
            }
        }
        if(col-1 >= 0){
            if(grid[row][col-1] == 1){
                nextToTree = true
            }
            else if(grid[row][col-1] == 2){
                return false
            }
        }
        if(row+1 < gridSize-1){
            if(grid[row+1][col] == 1){
                nextToTree = true
            }
            else if(grid[row+1][col] == 2){
                return false
            }
        }
        if(row-1 >= 0){
            if(grid[row-1][col] == 1){
                nextToTree = true
            }
            else if(grid[row-1][col] == 2){
                return false
            }
        }
        
        // Diagonal Checks
        if(row+1 < gridSize-1 && col+1 < gridSize-1){
            if(grid[row+1][col+1] == 2){
                return false
            }
        }
        if(row+1 < gridSize-1 && col-1 >= 0){
            if(grid[row+1][col-1] == 2){
                return false
            }
        }
        if(row-1 >= 0 && col+1 < gridSize-1){
            if(grid[row-1][col+1] == 2){
                return false
            }
        }
        if(row-1 >= 0 && col-1 >= 0){
            if(grid[row-1][col-1] == 2){
                return false
            }
        }
        
        return nextToTree
    }
    
    // Check to see if number of tents in row is correct
    // Return 0 for yes, < 0 for too many, > 0 for not enough
    func checkRow(row: Int) -> Int {
        var count = 0
        for col in 0..<gridSize-1 {
            if(grid[row][col] == 2){
                count += 1
            }
        }
        return grid[row][gridSize-1] - count
    }
    
    // Check to see if number of tents in col is correct
    // Return 0 for yes, < 0 for too many, > 0 for not enough
    func checkCol(col: Int) -> Int {
        var count = 0
        for row in 0..<gridSize-1 {
            if(grid[row][col] == 2){
                count += 1
            }
        }
        return grid[gridSize-1][col] - count
    }
    
    // Checks to see if the puzzle is solved
    func solved() -> Bool {
        for i in 0..<gridSize-1 {
            if(checkRow(i) != 0 || checkCol(i) != 0){
                return false
            }
        }
        return true
    }
}