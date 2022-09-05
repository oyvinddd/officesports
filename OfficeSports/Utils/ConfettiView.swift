//
//  ConfettiView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 30/05/2022.
//

import UIKit
import QuartzCore

final class ConfettiView: UIView {
    
    private lazy var emitter: CAEmitterLayer = {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        return emitter
    }()
    
    private var intensity: Float
    private var colors = [UIColor(red: 0.95, green: 0.40, blue: 0.27, alpha: 1),
                             UIColor(red: 1.00, green: 0.78, blue: 0.36, alpha: 1),
                             UIColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1),
                             UIColor(red: 0.30, green: 0.76, blue: 0.85, alpha: 1),
                             UIColor(red: 0.58, green: 0.39, blue: 0.55, alpha: 1)]
    
    init(intensity: Float) {
        self.intensity = intensity
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }
        emitter.birthRate = 1
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
    }
    
    func stop() {
        emitter.birthRate = 0
    }
    
    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let image = UIImage(named: "ConfettiDiamond")!.cgImage
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = image
        return confetti
    }
}
