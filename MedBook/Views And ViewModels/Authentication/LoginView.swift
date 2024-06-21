//
//  LoginView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject var authVM : AuthenticationViewModel
    @Environment(\.modelContext) private var context
    
    @State private var userViewModel: UserViewModel
   
    init(modelContext: ModelContext) {
        _userViewModel = State(initialValue:  UserViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        GeometryReader{ gr in
            ScrollView{
                VStack(alignment : .leading){
                    let welcome = Text(TitleStrings.welcome.localized)
                        .foregroundStyle(.blue)
                    Text("\(welcome)\n\(TitleStrings.login_to_continue.localized)")
                        .font(.title)
                        .bold()
                        .padding(.top,gr.size.height*0.05)
                    TextFieldView(label: .email,placeholder: .email_placeholder, text: $authVM.email,isSecureField : false, error: $authVM.emailError, isFocused: .constant(false))
                    
                    TextFieldView(label: .password,placeholder: .new_password_placeholder, text: $authVM.password,isSecureField : true, error: $authVM.passwordError, isFocused: .constant(false))
                    
                    
                    Spacer()
                    
                    Button(TitleStrings.log_in.localized){
                        self.authVM.logIn{
                            self.userViewModel.login(user: User(email: self.authVM.email, password: self.authVM.password)) { err in
                                if err == .wrong_password{
                                    self.authVM.passwordError = .wrong_password
                                }else if err == .user_not_exist{
                                    self.authVM.emailError = .user_not_exist
                                }
                            }
                        }
                    }
                    .buttonStyle(.solid)
                    .padding(.top)
                    
                    
                    
                }
                .frame(minHeight: gr.size.height)
            }
        }
        .padding(.horizontal)
        .medNavigationBar(.log_in)
        .navigate(using: $userViewModel.showMainView, destination: HomeScreenView(context: context))
    }
}


extension LoginView{
    @Observable
    class UserViewModel {
        var modelContext: ModelContext
        var users : [User] = []
        var showMainView = false
       
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            self.fetchUsers()
        }
        
        func fetchUsers() {
            do {
                let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.email)])
                users = try modelContext.fetch(descriptor)
                
            } catch {
                print("Fetch failed fetchCountriesFromLocalStorage")
            }
        }
        
        func login(user : User,completion : (ErrorStrings?) -> ()){
            print("users",self.users.map{$0.email})
            if let databaseUser = self.users.first(where: {$0.email == user.email}){
                if databaseUser.password != user.password{
                    completion(.wrong_password)
                }else{
                    UserDefaultManager.shared.currentEmail = user.email
                    print("welcome!! \(user.email)")
                    self.showMainView = true
                }
                
            }else{
                completion(.user_not_exist)
            }
        }
        
       
    }
}

//#Preview {
//    NavigationStack{
//        LoginView()
//            .environmentObject(AuthenticationViewModel())
//    }
//}
