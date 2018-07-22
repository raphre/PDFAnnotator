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
    //func getTransformation() -> CGAffineTransform
    func didFinishAnnotation(_ annotation: UIBezierPath)
}

class PDFViewer : UIView {
    // MARK: - Properties
    public var delegate : PDFViewerDelegate?
    
    // PDF page properties
    public var pageRect : CGRect?
    private var pdfPage : CGImage?
    private let backGroundColor : CGColor = UIColor.white.cgColor
    
    // Annotations properties
    private var liveAnnotation : UIBezierPath?
    

    // MARK: - Methods
    required init(page: CGImage, frame: CGRect, delegate: PDFViewerDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        pdfPage = page
        pageRect = makeDefaultPageRect()
    }
    
    /*
         Checks if the touch was from an apple pencil and inside of the page rectangle.
         If so, we start a new UIBezierPath and set its starting point to where to
         touch occured.
    */
    
    // MARK: - Apple Pencil drawing methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)

        if (touch.type == .stylus && (pageRect?.contains(location))!){
            liveAnnotation = UIBezierPath()
            liveAnnotation?.move(to: location)
        }
    }
    
    /*
        Checks if the touch was from an apple pencil and inside of the page rectangle.
        If so, we move through the coalesced touches, adding their points to the path.
        Finally, we tell iOS we wish to refresh the display within the page rectangle.
    */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        for cotouch in (event?.coalescedTouches(for: touch))! {
            let location = cotouch.location(in: self)
            if (touch.type == .stylus && (pageRect?.contains(location))!) {
                liveAnnotation?.addLine(to: location)
            }
        }
        setNeedsDisplay(pageRect!)
    }
    
    /*
         Checks if the touch was from an apple pencil and inside of the page rectangle.
         If so, we move through the coalesced touches, adding their points to the path.
         We then tell iOS we wish to refresh the display within the page rectangle.
         Once we have drawn the UIBezierPath, we send it to the delegate.
    */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        for cotouch in (event?.coalescedTouches(for: touch))! {
            let location = cotouch.location(in: self)
            if (touch.type == .stylus && (pageRect?.contains(location))!) {
                liveAnnotation?.addLine(to: location)
            }
        }
        setNeedsDisplay(pageRect!)
        delegate?.didFinishAnnotation(liveAnnotation!)
    }

    // On every draw loop iteration, we draw the page, then the finished annotations, and finally the live annotation.
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        drawPage(ctx!)
        drawAnnotations(ctx!)
        setupStroke(ctx!)
        drawAnnotation()
    }
    
    // Draws the background and then the page into the context.
    internal func drawPage(_ ctx: CGContext) {
        drawPageBackground(ctx)
        ctx.draw(pdfPage!, in: pageRect!)
    }
    
    // Returns the default CGRect for displaying the PDF.
    // The default is to fully display the PDF in the center of the screen.
    internal func makeDefaultPageRect() -> CGRect {
        let width = CGFloat(pdfPage?.width as! Int)
        let height = CGFloat(pdfPage?.height as! Int)
        
        let originX = self.bounds.midX - width*0.5
        let originY = self.bounds.midY - height*0.5
        
        let origin = CGPoint(x: originX, y: originY)
        let size = CGSize(width: width, height: height)
        
        return CGRect(origin: origin, size: size)
    }
    
    
    internal func drawPageBackground(_ ctx: CGContext) {
        ctx.setFillColor(backGroundColor)
        ctx.fill(pageRect!)
    }
    
    internal func drawAnnotations(_ ctx: CGContext){
        let image = delegate?.getAnnotationsImage()
        ctx.draw(image!, in: pageRect!)
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
