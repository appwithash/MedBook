//
//  Extensions.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func navigate<Destination: View>(
        using binding: Binding<Bool>,
        destination: Destination
    ) -> some View {
        background(NavigationLink( destination: destination,isActive: binding) { EmptyView() } )
    }
    
    func medNavigationBar(_ title: TitleStrings, backIcon: backButtonStyles? = .chevron_left,dismiss: (()->())? = nil) -> some View {
        modifier(MEDNavigationBar(dismiss: dismiss, heading: title.localized, backIcon: backIcon))
    }
    
}


struct MEDNavigationBar: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    var dismiss: (()->(Void))?
    var heading: String
    var backImage: String?
    
    init(dismiss: (() -> (Void))? = nil, heading: String, backIcon: backButtonStyles? = backButtonStyles.chevron_left) {
        self.dismiss = dismiss
        self.heading = heading
        self.backImage = backIcon?.rawValue
    }
    
    func body(content: Content) -> some View {
        VStack(spacing:0){
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(.systemGray5))
                .padding(.horizontal)
            
            content
                .toolbar {
                    ToolbarItem(id: TitleStrings.cancel.localized, placement: .navigationBarLeading) {
                        Button(action: dismiss ?? dismissPresentationMode) {
                            Image(systemName: backImage ?? "") 
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                        }
                    }
                }
           
        }
        .navigationBarTitle(heading, displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
    
    func dismissPresentationMode() {
        self.presentationMode.wrappedValue.dismiss()
    }
}


    
enum backButtonStyles: String {
    case xmark
    case chevron_left = "chevron.left"
    case none
}


extension String{
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var containsSpecialCharacters: Bool {
        let regex = ".*[^A-Za-z0-9 ].*"
        return self.range(of: regex, options: .regularExpression) != nil
    }
}


extension Collection where Index == Int {
    func isLastItem(_ item: Element) -> Bool {
        guard let itemIndex = firstIndex(where: { $0 as AnyObject === item as AnyObject }) else {
            return false
        }
        return itemIndex == count - 1
    }
}
