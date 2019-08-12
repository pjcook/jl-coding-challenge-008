//
//  ViewController.swift
//  Challenge8
//
//  Created by PJ COOK on 05/07/2019.
//  Copyright © 2019 Software101. All rights reserved.
//

import UIKit
import Shopopoly

class ViewController: UIViewController {
    private enum State {
        case waitingForGame
        case playingGame
        case gameOver
    }
    
    @IBOutlet private var stateLabel: UILabel!
    
    private var players: [Player] = []
    private var game: GameLedger?
    private var state: State = .waitingForGame

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
    }
}

// MARK: - General functions
extension ViewController {
    private func alert(_ error: Error) {
        let alert = UIAlertController(title: "Error".localize(), message: error.localizedDescription, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK".localize(), style: .default) { _ in
            self.refreshUI()
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayMoveResult(dice: [Int], location: Location, hasPassedGO: Bool) {
        guard let game = game else { return }
        let playerData = game.currentPlayerData
        do {
            let actions = try game.actions(for: location, player: playerData.player)
            
            var message = "Rolled: [\(dice[0])][\(dice[1])]\n"
            message += "Available funds: \(playerData.money)\n"
            message += "Landed at: \(location.name)\n"
            
            let alert = UIAlertController(title: "\(playerData.player.name) actions".localize(), message: message, preferredStyle: .actionSheet)
            
            for action in actions {
                if case .none = action {
                    continue
                } else if case .canPurchase = action {
                    let alertAction = UIAlertAction(title: "Purchase location".localize()
                    , style: .default) { _ in
                        self.purchase(location)
                    }
                    alert.addAction(alertAction)
                } else if case .canUpgrade = action {
                    let alertAction = UIAlertAction(title: "Buy upgrade".localize()
                    , style: .default) { _ in
                        self.upgrade(location)
                    }
                    alert.addAction(alertAction)
                }
            }
            
            let endTurnAction = UIAlertAction(title: "End Turn".localize()
            , style: .cancel) { _ in
                self.endTurn()
            }
            alert.addAction(endTurnAction)
            
            present(alert, animated: true, completion: nil)
        } catch let error {
            alert(error)
            refreshUI()
        }
    }
    
    private func refreshUI() {
        switch state {
        case .waitingForGame:
            displayWaitingForGameState()
        case .playingGame:
            displayPlayingGameState()
        case .gameOver:
            displayGameOverState()
        }
    }
    
    private func displayCreatePlayerDialogue() {
        guard state == .waitingForGame else { return }
        
        let alert = UIAlertController(title: "Create player".localize(), message: "Enter player name:".localize(), preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "player name".localize()
            textField.accessibilityIdentifier = "player name".localize()
        }
        
        let createAction = UIAlertAction(title: "Create".localize(), style: .default) { _ in
            let identifier = "player name".localize()
            let name = alert.textFields?.first(where: { return $0.accessibilityIdentifier == identifier })?.text ?? ""
            self.createPlayer(name: name)
        }
        alert.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayWaitingForGameState() {
        stateLabel.text = "Waiting to start game".localize()
        
        let alert = UIAlertController(title: "Actions".localize(), message: "Select required action:".localize(), preferredStyle: .actionSheet)
        
        let createPlayerAction = UIAlertAction(title: "Create player".localize()
        , style: .default) { _ in
            self.displayCreatePlayerDialogue()
        }
        alert.addAction(createPlayerAction)
        
        if players.count > 0 {
            let removePlayerAction = UIAlertAction(title: "Remove last player".localize()
            , style: .default) { _ in
                if let player =  self.players.last {
                    self.removePlayer(player: player)
                }
            }
            alert.addAction(removePlayerAction)
        }
        
        if players.count > 1 {
            let startGameAction = UIAlertAction(title: "Start Game".localize()
            , style: .cancel) { _ in
                self.startNewGame()
            }
            alert.addAction(startGameAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayPlayingGameState() {
        guard let game = game else { return }
        stateLabel.text = "Playing game".localize()
        
        let playerData = game.currentPlayerData
        let alert = UIAlertController(title: "\(playerData.player.name) actions".localize(), message: "Select required action:".localize(), preferredStyle: .actionSheet)
        
        if !game.currentPlayerMoved {
            let action = UIAlertAction(title: "Roll Die".localize()
            , style: .cancel) { _ in
                self.nextTurn()
            }
            alert.addAction(action)
        } else {
            let action = UIAlertAction(title: "End Turn".localize()
            , style: .cancel) { _ in
                self.endTurn()
            }
            alert.addAction(action)
        }
        
        let action = UIAlertAction(title: "Quit Game".localize()
        , style: .destructive) { _ in
            self.cancelGame()
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayGameOverState() {
        stateLabel.text = "Game Over!".localize()
        
        let alert = UIAlertController(title: "Actions".localize(), message: "Select required action:".localize(), preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "Quit Game".localize()
        , style: .cancel) { _ in
            self.cancelGame()
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Game functions
extension ViewController {
    private func startNewGame() {
        guard state == .waitingForGame else { return }
        game = GameLedger(players: players, locations: Monopoly.locations, dice: Monopoly.dice)
        do {
            try game?.startGame(value: Monopoly.startingCapital)
            state = .playingGame
        } catch let error {
            alert(error)
        }
        refreshUI()
    }

    private func cancelGame() {
        guard state == .playingGame else { return }
        game = nil
        state = .waitingForGame
        refreshUI()
    }
    
    private func nextTurn() {
        guard state == .playingGame else { return }
        guard var game = game else { return }
        do {
            let (dice, location, hasPassedGO) = try game.moveCurrentPlayer()
            displayMoveResult(dice: dice, location: location, hasPassedGO: hasPassedGO)
        } catch let error {
            alert(error)
        }
        self.game = game
        refreshUI()
    }
    
    private func purchase(_ location: Location) {
        guard var game = game else { return }
        let playerData = game.currentPlayerData
        do {
            try game.purchase(player: playerData.player, location: location)
        } catch let error {
            alert(error)
        }
        self.game = game
        refreshUI()
    }
    
    private func upgrade(_ location: Location) {
        guard var game = game else { return }
        let playerData = game.currentPlayerData
        do {
            try game.upgrade(player: playerData.player, location: location)
        } catch let error {
            alert(error)
        }
        self.game = game
        refreshUI()
    }
    
    private func endTurn() {
        guard state == .playingGame else { return }
        game?.endTurn()
        refreshUI()
    }
}

// MARK: - Setup game functions
extension ViewController {
    private func createPlayer(name: String) {
        guard state == .waitingForGame else { return }
        do {
            let player = try Player(name: name)
            players.append(player)
        } catch let error {
            alert(error)
        }
        refreshUI()
    }
    
    private func removePlayer(player: Player) {
        guard state == .waitingForGame else { return }
        players.removeAll(where: { $0 == player })
        self.refreshUI()
    }
}
