//
//  PDFViewer.swift
//  PDFAnnotator
//
//  Created by Raphael Reyna on 7/21/18.
//  Copyright © 2018 Raphael Reyna. All rights reserved.
//

// Handles displaying the live annotation for the current touch as well as
// whatever frozenPageImage the delegate hands back after WritablePageView
// sends it the UIBezierPath for a recently finished touch.

import Foundation
import UIKit
import CoreGraphics

protocol WritablePageViewDelegate {
    
    func didFinishAnnotating(_ path: UIBezierPath) -> CGImage?
    
}

class WritablePageView : UIView {
    
    // MARK: - Properties
    // PDF page properties
    
    public var delegate : WritablePageViewDelegate?
    
    public var shouldDraw : Bool = true
    
    public var frozenPageImage : CGImage?{
        
        didSet{
            
            setNeedsDisplay()
            
        }
        
    }
    public var liveAnnotation : UIBezierPath?
    
    // MARK: - Methods
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.white
        
    }
    
    convenience init(frame: CGRect, page: CGImage, delegate: WritablePageViewDelegate) {
        
        self.init(frame: frame)
        
        self.delegate = delegate
        
        frozenPageImage = page
        
    }
    
    // MARK: -  Touch drawing methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        
        handleTouchBegan(touch, with: event)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        
        handleTouchMoved(touch, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        
        handleTouchEnded(touch, with: event)

    }

    public func handleTouchBegan(_ touch: UITouch, with event: UIEvent?){
        
        if shouldDraw {
            
            let location = touch.location(in: self)
            
            liveAnnotation = UIBezierPath()
            
            liveAnnotation?.move(to: location)
            
        }
        
    }
    
    public func handleTouchMoved(_ touch: UITouch, with event: UIEvent?) {
        
        if shouldDraw {
            
            for cotouch in (event?.coalescedTouches(for: touch))! {
                
                let location = cotouch.location(in: self)
                
                liveAnnotation?.addLine(to: location)
                
            }
            
            setNeedsDisplay()
            
        }
        
    }
    
    public func handleTouchEnded(_ touch: UITouch, with event: UIEvent?) {
        
        if shouldDraw {
            
            for cotouch in (event?.coalescedTouches(for: touch))! {
                
                let location = cotouch.location(in: self)
                
                liveAnnotation!.addLine(to: location)
                
            }

            frozenPageImage = delegate?.didFinishAnnotating(liveAnnotation!.copy() as! UIBezierPath)
            
            liveAnnotation = nil
            
        }
        
    }
    
    // On every draw loop iteration, we draw the page, then the finished annotations, and finally the live annotation.
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.setLineCap(.round)
        
        ctx?.setLineWidth(4.0)
        
        ctx?.setStrokeColor(UIColor.red.cgColor)
        
        if frozenPageImage != nil {
            
            ctx?.draw(frozenPageImage!, in: rect)
            
        }
        
        liveAnnotation?.stroke()
        
    }
    
    private func debugPlotCoordinates(_ ctx: CGContext) {
        
        let red = UIColor.red.cgColor
        
        let origin = CGPoint(x: 0, y:0)
        
        let a = 50.0
        
        let b = 20.0
        
        let xAxisRectSize = CGSize(width: a, height: b)
        
        let yAxisRectSize = CGSize(width: b, height: a)
        
        let xAxisRect = CGRect(origin: origin, size: xAxisRectSize)
        
        let yAxisRect = CGRect(origin: origin, size: yAxisRectSize)
        
        ctx.fill(xAxisRect)
        
        ctx.fill(yAxisRect)
        
    }
    
}
