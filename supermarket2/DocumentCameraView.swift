import SwiftUI
import VisionKit
import Vision
struct DocumentCameraView: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Binding var inputImage: UIImage?
    @Binding var showAlert: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentCameraView

        init(_ parent: DocumentCameraView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true) {
                let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                    let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                    DispatchQueue.main.async {
                        self.parent.recognizedText = recognizedStrings.joined(separator: "\n")
                        self.parent.showAlert = true
                    }
                }
                textRecognitionRequest.recognitionLevel = .accurate
                textRecognitionRequest.recognitionLanguages = ["en_US"]
                textRecognitionRequest.usesLanguageCorrection = true

                DispatchQueue.global(qos: .userInitiated).async {
                    let images = (0..<scan.pageCount).compactMap { scan.imageOfPage(at: $0).cgImage }
                    let requests = images.map { VNImageRequestHandler(cgImage: $0, options: [:]) }

                    for (index, request) in requests.enumerated() {
                        do {
                            try request.perform([textRecognitionRequest])
                            DispatchQueue.main.async {
                                if index == 0 {
                                    self.parent.inputImage = UIImage(cgImage: images[index])
                                }
                            }
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
            print("Error: \(error.localizedDescription)")
        }
    }
}
