import AVFoundation
import UIKit

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var detectionRectangle: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        checkCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
        updateDetectionRectangle()
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global(qos: .userInitiated).async {
                self.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.setupCamera()
                        }
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.presentCameraSettings()
            }
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }

    func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]

            let detectionArea = CGRect(x: 0.4, y: 0.2, width: 0.2, height: 0.6)
            metadataOutput.rectOfInterest = detectionArea

            DispatchQueue.main.async {
                self.detectionRectangle = UIView()
                self.detectionRectangle.layer.borderColor = UIColor.green.cgColor
                self.detectionRectangle.layer.borderWidth = 2
                self.view.addSubview(self.detectionRectangle)

                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.frame = self.view.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(self.previewLayer)

                self.view.bringSubviewToFront(self.detectionRectangle)
                self.captureSession.startRunning()
                self.updateDetectionRectangle()
            }
        } else {
            return
        }
    }

    func updateDetectionRectangle() {
        if let previewLayer = previewLayer {
            let rectConverted = previewLayer.layerRectConverted(fromMetadataOutputRect: CGRect(x: 0.4, y: 0.2, width: 0.2, height: 0.6))
            detectionRectangle.frame = rectConverted
        }
    }

    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Permiso de Cámara",
                                                message: "La cámara está deshabilitada. Por favor, habilítela en la configuración.",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Abrir Configuración", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        })

        present(alertController, animated: true, completion: nil)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard readableObject.stringValue != nil else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            captureSession.stopRunning()

            sendQRCodeToAPI()
        }
    }

    func sendQRCodeToAPI() {
        let fixedCode = "01-01-01-01"
        let baseUrl = "https://ews-emea.api.bosch.com/manufacturing/machine/related_mae_information/production_orders_pix/d/v1/pix/createdorconfirmTO/"
        guard let url = URL(string: baseUrl + fixedCode) else {
            showAlert(title: "Error", message: "URL inválida")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            var message: String
            
            if let error = error {
                message = "Error en la solicitud: \(error.localizedDescription)"
            } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                message = responseString
            } else {
                message = "Respuesta inválida o error en el servidor"
            }

            DispatchQueue.main.async {
                self.showAlert(title: "Resultado", message: message)
            }
        }

        task.resume()
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.captureSession.startRunning()
        })
        present(alertController, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
