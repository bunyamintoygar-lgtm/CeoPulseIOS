import SwiftUI
import UIKit

@MainActor
class PDFManager: ObservableObject {
    static let shared = PDFManager()
    
    func generatePDF(insight: AIInsight) -> URL? {
        let pdfView = AIInsightPDFView(insight: insight)
        let renderer = ImageRenderer(content: pdfView)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(insight.title.prefix(20)).pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return url
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
