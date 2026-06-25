//
//  MarkCompleteExperiment.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//

import SwiftUI

@Observable
class NightWatchTaskExperiment {
    let name: String
    var isCompleted: Bool
    var lastCompleted: Date?
    
    internal init(name: String, isCompleted: Bool, lastCompleted: Date? = nil) {
        self.name = name
        self.isCompleted = isCompleted
        self.lastCompleted = lastCompleted
    }
}

struct MarkCompleteExperiment: View {
    @State private var theTask = NightWatchTaskExperiment(name: "Check all the windows", isCompleted: false)
    
    var body: some View {
        VStack{
            HStack{
                if theTask.isCompleted {
                    Image(systemName: "checkmark.square")
                } else {
                    Image(systemName: "square")
                }
                Text(theTask.name)
            }
            //ControlPanel(theTask: self.$theTask) //serve con la struct per parlare col padre, la classe observable lo rende inutile
            ControlPanel()
                .environment(self.theTask)
        }
    }
}

struct ControlPanel: View {
    //@Binding var theTask: NightWatchTaskExperiment //serve con la struct per parlare col padre, la classe observable lo rende inutile
    @Environment(NightWatchTaskExperiment.self) var theTask
    
    
    var body: some View {
        @Bindable var theTask: NightWatchTaskExperiment = self.theTask //Bindable serve per il toggle vedi perché poi
        
        HStack{
            if theTask.isCompleted {
                Button("Reset"){
                    theTask.isCompleted = false
                }
            } else {
                Button("Mark complete"){
                    theTask.isCompleted = true
                }
            }
        }
        
        HStack{
            Toggle(isOn: $theTask.isCompleted){
                Text("Task completed")
            }
        }
    }
}

#Preview {
    MarkCompleteExperiment()
        .environment(NightWatchTaskExperiment(name: "Check all the windows", isCompleted: false))
}
