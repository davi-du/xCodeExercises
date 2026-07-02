//
//  BankService.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import Foundation

struct BankService : Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
}


/*
 //IBAN
 HStack(alignment: .center){
     Text("IBAN: \(iban)")
         .font(.headline)
     Button {
         //action copia iban
         print("IBAN copiato")
     } label: {
         Image(systemName: "document.on.document.fill")
     }
 }.padding()
 */
