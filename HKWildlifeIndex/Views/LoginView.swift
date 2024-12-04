
import Foundation
import SwiftUI
import UIKit
import GoogleSignInSwift
import GoogleSignIn
import os.log

//sheet view
struct LoginView : View {
    @State var animation : Bool = false
    @State var username : String = ""
    @State var password : String = ""
    @State var errorMessage : String = ""
    @State var authActive : Bool  = false
    @State var showingPrompt : Bool = false
    
    @Binding var active : Bool
    
    @EnvironmentObject var userManager : UserManager
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text("Login")
                        .frame(width: geometry.size.width)
                        .font(.title)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                        )
                        .onAppear {
                            withAnimation(.easeInOut) {
                                animation = true
                            }
                        }
                    TextField("Username", text: $username)
                        .frame(width: geometry.size.width * 0.8, alignment: .center)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 5)
                    SecureField("Password", text: $password)
                        .frame(width: geometry.size.width * 0.8, alignment: .center)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom)
                        .clipped()
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
 
                    Button {
                        Task {
                            do {
                                try await userManager.signIn(username: username, password: password)
                            } catch {
                                errorMessage = errorMessage.description
                            }
                        }
                    } label: {
                        Text("Login")
                            .foregroundStyle(.blue)
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.12)
                            .overlay { RoundedRectangle(cornerRadius: 10).fill(.clear).stroke(.blue)
                            }
                    }
                    GoogleSignInButton {
                        Task {
                            do {
                                if try await userManager.googleSignIn() {
                                    authActive = true
                                } else {
                                    showingPrompt = true
                                }
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
                    .shadow(radius: 4)
                    .frame(width: geometry.size.width * 0.5)
                    .padding(.top, 6)
                    .navigationDestination(isPresented: $showingPrompt) {
                        GoogleUsernamePromptView(activeView: $showingPrompt, active: $active)
                    }
                    .navigationDestination(isPresented: $authActive) {
                        AuthenticationView(active: $active)
                    }
                    Spacer()
                }
            }
        }
        .padding(.top)
    }
}
struct GoogleUsernamePromptView : View {
    @EnvironmentObject var userManager : UserManager
    @Binding var activeView : Bool
    @State var username : String = ""
    @Binding var active : Bool
    @State var confirmShowing : Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Text("Create a Username")
                        .font(.title2)
                        .bold()
                        .padding()
                    TextField("Username", text: $username)
                        .frame(width: geometry.size.width * 0.8, alignment: .center)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 5)
                    HStack {
                        Button {
                            userManager.signOut()
                            activeView = false
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.blue)
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.125)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8).fill(.clear).stroke(.blue)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.trailing)
                        Button {
                            if !username.isEmpty {
                                confirmShowing = true
                            }
                        } label: {
                            Text("Continue")
                                .foregroundStyle(.white)
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.125)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .navigationDestination(isPresented: $confirmShowing) {
                            AuthenticationView(active: $active, username: username)
                        }
                    }
                }
                .frame(width: geometry.size.width, alignment: .center)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
struct AuthenticationView : View {
    @EnvironmentObject var userManager : UserManager
    @Binding var active : Bool
    @State var username : String = ""
    @State var authSuccessful : Bool = false
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if authSuccessful {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                        .foregroundStyle(.green)
                    Text("Done")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.green)
                } else {
                    HStack {
                        ProgressView()
                            .controlSize(.large)
                            .padding(5)
                        Text("Verifiying...")
                            .font(.title2)
                            .foregroundStyle(Color(uiColor: .systemGray))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .task {
                do {
                    if userManager.gidUser == nil {
                        try await userManager.getGoogleHKWIUser(username: username)
                    } else {
                        try await userManager.signIn()
                    }
                    withAnimation(.easeInOut) {
                        authSuccessful = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        active = false
                        userManager.refresh()
                    }
                } catch {
                    Logger().error("\(error.localizedDescription)")
                    active = false
                }
            }
        }.navigationBarBackButtonHidden()
    }
}
