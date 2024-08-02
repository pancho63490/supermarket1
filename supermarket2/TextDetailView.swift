import SwiftUI

struct TextDetailView: View {
    @Binding var recognizedText: String

    var body: some View {
        VStack {
            ScrollView {
                Text(recognizedText)
                    .padding()
            }
            .navigationBarTitle("Detected Text", displayMode: .inline)
        }
        .padding()
    }
}
