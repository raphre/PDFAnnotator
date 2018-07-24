//
//  WritablePage.swift
//  PDFAnnotator
//
//  Created by Raphael Reyna on 7/23/18.
//  Copyright © 2018 Raphael Reyna. All rights reserved.
//

// Data model for a writable PDF page. Contains the base page along with an array of
// hand written annotation.
// Handles all of its own drawing to make images that are handed off to WritablePageView to display.

import Foundation
import UIKit
import PDFKit
import CoreGraphics

class WritablePage: NSObject {
    
    // MARK: - Properties
    
    public var pdfPage: PDFPage {
        
        didSet {
            
            needToUpdateFrozenImageCache = true
            
        }
        
    }
    
    public var annotations : [UIBezierPath]?
    
    private var frozenImageCache: CGImage?
    
    private var needToUpdateFrozenImageCache = true
    
    // MARK: - Methods
    required init(page: PDFPage) {
        
        pdfPage = page
        
        annotations = [UIBezierPath]()
        
        super.init()
        
    }

    convenience init(page: PDFPage, annotations: [UIBezierPath]) {
        
        self.init(page: page)
        
        self.annotations = annotations
        
    }
    
    public func getFrozenImage(of size: CGSize) -> CGImage {
        
        if needToUpdateFrozenImageCache {
            
            UIGraphicsBeginImageContext(size)
            
            let ctx = UIGraphicsGetCurrentContext()
            
            drawBackGround(in: ctx!, of: size)
            
            drawAnnotations(in: ctx!, of: size)
            
            frozenImageCache = (ctx?.makeImage())!
            
            UIGraphicsEndImageContext()
            
            needToUpdateFrozenImageCache = false
            
        }
        
        return frozenImageCache!
        
    }

    public func addAnnotation(_ annotation: UIBezierPath){
        
        annotations?.append(annotation)
        
        needToUpdateFrozenImageCache = true
        
    }
    
    private func drawBackGround(in ctx: CGContext, of size: CGSize){
        
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let white = UIColor.white.cgColor
        
        ctx.saveGState()
        
        ctx.setFillColor(white)
        
        ctx.fill(frame)
        
        ctx.drawPDFPage(pdfPage.pageRef!)
        
        ctx.restoreGState()
        
    }
    
    private func drawAnnotations(in ctx: CGContext, of size: CGSize){
        
        ctx.saveGState()
        
        ctx.setLineCap(.round)
        
        ctx.setLineWidth(4.0)
        
        let trans1 = CGAffineTransform(translationX: 0.0, y: size.height)
        
        let trans2 = CGAffineTransform(scaleX: 1.0, y: -1.0)
        
        ctx.concatenate(trans1)
        
        ctx.concatenate(trans2)
        
        ctx.setStrokeColor(UIColor.red.cgColor)
        
        for annotation in annotations! {
            
            annotation.stroke()
            
        }
        
        ctx.restoreGState()
    }
    
}
