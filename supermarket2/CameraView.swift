import SwiftUI
import Vision
import AVFoundation
import PhotosUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Binding var startScanning: Bool
    @Binding var detectedBoundingBox: CGRect
    @Binding var inputImage: UIImage?
    @Binding var showImagePicker: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if startScanning {
            context.coordinator.startScanning()
        } else {
            context.coordinator.stopScanning()
        }
        if showImagePicker {
            context.coordinator.showImagePicker()
        }
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
        private let textRecognitionRequest = VNRecognizeTextRequest()

        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            textRecognitionRequest.recognitionLevel = .accurate
        }

        func startScanning() {
            // Custom implementation to start scanning if needed
        }

        func stopScanning() {
            // Custom implementation to stop scanning if needed
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try requestHandler.perform([textRecognitionRequest])
                if let observations = textRecognitionRequest.results as? [VNRecognizedTextObservation], let bestObservation = observations.first {
                    guard let topCandidate = bestObservation.topCandidates(1).first else { return }

                    DispatchQueue.main.async {
                        self.parent.detectedBoundingBox = bestObservation.boundingBox
                        self.parent.recognizedText = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.detectedBoundingBox = .zero
                    }
                }
            } catch {
                print("Failed to perform text recognition: \(error.localizedDescription)")
            }
        }

        func showImagePicker() {
            parent.showImagePicker = false
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(picker, animated: true, completion: nil)
            }
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.inputImage = uiImage
                recognizeTextInImage(uiImage)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        private func recognizeTextInImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                DispatchQueue.main.async {
                    self.parent.recognizedText = recognizedStrings.joined(separator: "\n")
                }
            }
            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.recognitionLanguages = ["en_US"]
            textRecognitionRequest.usesLanguageCorrection = true

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try requestHandler.perform([textRecognitionRequest])
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
