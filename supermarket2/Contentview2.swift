import SwiftUI
import Vision
import VisionKit


    struct ContentView2: View {
        @State private var showMenu = false
        @State private var showRightMenu = false
        
        var body: some View {
            NavigationView {
                ZStack(alignment: .leading) {
                    VStack {
                        Image("118_w1280")
                                     .resizable()
                                     .aspectRatio(contentMode: .fill)
                                     .frame(height: 15) // Ajusta la altura según sea necesario
                                     .clipped()
                        HStack {
                            // Botón del menú lateral izquierdo
                            Button(action: {
                                withAnimation {
                                    showMenu.toggle() // Alternar el estado del menú
                                }
                            }) {
                                Image(systemName: "list.bullet")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            
                            Spacer() // Empuja los botones hacia los extremos
                            
                            // Botón del menú lateral derecho
                            Button(action: {
                                withAnimation {
                                    showRightMenu.toggle()
                                }
                            }) {
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                        
                        // Contenido principal
                        VStack {
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
                    
                    // Menú lateral
                    if showMenu {
                        SideMenuView()
                            .frame(maxWidth: .infinity) // Ajusta el ancho del menú
                            .transition(.move(edge: .leading)) // Transición desde el borde izquierdo
                            .zIndex(1)
                    }
                    // Menú lateral derecho
                                   if showRightMenu {
                                       SideMenuView()
                                           .frame(maxWidth: .infinity ) // Ajusta el ancho del menú
                                           .transition(.move(edge: .trailing)) // Transición desde el borde derecho
                                           .zIndex(1)
                                           .alignmentGuide(.trailing) { _ in 0 } // Alinear al borde derecho
                                   }
                }
            }
        }
    }

struct SideMenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Spacer() // Este espacio empuja el contenido hacia abajo
            
          
                MyTableView()
            
            
            Spacer() // Esto empuja el contenido restante hacia el fondo
        }
        .frame(maxWidth: .infinity) // Ocupa todo el ancho horizontal
        .background(
            BlurView(style: .systemMaterialLight)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .offset(y: 60) // Ajusta el desplazamiento vertical para que comience debajo del botón
        .edgesIgnoringSafeArea(.horizontal)
    }
}


struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct Component: Identifiable {
    let id = UUID()
    let name: String
    let kanbanNumber: String
    let lotSize: Int
}

struct FinishGood: Identifiable {
    let id = UUID()
    let name: String
    let status: Int
    let components: [Component]
}

struct MyTableView: View {
    let finishGoods: [FinishGood] = [
        FinishGood(name: "Finish Good 1", status: 1, components: [
            Component(name: "Component 1A", kanbanNumber: "KB001", lotSize: 50),
            Component(name: "Component 1B", kanbanNumber: "KB002", lotSize: 100)
        ]),
        FinishGood(name: "Finish Good 2", status: 2, components: [
            Component(name: "Component 2A", kanbanNumber: "KB003", lotSize: 75),
            Component(name: "Component 2B", kanbanNumber: "KB004", lotSize: 150)
        ]),
        FinishGood(name: "Finish Good 3", status: 3, components: [
            Component(name: "Component 3A", kanbanNumber: "KB005", lotSize: 200),
            Component(name: "Component 3B", kanbanNumber: "KB006", lotSize: 300)
        ]),
        FinishGood(name: "Finish Good 4", status: 4, components: [
            Component(name: "Component 4A", kanbanNumber: "KB007", lotSize: 250),
            Component(name: "Component 4B", kanbanNumber: "KB008", lotSize: 350)
        ])
    ]
    var body: some View {
        List {
            ForEach(finishGoods) { finishGood in
                Section(header: HStack {
                    Text(finishGood.name)
                        .font(.headline) // Tamaño de letra para el nombre del Finish Good
                        .padding()
                    Spacer()
                    Circle()
                        .fill(statusColor(for: finishGood.status))
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                }
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding(.vertical, 5)
                ) {
                    ForEach(finishGood.components) { component in
                        HStack {
                            Text(component.name)
                                .font(.subheadline) // Tamaño de letra para el nombre del componente
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Kanban: \(component.kanbanNumber)")
                                .font(.footnote) // Tamaño de letra para el número de kanban
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Lot Size: \(component.lotSize)")
                                .font(.footnote) // Tamaño de letra para el tamaño del lote
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle()) // Estilo agrupado para la lista
        .navigationTitle("Finish Goods and Components")
        
    }
    func statusColor(for status: Int) -> Color {
        switch status {
        case 1:
            return .green
        case 2:
            return .yellow
        case 3:
            return .orange
        case 4:
            return .red
        default:
            return .gray
        }
    }
}



struct CameraAndDocumentView: View {
    @Environment(\.presentationMode) var presentationMode // Para controlar la navegación
    @State private var recognizedText = ""
    @State private var inputImage: UIImage?
    @State private var showImagePicker = false
    @State private var showDocumentCamera = false
    @State private var showAlert = false
    @State private var showTextDetail = false
    
    var body: some View {
        VStack(spacing: 20) { // Añadir espacio entre los elementos
            // Imagen en la parte superior
            Image("118_w1280")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 15) // Ajusta la altura según sea necesario
                .clipped()
            
            // Botón "Back" justo debajo de la imagen
            HStack {
                Button(action: {
                    // Acción del botón "Back"
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left") // Icono de "Back"
                        Text("Back")
                    }
                    .foregroundColor(.blue) // Color del texto y del icono
                    .padding()
            
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                Spacer() // Empuja el botón hacia la izquierda
            }
            .padding(.leading)
            
            // Logo y texto de TrackTrek
            VStack(spacing: 0) {
                Image("LOGO")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 55)
                
                Text("TrackTrek")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 0) // Añadir un poco de espacio superior
            
            Spacer() // Espacio flexible para el contenido restante
            
            // Botones de acción
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
            .padding(.horizontal) // Añadir padding horizontal para los botones
            
            Spacer() // Espacio flexible para el contenido restante
            
            // Texto reconocido
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
            
            Button(action: {
                showTextDetail.toggle()
            }) {
                Text(recognizedText.isEmpty ? "No text detected" : recognizedText)
                    .padding()
                    .background(Color.gray.opacity(0.2)) // Fondo para que se vea mejor el texto
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .center) // Centrar el texto
            }
            .sheet(isPresented: $showTextDetail) {
                TextDetailView(recognizedText: $recognizedText)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Alinear todo el contenido en la parte superior izquierda
        .background(Color.white.edgesIgnoringSafeArea(.all))
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
        .navigationBarHidden(true)
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
struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2 ()
    }
}
