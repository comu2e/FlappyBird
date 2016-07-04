//
//  GameScene.swift
//  FlappyBird
//
//  Created by Eiji Takahashi on 2016/06/30.
//  Copyright © 2016年 devlpEiji. All rights reserved.
//

import SpriteKit
class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var coinNode:SKNode!
    
    var bird:SKSpriteNode!

    
    
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let CoinCategory:UInt32 = 1 << 4       // 0...10000

    // スコア
    var score = 0
    var coinScore = 0
    var scoreLabelNode:SKLabelNode!
    var coinscoreLabelNode:SKLabelNode!
    let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    
    
    override func didMoveToView(view: SKView) {
        // 背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0) // ←追加
        physicsWorld.contactDelegate = self // ←追加

        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        coinNode = SKNode()
        scrollNode.addChild(coinNode)
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupCoin()
//
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
    }
    
//    コインと衝突した時に呼び出されるメソッド

 
    
//    コインのスプライト
    

    
    func setupCoin() {
        // コインの画像を読み込む
        let coinTexture = SKTexture(imageNamed: "coin_a")
        coinTexture.filteringMode = SKTextureFilteringMode.Linear
        
        
        let movingDistance = CGFloat(self.frame.size.width + coinTexture.size().width * 2)
        let moveCoin = SKAction.moveByX(-movingDistance, y: 0, duration:4.0)
        let removeCoin = SKAction.removeFromParent()
        
        let CoinAnimation = SKAction.sequence([moveCoin, removeCoin])
        
        
        
        let createCoinAnimation = SKAction.runBlock(
        {
            let coin = SKNode()
            coin.zPosition = -50.0

            
            coin.position = CGPoint(x: self.frame.size.width + coinTexture.size().width * 2, y: 0.0)
            coin.physicsBody?.categoryBitMask = self.CoinCategory
            
            let random_x_range = self.frame.size.width / 4.0
            let random_x = arc4random_uniform( UInt32(random_x_range) )
            let under_coin_x = CGFloat(random_x)

            let center_y = self.frame.size.height / 2
            let random_y_range = self.frame.size.height / 4
            let under_coin_lowest_y = UInt32( center_y - coinTexture.size().height / 2 -  random_y_range / 2)
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            let under_coin_y = CGFloat(under_coin_lowest_y + random_y)
        
                    
            let coinNode = SKSpriteNode(texture: coinTexture)
            let coin_size = CGFloat(coinTexture.size().height / 2 )
            coinNode.physicsBody = SKPhysicsBody(circleOfRadius:coin_size )

            
            coinNode.position = CGPoint(x: under_coin_x , y: under_coin_y)
            coinNode.physicsBody?.dynamic = false
            coinNode.physicsBody?.categoryBitMask = self.CoinCategory
            coinNode.physicsBody?.contactTestBitMask = self.birdCategory
            coin.addChild(coinNode)
            coin.runAction(CoinAnimation)

        self.coinNode.addChild(coin)

        })
        
        let waitAnimation = SKAction.waitForDuration(2)

        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createCoinAnimation, waitAnimation]))
        let delay =  SKAction.sequence([SKAction.waitForDuration(1), repeatForeverAnimation])
        runAction(delay)
    }

    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        coinScore = 0
        coinscoreLabelNode = SKLabelNode()
        coinscoreLabelNode.fontColor = UIColor.blackColor()
        coinscoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        coinscoreLabelNode.zPosition = 100 // 一番手前に表示する
        coinscoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        coinscoreLabelNode.text = "CoinScore:\(coinScore)"
        self.addChild(coinscoreLabelNode)
        

        
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
   

    
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)") // ←追加
        coinScore = 0
        coinscoreLabelNode.text = String("CoinScore:\(coinScore)") // ←追加
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        coinNode.removeAllChildren()
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    func didBeginContact(contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
//         (0100) == (0100)
//        1111 (３桁が１の時と４桁の１がカテゴリ

        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integerForKey("BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"

                userDefaults.setInteger(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        }else if (contact.bodyA.categoryBitMask & CoinCategory) == CoinCategory || (contact.bodyB.categoryBitMask & CoinCategory) == CoinCategory {
            // スコア用の物体と衝突した
            print("Coin")
            contact.bodyB.node!.removeFromParent() 
            coinScore += 1
            score += 1
            coinscoreLabelNode.text = "CoinScore:\(coinScore)"
            scoreLabelNode.text = "Score:\(score)"
//           音追加
            runAction(self.sound)
            
            
        }else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.runAction(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .Linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .Linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animateWithTextures([birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(texuresAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
//        birdがぶつかるカテゴリを設定するマスク？
//        上は物理演算でぶつかるか
//        下は接触したか 下をdidBeginContactがよびださる　オブジェクトがどこを遠たか取得できる <-透明なオブジェクト（通過したかどうか）
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory | CoinCategory  //(0100||0010 -> 0110)
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | CoinCategory  //(0100||0010 -> 0110)

//        
        // アニメーションを設定
        bird.runAction(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // 必要な枚数を計算
        let needGroundNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveByX(-groundTexture.size().width , y: 0, duration: 5.0)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
        
        // スプライトを配置する
        for var i:CGFloat = 0; i < needGroundNumber; i += 1 {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            // スプライトにアクションを設定する
            sprite.runAction(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.dynamic = false
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // 必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width , y: 0, duration: 20.0)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveByX(cloudTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        for var i:CGFloat = 0; i < needCloudNumber; i += 1 {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            // スプライトにアニメーションを設定する
            sprite.runAction(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = SKTextureFilteringMode.Linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * 2)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration:4.0)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.runBlock({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width * 2, y: 0.0)
            wall.zPosition = -50.0 // 雲より手前、地面より奥
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            // 衝突の時に動かないように設定する
            under.physicsBody?.dynamic = false
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory // ←追加
            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.dynamic = false
            
            wall.addChild(upper)
            
            // スコアアップ用のノード --- ここから ---
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            // --- ここまで追加 ---
            
            wall.runAction(wallAnimation)
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.waitForDuration(2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }
}
    