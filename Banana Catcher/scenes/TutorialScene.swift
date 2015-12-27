import SpriteKit

class TutorialScene: SKScene, SKPhysicsContactDelegate {
    
    private var hWidth: CGFloat = 0.0
    
    private let ground: Ground = Ground()
    private let basketMan: BasketMan = BasketMan()
    private let monkey: EvilMonkey = EvilMonkey()
    private let finger: SKSpriteNode = SKSpriteNode(imageNamed: "finger.png")
    private var infoLabel: InfoLabel?
    
    private var currentStage = 1
    private var stageAdvancable = false
    private var nextButton: SKSpriteNode = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        hWidth = size.width / 2
        
        musicPlayer.change("tutorial")

        adjustPhysics()
        addBackgroundImage()
        addGround()
        addDoodads()
        addBasketMan()
        addEvilMonkey()
        addDarkness()
        addTutorialLabel()
        addInfoLabel()
        addButtons()
        addFinger()
        
        playCurrentStage()
    }
        
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation)
        
        if(touchedNode.name == ButtonNodes.next && stageAdvancable) {
            currentStage += 1
            
            playSound(self, name: "option_select.wav")
            playCurrentStage()
        } else {
            print("name: \(touchedNode.name), adv?: \(stageAdvancable)")
        }
    }
    
    
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * Collision detection
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    func didBeginContact(contact: SKPhysicsContact) {
        CollissionDetector.run(
            contact: contact,
            onHitBasketMan: throwableHitsBasketMan,
            onHitGround: throwableHitsGround)
    }
    
    
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * Add game elements
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    private func adjustPhysics() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        self.physicsBody?.categoryBitMask = CollisionCategories.EdgeBody
    }
    
    private func addBackgroundImage() {
        let background = SKSpriteNode(imageNamed: "background.png")
        background.position = CGPointMake(CGRectGetMidX(frame), background.size.height / 2)
        background.zPosition = -999
        addChild(background)
    }
    
    private func addGround() {
        ground.position = CGPoint(x: hWidth, y: ground.size.height / 2)
        addChild(ground)
    }
    
    private func addDoodads() {
        let groundLevel = ground.size.height
        let cloudGen = CloudGenerator(forScene: self)
        let bushGen = BushGenerator(forScene: self, yBasePos: groundLevel)
        let burriedGen = BurriedGenerator(forScene: self, yBasePos: groundLevel)
        
        [burriedGen, bushGen, cloudGen].forEach { $0.generate() }
    }
    
    private func addBasketMan() {
        basketMan.position = CGPoint(x: hWidth, y: ground.size.height + 10)
        addChild(basketMan)
    }
    
    private func addEvilMonkey() {
        monkey.position = CGPoint(x: hWidth, y: size.height - 180)
        addChild(monkey)
    }
    
    private func addDarkness() {
        let topDarkness = SKSpriteNode(imageNamed: "darkness_top.png")
        let bottomDarkness = SKSpriteNode(imageNamed: "darkness_bottom.png")
        
        topDarkness.size.height *= 0.5
        bottomDarkness.size.height *= 0.7
        
        topDarkness.position = CGPointMake(hWidth, size.height - topDarkness.size.height / 2)
        bottomDarkness.position = CGPointMake(hWidth, bottomDarkness.size.height / 2 - 50)
        
        [topDarkness, bottomDarkness].forEach {
            $0.zPosition = -600
            addChild($0)
        }
    }
    
    private func addTutorialLabel() {
        let label = TutorialLabel(x: hWidth, y: size.height - 45, zPosition: -500)
        
        addChild(label)
    }
    
    private func addInfoLabel() {
        infoLabel = InfoLabel(x: hWidth, y: size.height - 100, zPosition: -500)
        
        addChild(infoLabel!)
    }
    
    private func addButtons() {
        let buttonGenerator = ButtonGenerator(forScene: self, yBasePos: 40)
        
        buttonGenerator.generate()
        
        nextButton = buttonGenerator.nextButton
    }
    
    private func addFinger() {
        finger.position = CGPointMake(hWidth, 100)
        finger.alpha = 0
        
        addChild(finger)
    }
    
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * Tutorial stages
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    private func playCurrentStage() {
        if currentStage == 1 {
            playStage1()
        } else if currentStage == 2 {
            playStage2()
        } else {
            moveToMenuScene()
        }
    }
    
    private func playStage1() {
        prepareButtonsAndLabels(forStage: 1)
        
        let wait = SKAction.waitForDuration(0.65)
        let waitL = SKAction.waitForDuration(1.75)
        let enableNext = enableNextButtonAction()
        let changeLabel = changeLabelAction("Catch all the bananas!")
        
        let throwLeft = SKAction.runBlock {
            self.monkeyThrows(Banana(), throwForceX: -2)
            self.moveBasketMan(-100)
        }
        
        let throwRight = SKAction.runBlock {
            self.monkeyThrows(Banana(), throwForceX: 2)
            self.moveBasketMan(100)
        }
        
        runAction(SKAction.sequence([changeLabel, wait, throwLeft, waitL, throwRight, wait, enableNext]))
    }
    
    private func playStage2() {
        prepareButtonsAndLabels(forStage: 2)
        
        let wait = SKAction.waitForDuration(0.5)
        let waitL = SKAction.waitForDuration(1.5)
        let enableNext = enableNextButtonAction()
        let changeLabel = changeLabelAction("Avoid the cocounuts!")
        
        let throwRight = SKAction.runBlock {
            self.monkeyThrows(Coconut(), throwForceX: 4)
            self.moveBasketMan(-100)
        }
        
        let throwLeft = SKAction.runBlock {
            self.monkeyThrows(Coconut(), throwForceX: -4)
            self.moveBasketMan(100)
        }

        runAction(SKAction.sequence([changeLabel, wait, throwRight, waitL, throwLeft, wait, enableNext]))
    }
    
    private func moveBasketMan(x: CGFloat) {
        finger.position = CGPointMake(hWidth, 100)
        finger.alpha = 0
        
        let wait = SKAction.waitForDuration(0.2)
        let fadeIn = SKAction.fadeInWithDuration(0.3)
        let fadeOut = SKAction.fadeOutWithDuration(0.6)
        let moveLeftF = SKAction.moveToX(hWidth + x, duration: 0.3)
        let moveLeftB = SKAction.moveToX(hWidth + x, duration: 0.75)
        
        finger.runAction(SKAction.sequence([SKAction.group([fadeIn, moveLeftF]), fadeOut]))
        basketMan.runAction(SKAction.sequence([wait, moveLeftB]))
    }
    
    private func monkeyThrows(item: Throwable, throwForceX: CGFloat) {
        item.position = CGPoint(x: monkey.position.x, y: monkey.position.y)
        
        addChild(item)
        
        item.physicsBody?.velocity = CGVectorMake(0,0)
        item.physicsBody?.applyImpulse(CGVectorMake(throwForceX, item.throwForceY()))
        
        monkey.bounce()
    }
    
    private func enableNextButtonAction() -> SKAction {
        return SKAction.runBlock {
            print("Setting stage advancable")
            self.nextButton.alpha = 1.0
            self.stageAdvancable = true
        }
    }
    
    private func changeLabelAction(text: String) -> SKAction {
        return SKAction.runBlock {
            self.infoLabel?.changeText(text)
        }
    }
    
    private func moveToMenuScene() {
        let scene = MenuScene(size: self.size)
        scene.scaleMode = self.scaleMode
        
        self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.5))
    }
    
    private func prepareButtonsAndLabels(forStage stage: Int) {
        infoLabel?.changeText("")
        stageAdvancable = false
        nextButton.alpha = 0.2
        
        if stage == 2 {
            nextButton.texture = SKTexture(imageNamed: "ok.png")
        }
    }
    
    
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * Collission detection callbacks
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    private func throwableHitsBasketMan(item: Throwable) {
        switch item {
            
        case is Banana:
            let pos = item.position
            let label = CollectPointLabel(points: GamePoints.BananaCaught, x: pos.x, y: pos.y)
            
            addChild(label)
            basketMan.collect()
            
        case is Coconut:
            basketMan.ouch()
            
        default:
            unexpectedHit(item, receiver: "BasketMan")
        }
        
        item.removeFromParent()
    }
    
    private func throwableHitsGround(item: Throwable) {
        switch item {
            
        case is Banana:
            basketMan.frown()

            item.removeFromParent()
            
        case is Coconut:
            let pos = CGPointMake(item.position.x, ground.size.height + 5)
            let brokenut = Brokenut(pos: pos)
            
            addChild(brokenut)
            
        default:
            unexpectedHit(item, receiver: "the ground")
        }
        
        item.removeFromParent()
    }
    
    private func unexpectedHit(item: Throwable, receiver: String) {
        fatalError("Unexpected item (\(item)) hit \(receiver)!")
    }
}
