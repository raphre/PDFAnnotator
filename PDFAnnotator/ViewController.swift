//
//  ViewController.swift
//  PDFAnnotator
//
//  Created by Raphael Reyna on 7/21/18.
//  Copyright © 2018 Raphael Reyna. All rights reserved.
//

import UIKit

import PDFKit

class ViewController: UIViewController {
    
    // MARK : - Properties
    
    var writablePage : WritablePage?
    
    var writablePageView : WritablePageView?

    // MARK : - Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let pdfPage = getSamplePDFDocument().page(at: 0)!
        
        writablePage = WritablePage(page: pdfPage)
        
        let frame = makeCenteredFrame(pageSize: ((writablePage?.pdfPage.bounds(for: .mediaBox))?.size)!, superRect: view.frame)
        
        let pageImage = writablePage?.getFrozenImage(of: frame.size)
        
        writablePageView = WritablePageView(frame: frame, page: pageImage!, delegate: self)
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(writablePageView!)
        
    }
    
}

extension ViewController : WritablePageViewDelegate {
    
    func didFinishAnnotating(_ path: UIBezierPath) -> CGImage? {
        
        writablePage?.addAnnotation(path)
        
        return writablePage?.getFrozenImage(of:((writablePage?.pdfPage.bounds(for: .mediaBox))?.size)!)
        
    }
    
}
