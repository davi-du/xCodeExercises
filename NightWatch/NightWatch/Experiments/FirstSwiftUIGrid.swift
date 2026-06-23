//
//  FirstSwiftUIGrid.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//

import SwiftUI

struct FirstSwiftUIGrid: View {
    
    let nightTasks = [
        "1 Check all the windows",
        "2 Check all the doors",
        "3 Check that the safe is locked",
        "4 Check the mailbox",
        "5 Inspect security cameras",
        "6 Clear ice from sidewalks",
        "7 Document \"strange and unusual occurrences\""
    ]
    
    
    var body: some View {
        //nei LazyGrid va passato un array di GridItem per formattarle (vedi dopo)
        ScrollView(.horizontal){
            LazyHGrid(rows: [
                GridItem(.fixed(100)),
                GridItem(.fixed(100)),
                GridItem(.fixed(100))
            ]) {
                ForEach(nightTasks, id: \.self){
                    taskName in Text(taskName)
                }
            }
        }
        
        ScrollView{
            LazyVGrid(columns: [
                GridItem(.fixed(100)),
                GridItem(.fixed(100)),
                GridItem(.fixed(100))
            ]) {
                ForEach(nightTasks, id: \.self){
                    taskName in Text(taskName)
                }
            }
        }
    }
    
}

#Preview {
    FirstSwiftUIGrid()
}
