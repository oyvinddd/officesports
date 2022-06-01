//
//  ScannerFrameLinesView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 28/05/2022.
//

import UIKit

final class ScannerFrameLinesView: UIView {
    
    private let activeColor = UIColor.OS.Status.success.cgColor
    private let inactiveColor = UIColor.white.cgColor
    private let frameWidth = 8.0
    
    var isActive: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        alpha = 0.6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard var ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        if isActive {
            drawActiveFrame(&ctx)
        } else {
            drawInactiveFrame(&ctx)
        }
    }
    
    private func drawActiveFrame(_ ctx: inout CGContext) {
        let width: CGFloat = bounds.width
        let height: CGFloat = bounds.height
        
        ctx.setStrokeColor(activeColor)
        ctx.setLineWidth(frameWidth)
        
        ctx.move(to: CGPoint.zero)
        ctx.addLine(to: CGPoint(x: 0, y: height))
        ctx.addLine(to: CGPoint(x: width, y: height))
        ctx.addLine(to: CGPoint(x: width, y: 0))
        ctx.addLine(to: CGPoint.zero)
        
        ctx.strokePath()
    }
    
    private func drawInactiveFrame(_ ctx: inout CGContext) {
        let width: CGFloat = bounds.width
        let height: CGFloat = bounds.height
        let lll: CGFloat = 25
        
        ctx.setStrokeColor(inactiveColor)
        ctx.setLineWidth(frameWidth)
        
        ctx.move(to: CGPoint.zero)
        ctx.addLine(to: CGPoint(x: lll, y: 0))
        ctx.move(to: CGPoint.zero)
        ctx.addLine(to: CGPoint(x: 0, y: lll))
        
        ctx.strokePath()
        
        ctx.move(to: CGPoint(x: width - lll, y: 0))
        ctx.addLine(to: CGPoint(x: width, y: 0))
        ctx.addLine(to: CGPoint(x: width, y: lll))
        
        ctx.strokePath()
        
        ctx.move(to: CGPoint(x: width, y: height - lll))
        ctx.addLine(to: CGPoint(x: width, y: height))
        ctx.addLine(to: CGPoint(x: width - lll, y: height))
        
        ctx.strokePath()
        
        ctx.move(to: CGPoint(x: lll, y: height))
        ctx.addLine(to: CGPoint(x: 0, y: height))
        ctx.addLine(to: CGPoint(x: 0, y: height - lll))
        
        ctx.strokePath()
    }
}
