//
//  AuthenticationViewModel.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import Combine

class AuthenticationViewModel : ObservableObject{
    
    @Published var email : String = ""
    @Published var countryList : [String : CountryDataModel] = [:]
    @Published var selectedCountry = CountryDataModel(country: "India", region: "Asia")
    @Published var emailError : String? = nil
    @Published var password : String = ""
    @Published var passwordError : String? = nil
    private var cancellable = Set<AnyCancellable>()

    
    init() {
        self.getCountryList()
        
        $email  
            .receive(on: RunLoop.main)
            .sink(receiveValue: { passphrase in
                self.emailError = nil
            })
            .store(in: &cancellable)
        
        $password
            .receive(on: RunLoop.main)
            .sink(receiveValue: { passphrase in
                self.passwordError = nil
            })
            .store(in: &cancellable)
    }
    func getCountryList(){
        Task{
            do{
                let countryList: CountryResponseDataModel = try await NetworkManager.shared.fetchData(with: .country_list)
                DispatchQueue.main.async {
                    self.countryList = countryList.data
                }
            }catch let err{
                print("error fetching countries",String(describing: err))
            }
        }
    }
}
