import SwiftUI
import Vision
import VisionKit

struct ContentView2: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("118_w1280")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 10) // Ajuste la altura según sea necesario
                        .clipped()
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Image("LOGO")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 55)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    Text("TrackTrek")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
                
                Text("Main Menu")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 30)
                
                Spacer()
                
                NavigationLink(destination: QRScannerView()) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Scan QR/Barcode")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)

                NavigationLink(destination: CameraAndDocumentView()) {
                    HStack {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Capture Photo and Detect Text")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: .green.opacity(0.4), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

struct CameraAndDocumentView: View {
    @State private var recognizedText = ""
    @State private var inputImage: UIImage?
    @State private var showImagePicker = false
    @State private var showDocumentCamera = false
    @State private var showAlert = false
    @State private var showTextDetail = false

    var body: some View {
        VStack {
            VStack {
                Image("118_w1280")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 10)
                    .clipped()
                
                Spacer().frame(height: 20)
                
                HStack {
                    Image("LOGO")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 55)
                }
                
                Spacer().frame(height: 10)
                
                Text("TrackTrek")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            
            Spacer()
            
            if let inputImage = inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom, 20)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    showDocumentCamera = true
                }) {
                    HStack {
                        Image(systemName: "doc.text.viewfinder")
                        Text("Scan Document")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }

                Button(action: {
                    showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select from Gallery")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding()

            Button(action: {
                showTextDetail.toggle()
            }) {
                Text(recognizedText.isEmpty ? "No text detected" : recognizedText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sheet(isPresented: $showTextDetail) {
                TextDetailView(recognizedText: $recognizedText)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Para que el VStack ocupe toda la pantalla
        .background(Color.white.edgesIgnoringSafeArea(.all)) // Asegúrate de que el fondo sea blanco
        .sheet(isPresented: $showDocumentCamera) {
            DocumentCameraView(recognizedText: $recognizedText, inputImage: $inputImage, showAlert: $showAlert)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage) { selectedImage in
                if let selectedImage = selectedImage {
                    inputImage = selectedImage
                    recognizeTextInImage(selectedImage)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Detected Text"), message: Text(recognizedText), dismissButton: .default(Text("OK")) {
                // No additional action needed
            })
        }
    }

    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async {
                recognizedText = recognizedStrings.joined(separator: "\n")
                showAlert = true
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
