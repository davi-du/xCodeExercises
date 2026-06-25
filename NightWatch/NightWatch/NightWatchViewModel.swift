//
//  NightWatchViewModel.swift
//  NightWatch
//
//  Created by Davide Cidu on 24/06/2026.
//
import Foundation

@Observable
class NightWatchViewModel {
    var nightlyTasks = [
        NightWatchTask(name: "Check all the windows", isCompleted: false),
        NightWatchTask(name: "Check all the doors", isCompleted: false),
        NightWatchTask(name: "Check that the safe is locked", isCompleted: false),
        NightWatchTask(name: "Check the mailbox", isCompleted: false),
        NightWatchTask(name: "Inspect security cameras", isCompleted: false),
        NightWatchTask(name: "Clear ice from sidewalks", isCompleted: false),
        NightWatchTask(name: "Document \"strange and unusual occurrences\"", isCompleted: false)
    ]
    
    var weeklyTasks = [
        NightWatchTask(name: "Check inside all vacant rooms", isCompleted: false),
        NightWatchTask(name: "Walk the perimeter of the propriety", isCompleted: false)
    ]
    
    var monthlyTasks = [
        NightWatchTask(name: "Test security alarm", isCompleted: false),
        NightWatchTask(name: "Test motion detectors", isCompleted: false),
        NightWatchTask(name: "Test smoke alarms", isCompleted: false),
    ]
}
