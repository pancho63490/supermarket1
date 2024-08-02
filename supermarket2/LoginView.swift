import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: Color
    var backgroundColor: Color
    var isSecure: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor.opacity(0.7)) // Ajusta la opacidad del placeholder
                    .padding(.leading, 15)
                    .font(.system(size: 18, weight: .regular, design: .default)) // San Francisco font
            }
            if isSecure {
                SecureField("", text: $text)
                    .padding()
                    .background(backgroundColor)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.system(size: 18, weight: .regular, design: .default)) // San Francisco font
            } else {
                TextField("", text: $text)
                    .padding()
                    .background(backgroundColor)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.system(size: 18, weight: .regular, design: .default)) // San Francisco font
            }
        }
        .padding(.bottom, 20)
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    Image("118_w1280")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 10)
                        .clipped()
                    
                    HStack {
                        Image("LOGO")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 55)
                    }
                    
                    Text("TrackTrek")
                        .font(.system(size: 20, weight: .regular, design: .default)) // San Francisco font
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding(.bottom, 30)
                    
                    Spacer()
                    
                    Text("Login")
                        .font(.system(size: 20, weight: .regular, design: .default)) // San Francisco font
                        .padding()
                    
                    CustomTextField(
                        text: $username,
                        placeholder: "Username",
                        placeholderColor: .black, // Color de placeholder estándar
                        backgroundColor: Color.gray.opacity(0.3), // Fondo blanco con opacidad
                        isSecure: false
                    )
                    
                    CustomTextField(
                        text: $password,
                        placeholder: "Password",
                        placeholderColor: .black, // Color de placeholder estándar
                        backgroundColor: Color.gray.opacity(0.3), // Fondo blanco con opacidad
                        isSecure: true
                    )
                    
                    Button(action: {
                        // La lógica para iniciar sesión siempre es exitosa mientras implementas la lógica de autenticación real
                        UIApplication.shared.endEditing()
                        self.isLoggedIn = true
                    }) {
                        Text("Login")
                            .font(.system(size: 20, weight: .regular, design: .default)) // San Francisco font
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 50)
                }
                .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoggedIn = false

    static var previews: some View {
        LoginView(isLoggedIn: $isLoggedIn)
    }
}
