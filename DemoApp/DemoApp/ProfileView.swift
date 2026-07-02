//
//  ProfileView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ProfileView: View {
    
    let costumer: CostumerProfile
    
    var body: some View {
        VStack{
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 100))
                .padding(.top)
            Spacer()
                .frame(height: 30)
            
            Text(costumer.fullName)
            Text(costumer.birthdate.formatted(date: .numeric, time: .omitted))
            Text(costumer.email)
            Text(costumer.phone)
            Text(costumer.costumerCode)
            Text(costumer.address)
        }
        .padding()
    }
}

#Preview {
    ProfileView(costumer:
        CostumerProfile(
            firstName: "Antonio",
            secondName: "Bianchi",
            birthdate: {
                let isoDate = "1987-04-14T10:44:00+0000"
                let dateFormatter = ISO8601DateFormatter()
                return dateFormatter.date(from: isoDate)!
            }(),
            email: "antoniobianchi@avanade.com",
            phone: "+39 xxxxxxxxxx",
            costumerCode: "ba1324",
            iban: "ITXXXXXXXXXXXXXXXXXXXXXXXXX",
            address: "Via Roma, 14, 00185 Roma RM, Italia",
            accountBalance: 999.99
        )
    )
}
