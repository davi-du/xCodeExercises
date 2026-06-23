//
//  FirstSwiftUINavigationStack.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//

import SwiftUI

struct FirstSwiftUINavigationStack: View {
    var body: some View {
        NavigationStack {
            NavigationLink{
                HStack {
                    Text("Destination view")
                }
                .navigationTitle(Text("Destination"))
            } label: {
                Text("Go to destination view")
            }
            .navigationTitle(Text("Home"))
        }
    }
}

#Preview {
    FirstSwiftUINavigationStack()
}
