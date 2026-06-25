//
//  DetailView.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//
import SwiftUI

struct DetailView: View {
    @Binding var task: NightWatchTask
    
    var body: some View {
        VStack{
            Text(task.name)
            Image("FloorPlan")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Button(action: {
                task.isCompleted = true
            }, label: {
                Text("Mark Complete")
            })
            
        }
    }
}

#Preview {
    DetailView(task: .constant(NightWatchTask(name: "Check all windows", isCompleted: false)))
}
