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

class PDFViewer : UIView {
    // MARK : -
    // MARK : - Properties
    // MARK : -
    public var pageRect : CGRect?
    public var pdfPage : CGImage?
    private let backGroundColor : CGColor = UIColor.white.cgColor
    
    // MARK : -
    // MARK : - Methods
    // MARK : -
    required init(page: CGImage, frame: CGRect) {
        super.init(frame: frame)
        pdfPage = page
        pageRect = makeDefaultPageRect()
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        drawPage(ctx!)
    }
    
    // Draws the background and then the page into the context
    internal func drawPage(_ ctx: CGContext) {
        drawPageBackground(ctx)
        ctx.draw(pdfPage!, in: pageRect!)
    }
    
    // Returns the default CGRect for displaying the PDF.
    // The default is to fully display the PDF in the center of the screen
    internal func makeDefaultPageRect() -> CGRect {
        let width = CGFloat(pdfPage?.width as! Int)
        let height = CGFloat(pdfPage?.height as! Int)
        
        let originX = self.bounds.midX - width*0.5
        let originY = self.bounds.midY - height*0.5
        
        let origin = CGPoint(x: originX, y: originY)
        let size = CGSize(width: width, height: height)
        
        return CGRect(origin: origin, size: size)
    }
    
    // Fills the page rectangle with white
    internal func drawPageBackground(_ ctx: CGContext) {
        ctx.setFillColor(backGroundColor)
        ctx.fill(pageRect!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
