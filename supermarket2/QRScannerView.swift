import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> QRScannerViewController {
        return QRScannerViewController()
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}
