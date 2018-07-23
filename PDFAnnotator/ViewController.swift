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

class ViewController: UIViewController {
    // MARK : - Properties
    @IBOutlet weak var pageView: PDFPageView!
    @IBOutlet var scrollView: UIScrollView!
    public var annotations = [UIBezierPath]()

    // MARK : - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load the PDF from the main bundle and grab the first page
        let pdfURL = Bundle.main.url(forResource: "pdf", withExtension: "pdf")!
        let pdf = PDFDocument(url: pdfURL)!
        let page = makePDFCGImage((pdf.page(at: 0))!)
        pageView.pdfPage = page
        pageView.delegate = self
        let origin = pageView.frame.origin
        let size = pdf.page(at: 0)?.bounds(for: .mediaBox).size
        pageView.frame = makeCenteredFrame(pageSize: size!, superRect: scrollView.frame)
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.panGestureRecognizer.maximumNumberOfTouches = 2
    }
}

// MARK:  UIScrollViewDelegate
extension ViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pageView
    }
}

// MARK:  UIScrollViewDelegate
extension ViewController : PDFPageViewDelegate {
    public func didFinishAnnotating(_ path: UIBezierPath) {
        let pathCopy = path.copy() as! UIBezierPath
        pageView?.liveAnnotation = nil
        annotations.append(pathCopy)
        pageView?.frozenAnnotations = makeAnnotationsImage()
    }
    
    internal func makeAnnotationsImage() -> CGImage {
        let size = pageView!.bounds.size
        
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        let trans1 = CGAffineTransform(translationX: 0.0, y: size.height)
        let trans2 = CGAffineTransform(scaleX: 1.0, y: -1.0)
        ctx?.concatenate(trans1)
        ctx?.concatenate(trans2)
        ctx?.setStrokeColor(UIColor.red.cgColor)
        for path in annotations {
            path.stroke()
        }
        let image = ctx?.makeImage()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

internal func makePDFCGImage(_ pdfPage: PDFPage) -> CGImage?{
    let pdfPageBounds = pdfPage.bounds(for: .mediaBox)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let ctx: CGContext = CGContext.init(data: nil, width: Int(pdfPageBounds.width), height: Int(pdfPageBounds.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let bounds = pdfPage.bounds(for: .mediaBox)
    let height = bounds.height
    
    ctx.scaleBy(x: 1.0, y: -1.0)
    ctx.translateBy(x: 0.0, y: -height)
    
    ctx.drawPDFPage(pdfPage.pageRef!)
    return ctx.makeImage()
}

internal func makeCenteredFrame(pageSize: CGSize, superRect: CGRect) -> CGRect {
    let oX = superRect.midX - pageSize.width*0.5
    let oY = superRect.midY - pageSize.height*0.5
    let origin = CGPoint(x: oX, y: oY)
    
    return CGRect(origin: origin, size: pageSize)
}

