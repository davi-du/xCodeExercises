//
//  ViewController2.swift
//  TicTacToe
//
//  Created by Davide Cidu on 25/06/2026.
//

import UIKit

final class ViewController: UIViewController {
    //MARK - componenti
    private let mainStack = UIStackView()
    private let currentPieceContainer = UIView()
    private let currentPieceImageView = UIImageView()
    private let boardContainer = UIStackView()
    private var cells: [UIView] = []
    private let statusLabel = UILabel()
    
    //MARK - stato del gioco
    private enum Player{
        case x
        case o
    }
    
    private var currentPlayer: Player = .x
    
    private var xMoves = Set<Int>()
    private var oMoves = Set<Int>()
    
    var winningCombinations : [Set<Int>] = [
        [0,1,2],[3,4,5],[6,7,8],
        [0,3,6],[1,4,7],[2,5,8],
        [0,4,8],[2,4,6]
    ]
    
    
    //MARK - lifecycle dell'app
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        
        updateStatus(text: "X's turn")
        updateCurrentPieceUI()
    }
    
    //MARL - setup
    private func setupUI(){
        view.backgroundColor = .systemBackground
        
        //mainStack
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        //CurrentPieceContainer
        currentPieceContainer.translatesAutoresizingMaskIntoConstraints = false
        currentPieceContainer.backgroundColor = .secondarySystemBackground
        currentPieceImageView.translatesAutoresizingMaskIntoConstraints = false
        currentPieceImageView.contentMode = .scaleAspectFit
        
        currentPieceContainer.addSubview(currentPieceImageView)
        mainStack.addArrangedSubview(currentPieceContainer)
        
        //boradContainer
        boardContainer.axis = .vertical
        boardContainer.spacing = 8
        boardContainer.distribution = .fillEqually
        boardContainer.translatesAutoresizingMaskIntoConstraints = false
        
        //creazione tabella
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            
            for col in 0..<3 {
                let cell = UIView()
                cell.backgroundColor = .systemGray5
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.black.cgColor
                
                let index = row * 3 + col
                cell.tag = index
                
                //gesture per le celle
                cell.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCell(_:)))
                cell.addGestureRecognizer(tap)
                
                cells.append(cell)
                rowStack.addArrangedSubview(cell)
            }
            
            boardContainer.addArrangedSubview(rowStack)
        }
        
        mainStack.addArrangedSubview(boardContainer)
        
        //label
        statusLabel.text = "X starts"
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.numberOfLines = 0
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack.addArrangedSubview(statusLabel)
        
        //drag della pedina
        currentPieceImageView.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        currentPieceImageView.addGestureRecognizer(pan)
        
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            //mainStack
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  16),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant:  -16),
            
            //altezza pedina
            currentPieceContainer.heightAnchor.constraint(equalToConstant: 120),
            
            //centra la pedina
            currentPieceImageView.centerXAnchor.constraint(equalTo: currentPieceContainer.centerXAnchor),
            currentPieceImageView.centerYAnchor.constraint(equalTo: currentPieceContainer.centerYAnchor),
            
            //dimensione pedina
            currentPieceImageView.widthAnchor.constraint(equalToConstant: 60),
            currentPieceImageView.heightAnchor.constraint(equalTo: currentPieceImageView.widthAnchor),
            
            //board quadrata
            boardContainer.heightAnchor.constraint(equalTo: boardContainer.widthAnchor)
        ])
    }
    
    private func makeMove(index: Int){
        //controllo cella
        if xMoves.contains(index) || oMoves.contains(index){
            return
        }
        
        //aggiunge mossa al set del player corrente
        if currentPlayer == .x {
            xMoves.insert(index)
        } else {
            oMoves.insert(index)
        }
        
        //check per vittoria
        if checkWin(player: currentPlayer) {
            updateStatus(text: "\((currentPlayer == .x) ? "X" : "O") wins!")
            return
        }
        
        //se non ho vittorie cambia turno
        currentPlayer = (currentPlayer == .x) ? .o : .x
        updateStatus(text: "\(currentPlayer == .x ? "X" : "O") turn")
        
        //aggiorna il player
        updateCurrentPieceUI()
    }
    
    private func checkWin(player: Player) -> Bool {
        let moves = (player == .x) ? xMoves : oMoves
        return winningCombinations.contains{
            combo in
            moves.isSuperset(of: combo)
        }
    }
    
    private func updateStatus(text: String){
        statusLabel.text = text
    }
    
    @objc private func didTapCell(_ sender: UITapGestureRecognizer){
        guard let cell = sender.view else { return }
        let index = cell.tag
        makeMove(index: index)
        updateBoardUI()
    }
    
    private func updateBoardUI(){
        for cell in cells {
            cell.subviews.forEach{ $0.removeFromSuperview() }
            
            let index = cell.tag
            var symbolName: String?
            
            if xMoves.contains(index) {
                symbolName = "xmark"
            } else if oMoves.contains(index) {
                symbolName = "circle"
            }
            
            guard let symbol = symbolName else { continue }
            
            let imageView = UIImageView(image: UIImage(systemName: symbol))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            
            cell.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: 0.6),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            ])
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer){
        guard let piece = gesture.view else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
            
        case .began:
            let location = gesture.location(in: piece)
            piece.layer.setValue(CGPoint(x: location.x - piece.bounds.midX, y: location.y - piece.bounds.midY), forKey: "dragOffset")
            view.addSubview(piece)
            
        case .changed:
            //muove la pedina col dito
            let location = gesture.location(in: view)
            let offset = piece.layer.value(forKey: "dragOffset") as! CGPoint
            
             piece.center = CGPoint(
                 x: piece.center.x + translation.x,
                 y: piece.center.y + translation.y
             )
             //gesture.setTranslation(.zero, in: view)
            
        case .ended:
            //controllo se sta su una cella valida
            let location = gesture.location(in: view)
            
            guard let targetCell = cells.first(where: {
                let cellFrame = $0.superview!.convert($0.frame, to: view)
                return cellFrame.contains(location)
            }) else {
                resetCurrentPiecePosition() //se non è sopra correttamente la resetta
                return
            }
            
            let index = targetCell.tag
            //prova a posizionare
            if xMoves.contains(index) || oMoves.contains(index) {
                resetCurrentPiecePosition() //reset perchè occupata
                return
            }
            
            makeMove(index: index)
            updateBoardUI()
            
            let targetCenter = targetCell.superview!.convert(targetCell.center, to: view)
            
            UIView.animate(withDuration: 0.2){
                piece.center = targetCenter
            }
            //resetCurrentPiecePosition() //reset per turno successivo
        
        default:
            break
        }
    }
    
    private func resetCurrentPiecePosition(){
        UIView.animate(withDuration: 0.3){
            self.currentPieceImageView.center = self.currentPieceContainer.center
        }
    }
    
    private func updateCurrentPieceUI(){
        let symbol = (currentPlayer == .x) ? "xmark.circle.fill" : "circle.fill"
        currentPieceImageView.image = UIImage(systemName: symbol)
    }
}



/*
 #Preview {
     ViewController2()
 }
 */
