//
//  ServiceCardView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ServiceCardView: View {
    var bankService : BankService
    
    var body: some View {
        VStack{
            Image(systemName: bankService.iconName)
                .foregroundColor(.white)
                .font(.system(size: 60))
                .padding(.top)
            
            Text(bankService.title)
                .font(.title2)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(bankService.description)
                .foregroundColor(.white)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 140, height: 140)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
        )
    }
}

#Preview {
    ServiceCardView(bankService:
        BankService(
            title: "Title",
            description: "Short description of our product",
            iconName: "creditcard")
    )
}
