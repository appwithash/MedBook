//
//  SignUpView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @EnvironmentObject var authVM : AuthenticationViewModel
    @Environment(\.modelContext) private var context
    
    @State private var viewModel: ViewModel
    @State private var userViewModel: UserViewModel
    
    init(modelContext: ModelContext) {
       
        _viewModel = State(initialValue:  ViewModel(modelContext: modelContext))
        _userViewModel = State(initialValue:  UserViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        GeometryReader{gr in
            ScrollView{
                VStack(alignment : .leading){
                    let welcome = Text(TitleStrings.welcome.localized)
                        .foregroundStyle(.blue)
                    Text("\(welcome)\n\(TitleStrings.signup_to_continue.localized)")
                        .font(.title)
                        .bold()
                        .padding(.top,gr.size.height*0.05)
                    TextFieldView(label: .email,placeholder: .email_placeholder, text: $authVM.email,isSecureField : false, error: $authVM.emailError, isFocused: .constant(false))
                    
                    TextFieldView(label: .password,placeholder: .new_password_placeholder, text: $authVM.password,isSecureField : true, error: $authVM.passwordError, isFocused: .constant(false))
                    VStack(alignment: .leading,spacing: 5){
                        HStack{
                            Text(TitleStrings.select_country.localized)
                                .foregroundColor(Color(.systemGray3))
                            Spacer()
                            
                            Picker("", selection: $viewModel.selectedCountry) {
                                ForEach(self.viewModel.countries){ country in
                                    Text(country.country)
                                        .tag(country)
                                    
                                }
                            }
                        }
                        .padding(.vertical,10)
                        .padding(.horizontal)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(.systemGray4),lineWidth: 1))
                        .padding(.top)
                        
                        if let error = authVM.countryError {
                            Text(error.localized)
                                .foregroundColor(Color.red)
                                .font(.system(size: 14))
                        }
                        
                    }
                    Spacer()
                    
                    Button(TitleStrings.sign_up.localized){
                        self.authVM.signUp{
                          
                            self.userViewModel.addUser(user: User(email: self.authVM.email, password: self.authVM.password)){err in
                                if err == .user_already_exist{
                                    self.authVM.emailError = err
                                }else{
                                    UserDefaultManager.shared.countryName = self.viewModel.selectedCountry.country
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
        .medNavigationBar(.sign_up)
        .navigate(using: $userViewModel.showMainView, destination: HomeScreenView(context: context))
        .onAppear{
            self.viewModel.fetchCountriesFromLocalStorage()
        }
    }
}

extension SignUpView{
    @Observable
        class ViewModel {
            var modelContext: ModelContext
            var countries = [CountryModel]()
            var selectedCountry = CountryModel(country: UserDefaultManager.shared.countryName, region: "")
            init(modelContext: ModelContext) {
                self.modelContext = modelContext
             
            }

            func addData() {
                Task{
                    do{
                        let countryList: CountryResponseDataModel = try await NetworkManager.shared.fetchData(with: .country_list)
                        DispatchQueue.main.async {[weak self] in
                            guard let self = self else { return }
                            let countryList = countryList.data
                           
                            let countries = Array(countryList.values.sorted(by: {$0.country < $1.country}))
                            for country in countries {
                                let newCountry = CountryModel(country: country.country, region: country.region)
                                modelContext.insert(newCountry)
                            }
                            fetchCountriesFromLocalStorage()
                           
                        }
                    }catch let err{
                        print("error fetching countries",String(describing: err))
                    }
                }
                
               
            }

            func fetchCountriesFromLocalStorage() {
                do {
                    let descriptor = FetchDescriptor<CountryModel>(sortBy: [SortDescriptor(\.country)])
                    countries = try modelContext.fetch(descriptor)
                    if self.countries.count == 0{
                        self.addData()
                    }else{
                       
                        if UserDefaultManager.shared.countryName == ""{
                            self.fetchDefaultCountry()
                        }else{
                            if let country = self.countries.first(where: {$0.country == UserDefaultManager.shared.countryName}){
                                self.selectedCountry = country
                            }
                        }
                       
                    }
                } catch {
                    print("Fetch failed fetchCountriesFromLocalStorage")
                }
            }
            
            func fetchDefaultCountry(){
                Task{
                    do{
                        let response : CountryDataModel = try await NetworkManager.shared.fetchData(with: .default_country)
                        DispatchQueue.main.async{
                            if let country = self.countries.first(where: {$0.country == response.country}){
                                
                                self.selectedCountry = country
                            }
                           
                        }
                    }catch let err{
                        print("error fetching countries",String(describing: err))
                    }
                }
            }
        }
}

extension SignUpView{
    @Observable
    class UserViewModel {
        var modelContext: ModelContext
        var showMainView = false
        var users : [User] = []
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            fetchUsers()
        }
        
        func fetchUsers() {
            do {
                let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.email)])
                users = try modelContext.fetch(descriptor)
                
            } catch {
                print("Fetch failed fetchCountriesFromLocalStorage")
            }
        }
        
        
        func addUser(user : User, completion : @escaping (ErrorStrings?) -> ()){
            if let databaseUser = self.users.first(where: {$0.email == user.email}){
                completion(.user_already_exist)
                return
            }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.modelContext.insert(user)
                print("Signup Success")
                UserDefaultManager.shared.currentEmail = user.email
                print("welcome!! \(user.email)")
                self.showMainView = true
                completion(nil)
            }
        }
        
        
       
    }
}
//#Preview {
//    NavigationView{
//        SignUpView(modelContext: ModelContext(ModelContainer(for: CountryModel.self)))
//            .environmentObject(AuthenticationViewModel())
//    }
//}
