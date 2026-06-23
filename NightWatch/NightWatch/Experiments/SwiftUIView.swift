//
//  SwiftUIView.swift
//  NightWatch
//
//  Created by Davide Cidu on 22/06/2026.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/) //sarebbe come scrivere return Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/) è una singola View
            
            //VStack mi mette le textview una sotto l'altra
            VStack{
                Text("Nightly Tasks")
                Text("Weekly Tasks")
                Text("Monthly Tasks")
            }
            
            //ZStack una sopra l'altra
            ZStack{
                Rectangle()
                    .fill(Color.yellow)
                Circle()
                    .fill(Color.red)
            }.frame(width: 120, height: 120)
            
            //HStack mi mette le textview una a fianco all'altra
            HStack{
                Text("Nightly Tasks")
                Text("Weekly Tasks")
                Text("Monthly Tasks")
            }
        }
        
        //il layout container ci permette di raggruppare le view primitive
        //in questo modo questi container (Stack) visualizzano una sola view
        HStack{
            //VStack mi mette le textview una sotto l'altra
            VStack(alignment: .leading){ //alignment: .leading me li giustifica a sx
                
                Text("\(Image(systemName: "moon.stars")) Nightly Tasks")
                    .modifier(HeaderStyle())//questo è con struct
                
                Text("Check all the windows")
                Text("Check all the doors")
                Text("Check that the safe is locked")
                Text("Check the mailbox")
                Text("Inspect security cameras")
                Text("Clear ice from sidewalks")
                Text("Document \"strange and unusual occurrences\"")
                
                Text("\(Image(systemName: "sunset")) Weekly Tasks")
                    .headerStyle()  //questo è con extension e la struct
                    .padding(.top)
                Text("Check inside all vacant rooms")
                Text("Walk the perimeter of the propriety")
                
                Text("\(Image(systemName: "calendar")) Monthly Tasks")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                    .fontWeight(.heavy)
                    .textCase(.uppercase)
                    .padding(.top)
                Text("Test security alarm")
                Text("Test motion detectors")
                Text("Test smoke alarms")
                
                Spacer()
            }
            .foregroundStyle(.gray) //lo applica a tutti i child del container a meno di view con specificità maggiori
            Spacer()
        }
        .padding([.leading, .top], 10)
    }
}

#Preview {
    SwiftUIView()
}
