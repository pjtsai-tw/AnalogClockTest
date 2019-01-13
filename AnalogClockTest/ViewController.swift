//
//  ViewController.swift
//  AnalogClockTest
//
//  Created by  Pei-Chih Tsai on 1/9/19.
//  Copyright © 2019 Pei-Chih Tsai. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var clockView: UIView!

    var hourHandLayer: CAShapeLayer = CAShapeLayer()
    var minuteHandLayer: CAShapeLayer = CAShapeLayer()
    var currentQuestionHour: Int = 0
    var currentQuestionMinute: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.timePicker.dataSource = self
        self.timePicker.delegate = self

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.drawClockFace()
        self.initHandLayers()
    }

    @IBAction func generateQuestion(_ sender: Any) {
        self.currentQuestionHour = Int.random(in: 0..<12)
        self.currentQuestionMinute = Int.random(in: 0..<60)
        self.rotateClockHands(hour: self.currentQuestionHour, minute: self.currentQuestionMinute)
    }

    @IBAction func checkAnswer(_ sender: Any) {
        var checkResult = ""
        if ((self.timePicker.selectedRow(inComponent: 0) + 1) % 12 == self.currentQuestionHour) && (self.timePicker.selectedRow(inComponent: 1) == self.currentQuestionMinute) {
            checkResult = "答對了，好棒"
        } else {
            checkResult = "答錯了，再試一次"
        }

        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: checkResult)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        synthesizer.speak(utterance)
    }

    func initHandLayers() {
        let center = CGPoint(x:self.clockView.bounds.midX, y:self.clockView.bounds.midY)
        let radius = CGFloat(self.clockView.bounds.width / 2.0)

        let hourHandPath = UIBezierPath()
        hourHandPath.move(to: CGPoint(x: center.x, y: center.y))
        hourHandPath.addLine(to: CGPoint(x: center.x, y: center.y - (radius * 0.4)))
        self.hourHandLayer.frame = self.clockView.bounds
        self.hourHandLayer.path = hourHandPath.cgPath;
        self.hourHandLayer.strokeColor = UIColor.green.cgColor
        self.hourHandLayer.lineWidth = 10.0
        self.hourHandLayer.fillColor = UIColor.green.cgColor
        self.clockView.layer.addSublayer(self.hourHandLayer)

        let minuteHandPath = UIBezierPath()
        minuteHandPath.move(to: CGPoint(x: center.x, y: center.y))
        minuteHandPath.addLine(to: CGPoint(x: center.x, y: center.y - (radius * 0.6)))
        self.minuteHandLayer.frame = self.clockView.bounds
        self.minuteHandLayer.path = minuteHandPath.cgPath;
        self.minuteHandLayer.strokeColor = UIColor.blue.cgColor
        self.minuteHandLayer.lineWidth = 4.0
        self.minuteHandLayer.fillColor = UIColor.blue.cgColor
        self.clockView.layer.addSublayer(self.minuteHandLayer)
    }

    func rotateClockHands(hour:Int, minute:Int) {
        let hourAngle = (Double((hour % 12) * 30) + Double(minute) * 0.5) * Double.pi / 180
        self.hourHandLayer.transform = CATransform3DMakeRotation(CGFloat(hourAngle), 0, 0, 1)

        let minuteAngle = Double(minute) * 6.0 * Double.pi / 180
        self.minuteHandLayer.transform = CATransform3DMakeRotation(CGFloat(minuteAngle), 0, 0, 1)
   }

    func drawClockFace() {
        let center = CGPoint(x:self.clockView.bounds.midX, y:self.clockView.bounds.midY)
        let radius = CGFloat(self.clockView.bounds.width / 2.0)

        // circle and minute indicators
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.append(UIBezierPath(ovalIn: self.clockView.bounds))
        for i in 1...60 {
            let angle = Double(i) * 6.0 * Double.pi / 180
            path.move(to: CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius))
            if i % 5 == 0 {
                path.addLine(to: CGPoint(x: center.x + CGFloat(cos(angle)) * (radius * 0.85), y: center.y + CGFloat(sin(angle)) * (radius * 0.85)))
            } else {
                path.addLine(to: CGPoint(x: center.x + CGFloat(cos(angle)) * (radius * 0.9), y: center.y + CGFloat(sin(angle)) * (radius * 0.9)))
            }
        }
        shapeLayer.path = path.cgPath;
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = UIColor.white.cgColor
        self.clockView.layer.addSublayer(shapeLayer)

        // numbers
        for i in stride(from: 0, through: 55, by: 5) {
            let angle = Double(i-15) * 6.0 * Double.pi / 180
            let numberLayer = CATextLayer()
            let number = (i == 0) ? "12" : String(i/5)
            let x = center.x + CGFloat(cos(angle)) * (radius * 0.75)
            let y = center.y + CGFloat(sin(angle)) * (radius * 0.75)
            numberLayer.frame = CGRect(x: x-25.0 , y: y - 10.0, width: 50.0, height: 20.0)
            numberLayer.string = number
            numberLayer.fontSize = 20.0;
            numberLayer.alignmentMode = CATextLayerAlignmentMode.center
            numberLayer.foregroundColor = UIColor.black.cgColor
            self.clockView.layer.addSublayer(numberLayer)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return 12
        } else {
            return 60
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return String(row + 1)
        } else {
            return String(row)
        }
    }
}

