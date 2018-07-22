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

protocol PDFViewerDelegate {
    func getAnnotationsImage() -> CGImage
    func getPageRect() -> CGRect
}

class PDFViewer : UIView {
    // MARK: - Properties
    public var delegate : PDFViewerDelegate?
    
    // PDF page properties
    private var pdfPage : CGImage?
    private let backGroundColor : CGColor = UIColor.white.cgColor
    
    // Annotations properties
    public var liveAnnotation : UIBezierPath?

    // MARK: - Methods
    required init(page: CGImage, frame: CGRect, delegate: PDFViewerDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        pdfPage = page
    }
    
    
    // MARK: - Apple Pencil drawing methods

    public func handleTouchBegan(_ touch: UITouch, with event: UIEvent?){
        let location = touch.location(in: self)
        
        if (touch.type == .stylus && (delegate!.getPageRect().contains(location))){
            liveAnnotation = UIBezierPath()
            liveAnnotation?.move(to: location)
        }
        setNeedsDisplay()
    }
    
    public func handleTouchMoved(_ touch: UITouch, with event: UIEvent?) {
        let pageRect = delegate!.getPageRect()
        for cotouch in (event?.coalescedTouches(for: touch))! {
            let location = cotouch.location(in: self)
            if (touch.type == .stylus && (pageRect.contains(location))) {
                liveAnnotation?.addLine(to: location)
            }
        }
        setNeedsDisplay()
    }

    public func handleTouchEnded(_ touch: UITouch, with event: UIEvent?) {
        let pageRect = delegate!.getPageRect()
        for cotouch in (event?.coalescedTouches(for: touch))! {
            let location = cotouch.location(in: self)
            if (touch.type == .stylus && pageRect.contains(location)) {
                liveAnnotation?.addLine(to: location)
            }
        }
        liveAnnotation = nil
        setNeedsDisplay()
    }

    // On every draw loop iteration, we draw the page, then the finished annotations, and finally the live annotation.
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.clear(rect)
        drawPage(ctx!)
        drawAnnotations(ctx!)
        setupStroke(ctx!)
        drawAnnotation()
    }
    
    // Draws the background and then the page into the context.
    
    internal func drawPage(_ ctx: CGContext) {
        drawPageBackground(ctx)
        ctx.draw(pdfPage!, in: delegate!.getPageRect())
    }
    
    // Returns the default CGRect for displaying the PDF.
    // The default is to fully display the PDF in the center of the screen.
    
    
    internal func drawPageBackground(_ ctx: CGContext) {
        ctx.setFillColor(backGroundColor)
        ctx.fill(delegate!.getPageRect())
    }
    
    internal func drawAnnotations(_ ctx: CGContext){
        let image = delegate?.getAnnotationsImage()
        ctx.draw(image!, in: delegate!.getPageRect())
    }
    
    internal func drawAnnotation(){
        if let annotation = liveAnnotation {
            annotation.stroke()
        }
    }
    
    internal func setupStroke(_ ctx: CGContext){
        ctx.setLineCap(.round)
        ctx.setLineWidth(3.0)
        ctx.setStrokeColor(UIColor.red.cgColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
