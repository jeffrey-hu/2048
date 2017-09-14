//
//  Grid.swift
//  2048
//
//  Created by Jeffrey Hu on 8/3/17.
//  Copyright © 2017 Jeffrey Hu. All rights reserved.
//

import Foundation

typealias GridPosition = (row: Int, col: Int)
typealias CellValue = Int

var gridHasChanged = false

protocol GridProtocol {
    var rows : Int {get set}
    var cols : Int {get set}
    var cells : [[Cell]] {get set}
    subscript (row: Int, col: Int) -> Int? { get set }
}

protocol CellProtocol {
    var value : CellValue? {get set}
}

struct Cell : CellProtocol {
    var value : CellValue?
}

struct Grid : GridProtocol {
    var rows : Int
    var cols : Int
    var cells : [[Cell]]
    
    subscript (row: Int, col: Int) -> Int? {
        get {
            if let value = cells[row][col].value {
                return value
            } else {
                return nil
            }
        }
        set { cells[row][col].value = newValue }
    }
    
    mutating func generateRandom() {
        let Rndm = arc4random_uniform(10) == 1
        let randomNumber = Rndm ? 4 : 2
        if let randomCoords = findOpenCell(){
            let x = randomCoords.0
            let y = randomCoords.1
            cells[x][y].value = randomNumber
            updateCellTitles()
        }
    }
    
    func findOpenCell() -> (Int, Int)? {
        var openCells = [(Int, Int)]()
        for x in 0..<rows {
            for y in 0..<cols{
                if cells[x][y].value == nil {
                    openCells.append((x, y))
                }
            }
        }
        if openCells.count == 0 {
            return nil
        }
        let returnCoords = openCells[Int(arc4random_uniform(UInt32(openCells.count)))]
        return returnCoords
    }
    
    public init(_ rows: Int, _ cols: Int) {
        self.rows = rows
        self.cols = cols
        cells = [[Cell]](repeating: [Cell](repeating: Cell(), count: cols), count: rows)
    }
    
}

extension Grid {
    mutating func goUp () {
    }
}

//handles movement functions
extension Grid {
    mutating func up () {
        for x in stride(from: 1, to: rows, by : 1) {
            for y in 0..<cols {
                if cells[x][y].value != nil {
                    if let nextOccupiedCell = findNextOccupiedCellUp(x, y) {
                        if cells[x][y].value == cells[nextOccupiedCell.0][nextOccupiedCell.1].value {
                            cells[nextOccupiedCell.0][nextOccupiedCell.1].value = cells[x][y].value! * 2
                            cells[x][y].value = nil
                            gridHasChanged = true
                        } else {
                            if let farthestAvailableCell = findFarthestAvailableCellUp(x, y,
                                                            from: nextOccupiedCell.0) {
                                cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                                cells[x][y].value = nil
                                gridHasChanged = true
                            }
                        }
                    } else {
                        if let farthestAvailableCell = findFarthestAvailableCellUp(x, y, from: 0) {
                            cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                            cells[x][y].value = nil
                            gridHasChanged = true
                        }
                    }
                }
            }
        }
        if (gridHasChanged) {
            generateRandom()
        }
        updateCellTitles()
        gridHasChanged = false
    }
    
    func findFarthestAvailableCellUp(_ x : Int, _ y : Int, from startX : Int) -> (Int, Int)? {
        var possibleX = startX
        while possibleX < x {
            if cells[possibleX][y].value == nil {
                return (possibleX, y)
            } else {
                possibleX = possibleX + 1
            }
        }
        return nil
    }
    
    func findNextOccupiedCellUp(_ x : Int, _ y : Int) -> (Int, Int)? {
        var x = x - 1
        while x>=0 {
            if cells[x][y].value != nil {
                return (x, y)
            } else {
                x = x - 1
            }
        }
        return nil
    }
    
    mutating func down () {
        for x in stride(from: 2, to: -1, by: -1) {
            print(x)
            for y in 0..<cols {
                if cells[x][y].value != nil {
                    if let nextOccupiedCell = findNextOccupiedCellDown(x, y) {
                        if cells[x][y].value == cells[nextOccupiedCell.0][nextOccupiedCell.1].value {
                            cells[nextOccupiedCell.0][nextOccupiedCell.1].value = cells[x][y].value! * 2
                            cells[x][y].value = nil
                            gridHasChanged = true
                        } else {
                            if let farthestAvailableCell = findFarthestAvailableCellDown(x, y,
                                                                                     from: nextOccupiedCell.0) {
                                cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                                cells[x][y].value = nil
                                gridHasChanged = true
                            }
                        }
                    } else {
                        if let farthestAvailableCell = findFarthestAvailableCellDown(x, y, from: 3) {
                            cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                            cells[x][y].value = nil
                            gridHasChanged = true
                        }
                    }
                }
            }
        }
        if (gridHasChanged){
            generateRandom()
        }
        updateCellTitles()
        gridHasChanged = false
    }
    
