//
//  TextFieldView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct TextFieldView : View {
    var label : TitleStrings? = nil
    var placeholder : TitleStrings
    @Binding var text : String
    @State var isSecureField : Bool
    @FocusState var inFocus : Bool
    @State var showPassword = false
    @Binding var error : ErrorStrings?
    @Binding var isFocused : Bool
    var rightImage : String? = nil
    var borderColor : Color{
        return inFocus ? Color.blue : Color(.systemGray4)
    }
   
    var body: some View {
        VStack(alignment: .leading,spacing: 5){
            if let label = label {
                Text(label.localized)
                    .foregroundColor(Color.gray)
                    .padding(.top, 10)
                
            }
            
            HStack(spacing:20) {
                VStack(alignment: .leading) {
                    
                    if isSecureField == false{
                        TextField(placeholder.localized, text: $text)
                            .focused($inFocus)
                            .keyboardType(.alphabet)
                            .autocorrectionDisabled()
                    } else {
                        if showPassword{
                            TextField(placeholder.localized, text: $text)
                                .focused($inFocus)
                                .keyboardType(.alphabet)
                                .autocorrectionDisabled()
                        }else{
                            SecureField(placeholder.localized, text: $text)
                                .focused($inFocus)
                        }
                       
                    }
                }
                
                Spacer()
                if self.isSecureField == true{
                    Image(systemName: self.showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.showPassword.toggle()
                        }
                }
                
                if let rightImage = rightImage, isFocused == true, self.text.isEmpty == false{
                    Image(systemName: rightImage)
                        .font(.system(size: 12))
                        .foregroundStyle(borderColor)
                        .onTapGesture {
                            self.text = ""
                        }
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .onChange(of: self.inFocus){newValue in
                self.isFocused = newValue
            }
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(borderColor,lineWidth: 1))
            
            if let error = error {
                Text(error.localized)
                    .foregroundColor(Color.red)
                    .font(.system(size: 14))
            }
           
        }
       
       
    }
}
