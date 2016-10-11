import SpriteKit
import GameplayKit

class GameActiveState: GKState {

  unowned let gameScene: GameScene
  
  private var currentLevelNum: Int!
  
  init(gameScene: GameScene) {
    self.gameScene = gameScene
    super.init()

    gameScene.swipeHandler = handleSwipe
    
    beginGame()
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
      case is GamePauseState.Type, is GameFailureState.Type, is GameSuccessState.Type:
        return true
      default:
        return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    if previousState is GameSuccessState {
        let curlevel = self.gameScene.level.currentLevel()
        restartLevel((curlevel < NumLevels) ? curlevel+1 : 1)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if gameScene.isPaused {
        return
    }
    
  }
  
  private func restartLevel(_ levelNum: Int) {
    setupLevel(levelNum)
    gameScene.updateLabels()
    
  }
    
    private func setupLevel(_ levelNum: Int){
        
        // Start the game.
        gameScene.level = Level(level: levelNum)
        
        gameScene.addTiles()
        gameScene.swipeHandler = handleSwipe
    
        beginGame()
        
    }
    
    func beginGame(){
        gameScene.movesLeft = gameScene.level.maximumMoves
        gameScene.score = 0
        gameScene.updateLabels()
        gameScene.level.resetComboMultiplier()
        gameScene.animateBeginGame() {
            
        }
        gameScene.shuffle()
    }
    
    func beginNextTurn() {
        gameScene.level.resetComboMultiplier()
        gameScene.level.detectPossibleSwaps()
        gameScene.decrementMoves()
        gameScene.view?.isUserInteractionEnabled = true
        
        if gameScene.score >= gameScene.level.targetScore {
            // gameSceneDelegate?.showGameOver(imageName: "LevelComplete")
            stateMachine?.enter(GameSuccessState.self)
        } else if gameScene.movesLeft == 0 {
            // gameSceneDelegate?.showGameOver(imageName: "GameOver")
            stateMachine?.enter(GameFailureState.self)
        }
    }
    
    func handleMatches() {
        let chains = gameScene.level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        gameScene.animateMatchedCookies(chains) {
            for chain in chains {
                self.gameScene.score += chain.score
            }
            self.gameScene.updateLabels()
            let columns = self.gameScene.level.fillHoles()
            self.gameScene.animateFallingCookies(columns) {
                let columns = self.gameScene.level.topUpCookies()
                self.gameScene.animateNewCookies(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func handleSwipe(_ swap: Swap) {
        gameScene.view?.isUserInteractionEnabled = false
        
        if gameScene.level.isPossibleSwap(swap) {
            gameScene.level.performSwap(swap)
            gameScene.animateSwap(swap, completion: handleMatches)
            self.gameScene.view?.isUserInteractionEnabled = true
        }else {
            gameScene.animateInvalidSwap(swap) {
                self.gameScene.view?.isUserInteractionEnabled = true
            }
        }
    }
  
}
