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

class ViewController: UIViewController, PDFViewerDelegate, UIGestureRecognizerDelegate {
    
    // MARK : - Properties
    var pdfViewer : PDFViewer?
    var pageRect : CGRect?
    var pdf : PDFDocument? = nil
    public var annotations = [UIBezierPath]()
    var panHandler : UIPanGestureRecognizer?
    
    // MARK : - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the PDF from the main bundle and grab the first page
        let pdfURL = Bundle.main.url(forResource: "pdf", withExtension: "pdf")!
        pdf = PDFDocument(url: pdfURL)!
        pageRect = makeDefaultPageRect()
        let page = getPDFCGImage((pdf?.page(at: 0))!)
        
        
        // Give the first page of the sampe PDF to the PDFViewer along with its frame
        pdfViewer = PDFViewer(page: page!, frame: self.view.bounds, delegate: self)
        
        // Make the PDFViewer the main view
        self.view = pdfViewer!
        
        panHandler = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panHandler?.minimumNumberOfTouches = 2
        panHandler?.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(panHandler!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        pdfViewer?.handleTouchBegan(touch, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        pdfViewer?.handleTouchMoved(touch, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!

        let correctedAnnotation = pdfViewer?.liveAnnotation?.copy() as? UIBezierPath
        
        let pageRectOrigin = pageRect?.origin
        let proX = pageRectOrigin?.x
        let proY = (pageRectOrigin?.y)! + (pageRect?.height)!
        let trans1 = CGAffineTransform(scaleX: 1.0, y: -1.0)
        let trans2 = CGAffineTransform(translationX: (-1.0)*proX!, y: proY)
        correctedAnnotation?.apply(trans1)
        correctedAnnotation?.apply(trans2)
        correctedAnnotation?.lineWidth = 3.0
        correctedAnnotation?.lineCapStyle = .round
        correctedAnnotation?.lineJoinStyle = .round
        annotations.append(correctedAnnotation!)
        pdfViewer?.handleTouchEnded(touch, with: event)
    }
    
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer){
        let state = recognizer.state
        let location = recognizer.location(in: view)
        
        if true {
            switch state {
            case .began:
                pageRect?.origin = location
                pdfViewer!.setNeedsDisplay()
            case .possible:
                fallthrough
            case .changed:
                pageRect?.origin = location
                pdfViewer!.setNeedsDisplay()
            case .ended:
                fallthrough
            case .cancelled:
                fallthrough
            case .failed:
                break
            }
        }
    }
    
    // MARK: - Protocol Methods
    
    func getAnnotationsImage() -> CGImage {
        let size = pageRect?.size
        
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
    
    func getPageRect() -> CGRect {
        return pageRect!
    }
    
    // Takes a newly finished annotation, transforms its coordinates to page coords. and stores it.
    func didFinishAnnotation(_ annotation: UIBezierPath) {
        let pageRectOrigin = pageRect?.origin
        let proX = pageRectOrigin?.x
        let proY = (pageRectOrigin?.y)! + (pageRect?.height)!
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
    
    internal func makeDefaultPageRect() -> CGRect {
        let pdfPage = pdf?.page(at: 0)
        let bounds = pdfPage?.bounds(for: .mediaBox)
        
        let width = bounds?.width
        let height = bounds?.height
        
        let originX = self.view.bounds.midX - width!*0.5
        let originY = self.view.bounds.midY - height!*0.5
        
        let origin = CGPoint(x: originX, y: originY)
        let size = CGSize(width: width!, height: height!)
        
        return CGRect(origin: origin, size: size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

