//
//  ViewController.swift
//  PDFAnnotator
//
//  Created by Raphael Reyna on 7/21/18.
//  Copyright © 2018 Raphael Reyna. All rights reserved.
//
// This View Controller currently just serves up a CGImage to the PDFViewer.

import UIKit
import PDFKit

class ViewController: UIViewController, PDFViewerDelegate {
    // MARK : - Properties
    var pdfViewer : PDFViewer?
    var pdf : PDFDocument? = nil
    public var annotations = [UIBezierPath]()
    
    // MARK : - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load the PDF from the main bundle and grab the first page
        let pdfURL = Bundle.main.url(forResource: "pdf", withExtension: "pdf")!
        pdf = PDFDocument(url: pdfURL)!
        let page = getPDFCGImage((pdf?.page(at: 0))!)
        
        // Give the first page of the sampe PDF to the PDFViewer along with its frame
        pdfViewer = PDFViewer(page: page!, frame: self.view.bounds, delegate: self)
        
        // Make the PDFViewer the main view
        self.view = pdfViewer!
    }
    
    // MARK: - Protocol Methods
    
    func getAnnotationsImage() -> CGImage {
        let size = self.pdfViewer?.pageRect?.size
        
        UIGraphicsBeginImageContext(size!)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.red.cgColor)
        for path in annotations {
            path.stroke()
        }
        let image = ctx?.makeImage()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // Takes a newly finished annotation, transforms its coordinates to page coords. and stores it.
    func didFinishAnnotation(_ annotation: UIBezierPath) {
        let pageRect = self.pdfViewer?.pageRect
        let pageRectOrigin = pageRect?.origin
        let proX = pageRectOrigin?.x
        let proY = (pageRectOrigin?.y)! + (self.pdfViewer?.pageRect?.height)!
        let trans1 = CGAffineTransform(scaleX: 1.0, y: -1.0)
        let trans2 = CGAffineTransform(translationX: (-1.0)*proX!, y: proY)
        
        let correctedAnnotation = annotation.copy() as! UIBezierPath
        correctedAnnotation.apply(trans1)
        correctedAnnotation.apply(trans2)
        correctedAnnotation.lineWidth = 3.0
        correctedAnnotation.lineCapStyle = .round
        correctedAnnotation.lineJoinStyle = .round
        annotations.append(correctedAnnotation)
    }

    // MARK: - PDF conversion method.
    
    // Converts the PDFPage into a CGImage. This method handles
    // page flipping.
    // TODO : Make this functions more robust.
    func getPDFCGImage(_ pdfPage: PDFPage) -> CGImage?{
        let pdfPageBounds = pdfPage.bounds(for: .mediaBox)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx: CGContext = CGContext.init(data: nil, width: Int(pdfPageBounds.width), height: Int(pdfPageBounds.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        let bounds = pdfPage.bounds(for: .mediaBox)
        let width = bounds.width
        let height = bounds.height
        
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.translateBy(x: 0.0, y: -height)
        
        ctx.drawPDFPage(pdfPage.pageRef!)
        return ctx.makeImage()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

