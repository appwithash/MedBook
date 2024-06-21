//
//  LoaderManager.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import IHProgressHUD
class LoaderManager: ObservableObject {
    @Published var isBlurViewPresented = false
    @Published var isPopupPresented = false
    

    func blur(_ status: String? = nil) {
        DispatchQueue.main.async {
            self.isBlurViewPresented = true
            if let status = status {
                IHProgressHUD.show(withStatus: status)
            }
        }
    }
    
    func hideBlur() {
        DispatchQueue.main.async {
            self.isBlurViewPresented = false
            IHProgressHUD.dismiss()
        }
    }
    
    func dismissPopupAndBlur() {
        DispatchQueue.main.async {
            self.isPopupPresented = false
            self.isBlurViewPresented = false
            IHProgressHUD.dismiss()
        }
    }
}

