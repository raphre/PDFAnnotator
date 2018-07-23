//
//  PDFViewer.swift
//  PDFAnnotator
//
//  Created by Raphael Reyna on 7/21/18.
//  Copyright © 2018 Raphael Reyna. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

protocol PDFPageViewDelegate {
    func didFinishAnnotating(_ path: UIBezierPath)
}

class PDFPageView : UIView {
    // MARK: - Properties
    // PDF page properties
    public var delegate : PDFPageViewDelegate?
    public var pdfPage : CGImage?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var frozenAnnotations : CGImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    public var liveAnnotation : UIBezierPath?
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        frozenAnnotations = makeEmptyAnnotations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.white
        frozenAnnotations = makeEmptyAnnotations()
    }
    
    convenience init(frame: CGRect, page: CGImage, delegate: PDFPageViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
        pdfPage = page
    }
    
    // MARK: - Apple Pencil drawing methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        switch touch.type {
        case .stylus:
            handleTouchBegan(touch, with: event)
            break
        default:
            next?.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        switch touch.type {
        case .stylus:
            handleTouchMoved(touch, with: event)
            break
        default:
            next?.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        switch touch.type {
        case .stylus:
            handleTouchEnded(touch, with: event)
            break
        default:
            next?.touchesEnded(touches, with: event)
        }
    }

    public func handleTouchBegan(_ touch: UITouch, with event: UIEvent?){
        let location = touch.location(in: self)
        liveAnnotation = UIBezierPath()
        liveAnnotation?.move(to: location)
    }
    
    public func handleTouchMoved(_ touch: UITouch, with event: UIEvent?) {
        for cotouch in (event?.coalescedTouches(for: touch))! {
            let location = cotouch.location(in: self)
            liveAnnotation?.addLine(to: location)
        }
        setNeedsDisplay()
    }
    
    public func handleTouchEnded(_ touch: UITouch, with event: UIEvent?) {
        for cotouch in (event?.coalescedTouches(for: touch))! {
            let location = cotouch.location(in: self)
            liveAnnotation!.addLine(to: location)
        }
        delegate?.didFinishAnnotating(liveAnnotation!)
    }
    
    
    // On every draw loop iteration, we draw the page, then the finished annotations, and finally the live annotation.
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineCap(.round)
        ctx?.setLineWidth(3.0)
        ctx?.setStrokeColor(UIColor.red.cgColor)
        ctx?.draw(pdfPage!, in: rect)
        ctx?.draw(frozenAnnotations!, in: rect)
        liveAnnotation?.stroke()
    }
    
    internal func makeEmptyAnnotations() -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx: CGContext = CGContext.init(data: nil, width: Int(self.frame.width), height: Int(self.frame.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        return ctx.makeImage()!
    }
}
