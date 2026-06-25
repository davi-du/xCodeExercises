//
//  ViewController.swift
//  TicTacToe
//
//  Created by Davide Cidu on 25/06/2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var vGameBoard: UIView!
    @IBOutlet weak var vNewPiece: UIView!
    
    var xTurn = false
    var xMoves = Set<Int>()
    var oMoves = Set<Int>()
    var isMakingMove = false
    var newPiece :UIImageView?
    
    var boardPositions = [UIView]()
    var winningMoves : Set<Set<Int>> = [
        [0,1,2],[3,4,5],[6,7,8],
        [0,3,6],[1,4,7],[2,5,8],
        [0,4,8],[2,4,6]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        boardPositions = vGameBoard.subviews
        nextTurn()
        lblMsg.text = "X starts"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: view)
        isMakingMove = vNewPiece.frame.contains(point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newPiece = newPiece else { return }
        guard isMakingMove else { return }
        newPiece.center = touches.first!.location(in: view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newPiece = newPiece else { return }
        let lastTouch = touches.first!.location(in: self.vGameBoard)
        guard let position = boardPositions.first(where: {
            $0.frame.contains(lastTouch)
        }) else { return }
        
        let positionPlacement = position.tag
        guard xMoves.firstIndex(of: positionPlacement) == nil,
              oMoves.firstIndex(of: positionPlacement) == nil else { return }
        newPiece.frame = position.frame
        vGameBoard.addSubview(newPiece)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7) {
            let trans = CGAffineTransform(rotationAngle: 3.14)
            newPiece.transform = trans
        }
        
        if xTurn {
            xMoves.insert(positionPlacement)
        } else {
            oMoves.insert(positionPlacement)
        }
        
        nextTurn()
    }
    
    func nextTurn() {
        let curPlayerMoves = xTurn ? xMoves : oMoves
        let isWin = winningMoves.contains(where: { curPlayerMoves.isSuperset(of: $0) })

        if isWin {
            lblMsg.text = "Player \(xTurn ? "X" : "O") ha vinto! 🎉"
            newPiece?.removeFromSuperview()
            newPiece = nil
            return
        }

        xTurn.toggle()
        lblMsg.text = "Turno del giocatore \(xTurn ? "X" : "O")"

        newPiece = UIImageView(frame: vNewPiece.frame)
        view.addSubview(newPiece!)
        newPiece?.image = UIImage(systemName: "\(xTurn ? "x" : "o").circle.fill")
        newPiece?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7) {
            self.newPiece?.transform = .identity
        }
    }
}

