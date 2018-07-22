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
    
    // MARK : -
    // MARK : - Properties
    // MARK : -
    
    var pdfViewer : PDFViewer?
    var pdf : PDFDocument? = nil
    
    
    // MARK : -
    // MARK : - Methods
    // MARK : -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the PDF from the main bundle and grab the first page
        let pdfURL = Bundle.main.url(forResource: "pdf", withExtension: "pdf") as! URL
        pdf = PDFDocument(url: pdfURL)!
        let page = getPDFCGImage((pdf?.page(at: 0))!)
        
        // Give the first page of the sampe PDF to the PDFViewer along with its frame
        pdfViewer = PDFViewer(page: page!, frame: self.view.bounds)
        
        // Make the PDFViewer the main view
        self.view = pdfViewer!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
}

