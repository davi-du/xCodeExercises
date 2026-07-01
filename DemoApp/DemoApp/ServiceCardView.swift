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
                .imageScale(.large)
            Text(bankService.title)
                .bold()
            Text(bankService.description)
        }
    }
}

#Preview {
    ServiceCardView(bankService:
        BankService(
            title: "Title",
            description: "Short description of the product",
            iconName: "creditcard")
    )
}