    func findFarthestAvailableCellDown(_ x : Int, _ y : Int, from startX : Int) -> (Int, Int)? {
        var possibleX = startX
        while possibleX > x {
            if cells[possibleX][y].value == nil {
                return (possibleX, y)
            } else {
                possibleX = possibleX - 1
            }
        }
        return nil
    }
    
    func findNextOccupiedCellDown(_ x : Int, _ y : Int) -> (Int, Int)? {
        var x = x + 1
        while x<=3 {
            if cells[x][y].value != nil {
                return (x, y)
            } else {
                x = x + 1
            }
        }
        return nil
    }
    
    mutating func right () {
        for y in stride(from: 2, to: -1, by: -1) {
            for x in 0..<rows {
                if cells[x][y].value != nil {
                    if let nextOccupiedCell = findNextOccupiedCellRight(x, y) {
                        if cells[x][y].value == cells[nextOccupiedCell.0][nextOccupiedCell.1].value {
                            cells[nextOccupiedCell.0][nextOccupiedCell.1].value = cells[x][y].value! * 2
                            cells[x][y].value = nil
                            gridHasChanged = true
                        } else {
                            if let farthestAvailableCell = findFarthestAvailableCellRight(x, y,
                                                                                         from: nextOccupiedCell.1) {
                                cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                                cells[x][y].value = nil
                                gridHasChanged = true
                            }
                        }
                    } else {
                        if let farthestAvailableCell = findFarthestAvailableCellRight(x, y, from: 3) {
                            cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                            cells[x][y].value = nil
                            gridHasChanged = true
                        }
                    }
                }
            }
        }
        if (gridHasChanged){
            generateRandom()
        }
        updateCellTitles()
        gridHasChanged = false
    }
    
    func findFarthestAvailableCellRight(_ x : Int, _ y : Int, from startY : Int) -> (Int, Int)? {
        var possibleY = startY
        while possibleY > y {
            if cells[x][possibleY].value == nil {
                return (x, possibleY)
            } else {
                possibleY = possibleY - 1
            }
        }
        return nil
    }
    
    func findNextOccupiedCellRight(_ x : Int, _ y : Int) -> (Int, Int)? {
        var y = y + 1
        while y<=3 {
            if cells[x][y].value != nil {
                return (x, y)
            } else {
                y = y + 1
            }
        }
        return nil
    }
    
    mutating func left () {
        for y in stride(from: 0, to: cols, by: 1) {
            for x in 0..<rows {
                if cells[x][y].value != nil {
                    if let nextOccupiedCell = findNextOccupiedCellLeft(x, y) {
                        if cells[x][y].value == cells[nextOccupiedCell.0][nextOccupiedCell.1].value {
                            cells[nextOccupiedCell.0][nextOccupiedCell.1].value = cells[x][y].value! * 2
                            cells[x][y].value = nil
                            gridHasChanged = true
                        } else {
                            if let farthestAvailableCell = findFarthestAvailableCellLeft(x, y,
                                                                                          from: nextOccupiedCell.1) {
                                cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                                cells[x][y].value = nil
                                gridHasChanged = true
                            }
                        }
                    } else {
                        if let farthestAvailableCell = findFarthestAvailableCellLeft(x, y, from: 0) {
                            cells[farthestAvailableCell.0][farthestAvailableCell.1].value = cells[x][y].value
                            cells[x][y].value = nil
                            gridHasChanged = true
                        }
                    }
                }
            }
        }
        if (gridHasChanged){
            generateRandom()
        }
        updateCellTitles()
        gridHasChanged = false
    }
    
    func findFarthestAvailableCellLeft(_ x : Int, _ y : Int, from startY : Int) -> (Int, Int)? {
        var possibleY = startY
        while possibleY < y {
            if cells[x][possibleY].value == nil {
                return (x, possibleY)
            } else {
                possibleY = possibleY + 1
            }
        }
        return nil
    }
    
    func findNextOccupiedCellLeft(_ x : Int, _ y : Int) -> (Int, Int)? {
        var y = y - 1
        while y>=0 {
            if cells[x][y].value != nil {
                return (x, y)
            } else {
                y = y - 1
            }
        }
        return nil
    }
}

//sends notification
extension Grid {
    func updateCellTitles (){
        NotificationCenter.default.post(name: Names.cellValues,
                                        object: cells,
                                        userInfo: nil)
    }
}

struct Names {
    static let cellValues = NSNotification.Name("cellValueNotification")
}
