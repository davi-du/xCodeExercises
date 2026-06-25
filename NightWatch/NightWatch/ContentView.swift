//
//  ContentView.swift
//  NightWatch
//
//  Created by Davide Cidu on 22/06/2026.
//

import SwiftUI

struct ContentView: View {
    @Bindable var nightWatchViewModel: NightWatchViewModel
    @State private var focusModeOn = false
    @State private var resetAlertShowing = false
    
    var body: some View {
        NavigationStack{
            List{
                Section(content: {
                    ForEach($nightWatchViewModel.nightlyTasks){
                        task in
                        if focusModeOn == false || (focusModeOn && task.wrappedValue.isCompleted == false){
                            NavigationLink{
                                DetailView(task: task)
                            } label: {
                                TaskRow(task: task.wrappedValue)
                            }
                        } else {
                            EmptyView()
                        }
                    }
                    .onDelete{ indexSet in
                        nightWatchViewModel.nightlyTasks.remove(atOffsets: indexSet)
                    }
                    .onMove{indices, newOffset in
                        nightWatchViewModel.nightlyTasks.move(fromOffsets: indices, toOffset: newOffset)
                    }
                },
                        header: {
                    TaskSectionHeader(symbolSystemName: "moon.stars", headerText: "Nightly Tasks")
                })
                
                
                Section(content: {
                    ForEach($nightWatchViewModel.weeklyTasks){
                        task in
                        if focusModeOn == false || (focusModeOn && task.wrappedValue.isCompleted == false){
                            NavigationLink{
                                DetailView(task: task)
                            } label: {
                                TaskRow(task: task.wrappedValue)
                            }
                        } else {
                            EmptyView()
                        }
                    }
                    .onDelete{ indexSet in
                        nightWatchViewModel.weeklyTasks.remove(atOffsets: indexSet)
                    }
                    .onMove{indices, newOffset in
                        nightWatchViewModel.weeklyTasks.move(fromOffsets: indices, toOffset: newOffset)
                    }
                },
                        header: {
                    TaskSectionHeader(symbolSystemName: "sunset", headerText: "Weekly Tasks")
                })
                
                
                Section(content: {
                    ForEach($nightWatchViewModel.monthlyTasks){
                        task in
                        if focusModeOn == false || (focusModeOn && task.wrappedValue.isCompleted == false){
                            NavigationLink{
                                DetailView(task: task)
                            } label: {
                                TaskRow(task: task.wrappedValue)
                            }
                        } else {
                            EmptyView()
                        }
                    }
                    .onDelete{ indexSet in
                        nightWatchViewModel.monthlyTasks.remove(atOffsets: indexSet)
                    }
                    .onMove{indices, newOffset in
                        nightWatchViewModel.monthlyTasks.move(fromOffsets: indices, toOffset: newOffset)
                    }
                },
                        header: {
                    TaskSectionHeader(symbolSystemName: "calendar", headerText: "Monthly Tasks")
                })
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Home")
            .toolbar{
                ToolbarItem(placement: .bottomBar) {
                    Toggle(isOn: $focusModeOn, label: {
                        Text("Focus mode")
                    })
                    .toggleStyle(.switch)
                    .frame(width: 175)
                }
                
                ToolbarItem(placement: .topBarLeading){
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        resetAlertShowing = true
                    }, label: {
                        Text("Reset")
                    })
                }
            }
        }
        .alert("Reset list", isPresented: $resetAlertShowing){
            Button(role: .cancel){
                
            } label: {
                Text("Cancel")
            }
            
            Button(role: .destructive){
                let refreshedNightWatchViewModel = NightWatchViewModel()
                self.nightWatchViewModel.nightlyTasks = refreshedNightWatchViewModel.nightlyTasks
                self.nightWatchViewModel.weeklyTasks = refreshedNightWatchViewModel.weeklyTasks
                self.nightWatchViewModel.monthlyTasks = refreshedNightWatchViewModel.monthlyTasks
            } label: {
                Text("Yes, reset it")
            }
        } message: {
            Text("Are you sure?")
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

struct TaskRow: View {
    let task: NightWatchTask
    
    var body: some View {
        VStack {
            if task.isCompleted {
                HStack{
                    Image(systemName: "checkmark.square")
                    Text(task.name)
                        .foregroundStyle(.gray)
                        .strikethrough()
                }
            } else {
                HStack{
                    Image(systemName: "square")
                    Text(task.name)
                }
            }
        }
    }
}



#Preview {
    ContentView(nightWatchViewModel: NightWatchViewModel())
}

#Preview("ContentView Landscape",
         traits: .landscapeRight,
         body: {
    ContentView(nightWatchViewModel: NightWatchViewModel())
})

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(nightWatchViewModel: NightWatchViewModel())
    }
}

#Preview("Task Row", body: {
    TaskRow(task: NightWatchTask(name: "Check all the windows", isCompleted: true))
    TaskRow(task: NightWatchTask(name: "Check all the windows", isCompleted: false))
})
