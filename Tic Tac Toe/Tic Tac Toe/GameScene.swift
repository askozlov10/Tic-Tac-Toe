//
//  GameScene.swift
//  Tic Tac Toe
//
//  Created by User on 02/06/2020.
//  Copyright © 2020 askoz. All rights reserved.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var label = SKLabelNode()
    var outerRectangle = SKShapeNode()
    var gameLabel = SKLabelNode()
    
    // node collections
    var elements = [SKSpriteNode]()
    var fields: [[SKShapeNode]] = Array(repeating: Array(repeating: SKShapeNode(), count: 3), count: 3)
    
    // helper variables
    var fieldSize: CGSize = CGSize()
    var positions: [[CGPoint]] = Array(repeating: Array(repeating: CGPoint(), count: 3), count: 3)
    
    // game logic
    var board = Board()
    var player = Player(name: "")
    var cpu = Player(name: "")
    var playerToMove = false
    var cpuThinking = false
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    func setupScene() {
        self.removeAllChildren()
        
        let title = SKLabelNode(text: "Tic Tac Toe")
        title.position = CGPoint(x: 7.5, y: Double(0.375 * self.size.height - 5.0))
        title.fontSize = 80
        title.zPosition = CGFloat(10)
        title.fontName = "Futura-CondensedMedium"
        self.addChild(title)
        
        gameLabel = SKLabelNode(text: "")
        gameLabel.position = CGPoint(x: 0, y: 0.275 * self.size.height)
        gameLabel.fontSize = 40
        gameLabel.fontName = "Futura-CondensedMedium"
        gameLabel.fontColor = UIColor.lightGray
        self.addChild(gameLabel)
        
        label = SKLabelNode(text: "Start New Game")
        label.position = CGPoint(x: 0, y: -0.4 * self.size.height)
        label.fontColor = UIColor.black
        label.fontSize = 70
        label.zPosition = 10
        label.fontName = "Futura-CondensedMedium"
        self.addChild(label)
        
        
        outerRectangle = SKShapeNode(rect: CGRect(x: -0.45 * self.size.width, y: -0.45 * self.size.width, width: 0.9 * self.size.width, height: 0.9 * self.size.width))
        outerRectangle.fillColor = UIColor.white
        self.addChild(outerRectangle)
        
        
        fieldSize = CGSize(width: CGFloat(0.25) * self.size.width, height: CGFloat(0.25) * self.size.width)
        
        for i in 0...2 {
            for j in 0...2 {
                let x = (-0.3 + Double(j) * 0.3) * Double(self.size.width)
                let y = (0.3 - Double(i) * 0.3) * Double(self.size.width)
                positions[i][j] = CGPoint(x: x - 0.5 * Double(fieldSize.width), y: y - 0.5 * Double(fieldSize.height))
                fields[i][j] = SKShapeNode(rect: CGRect(origin: positions[i][j], size: fieldSize))
                positions[i][j] = CGPoint(x: x, y: y)
                fields[i][j].fillColor = UIColor.clear
                fields[i][j].strokeColor = UIColor.clear
                self.outerRectangle.addChild(fields[i][j])
            }
        }
        
        // separation lines
        let lineOffset = 0.025 * Double(self.size.width)
        let lineSize = CGSize(width: 5.0, height: 0.9 * self.size.width - 2.0 * CGFloat(lineOffset))
        // loop to create all 4 lines
        for i in 0...1 {
            // vertical lines
            var x = (-0.15 + 0.3 * Double(i)) * Double(self.size.width)
            var y = (-0.45) * Double(self.size.width)
            var linePoint = CGPoint(x: x - 0.5 * Double(lineSize.width), y: y + lineOffset)
            var lineRect = CGRect(origin: linePoint, size: lineSize)
            var line = SKShapeNode(rect: lineRect, cornerRadius: 5.0)
            line.fillColor = UIColor.black
            line.strokeColor = UIColor.black
            self.outerRectangle.addChild(line)
            // horizontal lines
            let flippedLineSize = CGSize(width: lineSize.height, height: lineSize.width)
            x = (-0.45) * Double(self.size.width)
            y = (-0.15 + 0.3 * Double(i)) * Double(self.size.width)
            linePoint = CGPoint(x: x + lineOffset, y: y - 0.5 * Double(flippedLineSize.height))
            lineRect = CGRect(origin: linePoint, size: flippedLineSize)
            line = SKShapeNode(rect: lineRect, cornerRadius: 5.0)
            line.fillColor = UIColor.black
            line.strokeColor = UIColor.black
            self.outerRectangle.addChild(line)
        }
    }
    
    // ***********************
    // **** Game behavior ****
    // ***********************
    
    func startGame() {
        // set up game logic
        board = Board()
        player = HumanPlayer(name: "human")
        cpu = RandomPlayer(name: "random")
        playerToMove = true
    }
    
    func checkGame() {
        
        if self.board.isOver() {
            gameOver()
        } else if !playerToMove {
            cpuMove()
        }
    }
    
    func gameOver() {
        
        let result = self.board.getResult()
        if result == .draw {
            gameLabel.text = "Draw"
        } else if result == .opponentWon {
            gameLabel.text = "You've lost :c"
        } else if result == .playerWon {
            gameLabel.text = "Congratulations, you won!"
        } else {
          print("Something went wrong")
        }
        playerToMove = false
    }
    
    func cleanupGame() {
        for e in self.elements {
            e.removeFromParent()
        }
        self.elements.removeAll()
        gameLabel.text = ""
    }
    
    func cpuMove() {
        let (row, col) = self.cpu.getMove(board: self.board)
        self.board.makeMove(row: row, col: col)
        self.makeCircle(row: row, col: col)
        playerToMove = true
        checkGame()
    }
    
    //Game Appearance
    func makeCircle(row: Int, col: Int) {
        let circleTexture = SKTexture(image: #imageLiteral(resourceName: "circle"))
        let circle = SKSpriteNode(texture: circleTexture)
        circle.position = positions[row][col]
        circle.size.width = self.fieldSize.width * 0.8
        circle.size.height = self.fieldSize.height * 0.8
        self.elements.append(circle)
        self.outerRectangle.addChild(circle)
    }
    
    func makeCross(row: Int, col: Int) {
        let crossTexture = SKTexture(image: #imageLiteral(resourceName: "cross"))
        let cross = SKSpriteNode(texture: crossTexture)
        cross.position = positions[row][col]
        cross.size.width = self.fieldSize.width * 0.8
        cross.size.height = self.fieldSize.height * 0.8
        self.elements.append(cross)
        self.outerRectangle.addChild(cross)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let touchedNodes = nodes(at: t.location(in: self))
            if touchedNodes.contains(label) {
                if label.text == "Start New Game" {
                    label.text = "Clear Table"
                    startGame()
                } else if label.text == "Clear Table" {
                    label.text = "Start New Game"
                    cleanupGame()
                }
            }
            if touchedNodes.contains(gameLabel) {
                self.gameLabel.text = ""
            }
            for i in 0...2 {
                for j in 0...2 {
                    if touchedNodes.contains(fields[i][j]) {
                        if playerToMove {
                            if self.board.getField(row: i, col: j) == 0 {
                                self.board.makeMove(row: i, col: j)
                                makeCross(row: i, col: j)
                                playerToMove = false
                                checkGame()
                            }
                        }
                    }
                }
            }
        }
    }
}
