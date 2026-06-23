//
//  DetailView.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//
import SwiftUI

struct DetailView: View {
    var taskName: String
    
    var body: some View {
        VStack{
            Text(taskName)
            Text("Placeholder for description")
            Text("Placeholder for complete button")
        }
    }
}

#Preview {
    DetailView(taskName: "Check all windows")
}
