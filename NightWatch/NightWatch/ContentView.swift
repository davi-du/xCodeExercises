//
//  ContentView.swift
//  NightWatch
//
//  Created by Davide Cidu on 22/06/2026.
//

import SwiftUI

struct ContentView: View {
    
    let nightTasks = [
        "Check all the windows",
        "Check all the doors",
        "Check that the safe is locked",
        "Check the mailbox",
        "Inspect security cameras",
        "Clear ice from sidewalks",
        "Document \"strange and unusual occurrences\""
    ]
    
    let weeklyTasks = [
        "Check inside all vacant rooms",
        "Walk the perimeter of the propriety"
    ]
    
    let monthlyTasks = [
        "Test security alarm",
        "Test motion detectors",
        "Test smoke alarms"
    ]
    
    
    var body: some View {
        NavigationStack{
            List{
                Section(content: {
                    ForEach(nightTasks, id: \.self){
                        taskName in NavigationLink(taskName){
                            DetailView(taskName: taskName)
                        }
                    }
                },
                        header: {
                    TaskSectionHeader(symbolSystemName: "moon.stars", headerText: "Nightly Tasks")
                })
                
                
                Section(content: {
                    ForEach(weeklyTasks, id: \.self){
                        taskName in NavigationLink(taskName){
                            DetailView(taskName: taskName)
                        }
                    }
                },
                        header: {
                    TaskSectionHeader(symbolSystemName: "sunset", headerText: "Weekly Tasks")
                })
                
                
                Section(content: {
                    ForEach(monthlyTasks, id: \.self){
                        taskName in NavigationLink(taskName){
                            DetailView(taskName: taskName)
                        }
                    }
                },
                        header: {
                    TaskSectionHeader(symbolSystemName: "calendar", headerText: "Monthly Tasks")
                })
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Home")
        }
        
    }
}


//RICICLO DEL CODICE PER L'ESTETICA
//ViewModifier per riciclare estetica la usi con .modifier(NomeDellaStruct())
struct HeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundStyle(.yellow)
            .fontWeight(.heavy)
            .textCase(.uppercase)
    }
}
//extension per riciclare l'estetica la usi con .nomeDellaFunzioneEstesa
extension View{
    func headerStyle() -> some View {
        self.modifier(HeaderStyle())
    }
}

//SUBVIEWS
struct TaskSectionHeader: View {
    let symbolSystemName: String
    let headerText: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolSystemName)
            Text(headerText)
        }
        .headerStyle()
    }
}





#Preview {
    ContentView()
}

#Preview("ContentView Landscape",
         traits: .landscapeRight,
         body: {
    ContentView()
})

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
