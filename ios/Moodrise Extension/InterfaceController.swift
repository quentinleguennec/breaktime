//
//  InterfaceController.swift
//  Moodrise Extension
//
//  Created by Luca on 21/02/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreGraphics
import CoreFoundation
import SpriteKit

class InterfaceController: WKInterfaceController, WCSessionDelegate, WKCrownDelegate {
    
    @IBOutlet weak var sceneInterface: WKInterfaceSKScene!
    @IBOutlet weak var moodLabel: WKInterfaceLabel!
    
    @IBOutlet weak var moodLabelGroup: WKInterfaceGroup!
    @IBOutlet weak var checkImage: WKInterfaceImage!
    
    @IBAction func onPan(_ gestureRecognizer: WKPanGestureRecognizer) {
        if (!moodAlreadySelected) {
            let translation = gestureRecognizer.locationInObject()
            if (gestureRecognizer.state.rawValue == 2 && lastKnownTouchPosition != nil) {
                let deltaY = translation.y - lastKnownTouchPosition!.y
                moveByAmount(amount: Double(deltaY) * 0.01 * -1)
            } else if (gestureRecognizer.state.rawValue == 3) {
                onMoveEnd()
            }
            lastKnownTouchPosition = translation
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        if (!moodAlreadySelected) {
            UserDefaults.standard.set(delta, forKey: "lastDelta")
            if (session != nil) {
                let date = Date.init().timeIntervalSince1970
                if session!.isReachable {
                    session!.sendMessage([String(date):moodText], replyHandler: nil, errorHandler: { error in
                        print("Error sending message",error)
                    })
                } else {
                    session!.transferUserInfo([String(date):moodText])
                }
            }
            runSelectionAnimation()
            moodAlreadySelected = true
        }
    }
    
    var lastKnownTouchPosition : CGPoint? = nil
    var moodAlreadySelected = false
    var session : WCSession?
    var isAlreadyRunning = false
    
    var spriteNode: SKSpriteNode? = nil
    var scene: SKScene? = nil
    var deviceSize: CGSize {
        let currentDevice = WKInterfaceDevice.current()
        let bounds = currentDevice.screenBounds
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    var screenScale: Double {
        let currentDevice = WKInterfaceDevice.current()
        return Double(currentDevice.screenScale)
    }
    
    let animateAlphaUpName = "AnimateAlphaUp"
    let animateAlphaDownName = "AnimateAlphaDown"
    let animateLightPositionName = "AnimateLightPosition"
    
    var circleRadius: Double {
        return Double(deviceSize.width) * 0.5 * screenScale * 1.6
    }
    
    var fadeRunning = false
    var crownRotationDirectionPositive = true
    
    var totalMoods: Int = 0
    var colours : Array<Colour> = []
    let colourAndMoodDictionary = ["Colours":[
        ["calm":["R":(33), "G":(150), "B":(243)]],
    ["content":["R":(179), "G":(229), "B":(252)]],
    ["glad":["R":(100), "G":(181), "B":(246)]],
    ["relaxed":["R":(30), "G":(136), "B":(229)]],
    ["tired":["R":(148), "G":(127), "B":(210)]],
    ["sad":["R":(97), "G":(14), "B":(215)]],
    ["anxious":["R":(51), "G":(26), "B":(140)]],
    ["depressed":["R":(22), "G":(17), "B":(47)]],
    ["angry":["R":(255), "G":(0), "B":(0)]],
    ["frustrated":["R":(254), "G":(78), "B":(0)]],
    ["stressed":["R":(252), "G":(104), "B":(0)]],
    ["annoyed":["R":(247), "G":(124), "B":(0)]],
    ["delighted": ["R":(250), "G":(239), "B":(10)]],
    ["excited": ["R":(246), "G":(222), "B":(0)]],
    ["amused": ["R":(239), "G":(200), "B":(0)]],
    ["happy": ["R":(243), "G":(175), "B":(0)]]
        ]]
    
    
    var moodText: String {
        var indexBelow = Int(floor(delta).truncatingRemainder(dividingBy: Double(totalMoods)))
        let proportionIndexAbove = delta - floor(delta)
        if (indexBelow < 0) {
            indexBelow += totalMoods
        }
        let indexAbove = (indexBelow + 1) % totalMoods
        
        if (proportionIndexAbove < 0.5) {
            return colours[indexBelow].mood
            
        } else {
           return colours[indexAbove].mood
        }
    }
    
    var moodLabelAlpha: CGFloat {
        let proportionIndexAbove = delta - floor(delta)
        let distanceFromMood = min(proportionIndexAbove, 1 - proportionIndexAbove)
        if (distanceFromMood < 0.2) {
            return 1
        } else {
            let gradient = -1.0 / 0.3
            let intercept = 1.0 + (2.0/3.0)
            return CGFloat(intercept + (gradient * distanceFromMood))
        }
    }

    var colorAlpha = 1.0 {
        didSet {
            spriteNode?.color = lightColor.withAlphaComponent(CGFloat(colorAlpha))
        }
    }
    
    var spriteDelta = 0.0 {
        didSet {
            let r = 1.1 * deviceSize.width
            let theta = (spriteDelta/Double(totalMoods)).truncatingRemainder(dividingBy: 1) * 2.0 * Double.pi
            let x = (r * CGFloat(cos(theta))) + (deviceSize.width/2)
            let y = (r * CGFloat(sin(theta))) + (deviceSize.width/2)
            spriteNode?.position = CGPoint.init(x: x, y: y)
        }
    }
    
    var lightColor: UIColor {
        var indexBelow = Int(floor(delta).truncatingRemainder(dividingBy: Double(totalMoods)))
        let proportionIndexAbove = delta - floor(delta)
        if (indexBelow < 0) {
            indexBelow += totalMoods
        }
        let indexAbove = (indexBelow + 1) % totalMoods
        let r = (CGFloat(proportionIndexAbove) * colours[indexAbove].red) + ((1 - CGFloat(proportionIndexAbove)) * colours[indexBelow].red)
        let g = (CGFloat(proportionIndexAbove) * colours[indexAbove].green) + ((1 - CGFloat(proportionIndexAbove)) * colours[indexBelow].green)
        let b = (CGFloat(proportionIndexAbove) * colours[indexAbove].blue) + ((1 - CGFloat(proportionIndexAbove)) * colours[indexBelow].blue)
        return UIColor.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    var delta = 0.0 {
        didSet {
            moodLabel.setText(moodText.lowercased())
            moodLabel.setAlpha(moodLabelAlpha)
            spriteNode?.color = lightColor.withAlphaComponent(CGFloat(colorAlpha))
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // This will be called when the activation of a session finishes.
      
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if !userInfo.isEmpty {
            parseColoursData(data: userInfo)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if !message.isEmpty {
            parseColoursData(data: message)
        }
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        crownSequencer.delegate = self
        crownSequencer.isHapticFeedbackEnabled = true
        // Configure interface objects here.
    }
    
    override func didAppear() {
        super.didAppear()
        crownSequencer.focus()
        
        scene = SKScene.init(size: deviceSize)
        scene!.backgroundColor = SKColor.black
        
        addLightImageToScene()
        sceneInterface.presentScene(scene)
        delta = {delta}()
        spriteDelta = {spriteDelta}()
        if (!isAlreadyRunning) {
            isAlreadyRunning = true
            if ((UserDefaults.standard.object(forKey: "lastDelta")) != nil) {
                delta = UserDefaults.standard.double(forKey: "lastDelta")
                spriteDelta = delta
            }
        }
    }
    
    
    func addLightImageToScene() {
        UIGraphicsBeginImageContext(CGSize(width: 2 * circleRadius, height: 2 * circleRadius))
        let context = UIGraphicsGetCurrentContext()!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        context.saveGState()
        
        let circlePosition = CGPoint(x: circleRadius, y: circleRadius)
        
        let colors = [UIColor.init(red: 1, green: 1, blue: 1, alpha: 1).cgColor, UIColor.init(red: 1, green: 1, blue: 1, alpha: 0).cgColor] as CFArray
        let gradient = CGGradient.init(colorsSpace: colorSpace, colors: colors, locations: nil)
        context.drawRadialGradient(gradient!, startCenter: circlePosition, startRadius: 0, endCenter: circlePosition, endRadius: CGFloat(circleRadius), options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        // Convert to an UIImage
        let cgimage = context.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)
        let texture = SKTexture(image: uiimage)
        
        spriteNode = SKSpriteNode.init(texture: texture)
        spriteNode!.position = CGPoint.init(x: deviceSize.width * 1.1, y: 0)
        spriteNode?.zPosition = -1
        spriteNode!.scale(to: CGSize(width: 2 * circleRadius, height: 2 * circleRadius))
        spriteNode!.colorBlendFactor = 1.0
        scene!.addChild(spriteNode!)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if (!moodAlreadySelected) {
            moveByAmount(amount: rotationalDelta)
        }
    }
    
    func moveByAmount(amount: Double) {
        if (amount > 0) {
            crownRotationDirectionPositive = true
        } else {
            crownRotationDirectionPositive = false
        }
        spriteNode!.removeAction(forKey: animateAlphaUpName)
        let d = 3 * amount
        delta += d
        
        if (!fadeRunning) {
            fadeRunning = true
            let animDuration = 0.5
            let alphaToAdd = 0.3 - colorAlpha
            let startAlpha = colorAlpha
            let customAction = SKAction.customAction(withDuration: animDuration) {
                _, elapsedTime in
                
                self.colorAlpha = startAlpha + ((Double(elapsedTime) / animDuration) * alphaToAdd)
            }
            spriteNode?.run(customAction, withKey: animateAlphaDownName)
        }
        
        if (abs(spriteDelta - delta) > 2) {
            spriteDelta += d
        } else {
            spriteDelta += d/2
        }
        spriteNode!.removeAction(forKey: animateLightPositionName)
    }
    
    func parseColoursData(data: [String: Any]){
        self.colours = []
        if let colourDict = data["Colours"] as? Array<Dictionary<String, Any>> {
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "DataSaved")
            
            colourDict.forEach { (colour) in
                colour.forEach({ (arg0) in
                    let (key, value) = arg0
                    if let valueDict : Dictionary<String, NSNumber> = value as? Dictionary<String, NSNumber>
                    {
                        let colourObject = Colour.init(title: key, r: valueDict["R"] as! Float, g: valueDict["G"] as! Float, b: valueDict["B"] as! Float)
                        self.colours.append(colourObject)
                    }
                })
            }
            totalMoods = self.colours.count
        }
    }
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        if (!moodAlreadySelected) {
            onMoveEnd()
        }
    }
    
    func onMoveEnd() {
        fadeRunning = false
        animateWheelToPosition()
        
        let distance = (delta - spriteDelta).truncatingRemainder(dividingBy: Double(totalMoods))
        let dur = 0.6//max(abs(distance) / 3,0.2)
        let start = spriteDelta
        let action = SKAction.customAction(withDuration: dur) {
            _, elapsedTime in
            self.spriteDelta = start + ((Double(elapsedTime) / dur) * distance)
        }
        action.timingMode = SKActionTimingMode.easeInEaseOut
        spriteNode?.run(action, withKey: animateLightPositionName)
    }
    
    func animateWheelToPosition() {
        spriteNode!.removeAction(forKey: animateAlphaDownName)
        let remainder = delta - floor(delta)
        let animStartAngle = delta
        var animAngleToAdd = 0.0
        
        if (crownRotationDirectionPositive == true) {
            if (remainder < 0.2) {
                animAngleToAdd = -1 * remainder;
            } else {
                animAngleToAdd = 1 - remainder;
            }
        } else {
            if (remainder < 0.8) {
                animAngleToAdd = -1 * remainder;
            } else {
                animAngleToAdd = 1 - remainder;
            }
        }
        let animDuration = 1.5
        let alphaToAdd = 1 - colorAlpha
        let startAlpha = colorAlpha
        let customAction = SKAction.customAction(withDuration: animDuration) {
            _, elapsedTime in
            
            self.delta = animStartAngle + ((Double(elapsedTime) / animDuration) * animAngleToAdd)
            self.colorAlpha = startAlpha + ((Double(elapsedTime) / animDuration) * alphaToAdd)
        }
        spriteNode?.run(customAction, withKey: animateAlphaUpName)
    }
    
    func runSelectionAnimation() {
        self.checkImage.setHidden(false)
        self.checkImage.setImageNamed("check-")
        spriteNode!.removeAllActions()
        let colorStartAlpha = colorAlpha
        let moodLabelStartAlpha = Double(moodLabelAlpha)
        let duration1 = 0.4
        let fadeText = SKAction.customAction(withDuration: duration1) {
            _, elapsedTime in
            self.colorAlpha = colorStartAlpha - Double(((elapsedTime / CGFloat(duration1)) * CGFloat(colorStartAlpha)))
            self.moodLabel.setAlpha(CGFloat(moodLabelStartAlpha - Double(((elapsedTime / CGFloat(duration1)) * CGFloat(moodLabelStartAlpha)))))
        }
        var runCheckAnim = true
        let duration2 = 0.4
        let labelEndPosition = 0.4
        let checkAndFadeUpText = SKAction.customAction(withDuration: duration2) {
            _, elapsedTime in
            if (runCheckAnim) {
                self.moodLabelGroup.setRelativeHeight(1 - CGFloat(labelEndPosition), withAdjustment: 0)
                self.checkImage.setAlpha(1.0)
                self.checkImage.startAnimatingWithImages(in: NSRange(location: 0,length: 85), duration: duration2, repeatCount: 1)
                runCheckAnim = false
            }
            self.moodLabel.setAlpha(elapsedTime/CGFloat(duration2))
        }
        let sequence = SKAction.sequence([fadeText,checkAndFadeUpText])
        spriteNode!.run(sequence)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "DataSaved") as? [String: Any] {
            parseColoursData(data: data)
        } else {
            parseColoursData(data: self.colourAndMoodDictionary)
        }
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
    }
    
    func reset() {
        checkImage.setHidden(true)
        moodLabelGroup.setRelativeHeight(1, withAdjustment: 0)
        colorAlpha = 1.0
        moodAlreadySelected = false
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        reset()
    }
}

class Colour{
    var mood: String = ""
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    init(title: String, r: Float, g: Float, b: Float) {
        self.mood = title
        self.red = CGFloat(r/255)
        self.green = CGFloat(g/255)
        self.blue = CGFloat(b/255)
    }
}
