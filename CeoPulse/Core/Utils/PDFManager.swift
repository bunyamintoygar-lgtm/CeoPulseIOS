import SwiftUI
import UIKit

@MainActor
class PDFManager {
    static let shared = PDFManager()
    
    func generatePDF<Content: View>(view: Content, filename: String) -> URL? {
        let renderer = ImageRenderer(content: view)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return url
    }
}


