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
        let randomCoords = findOpenCell()
        let x = randomCoords.0
        let y = randomCoords.1
        cells[x][y].value = randomNumber
    }
    
    func findOpenCell() -> (Int, Int) {
        var openCells = [(Int, Int)]()
        for x in 0..<rows {
            for y in 0..<cols{
                if cells[x][y].value == nil {
                    openCells.append((x, y))
                }
            }
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

//handles movement functions
extension Grid {
    mutating func up () {
        for x in 1..<rows {
            for y in 0..<cols {
                if let lowerValue = cells[x][y].value,
                    let upperValue = cells[x-1][y].value {
                    if lowerValue == upperValue {
                        cells[x-1][y].value = upperValue * 2
                        cells[x][y].value = nil
                        for X in (x+1)..<rows {
                            if (X != 3) {
                                if let movingValue = cells[X][y].value {
                                    cells[X-1][y].value = movingValue
                                    cells[X][y].value = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
