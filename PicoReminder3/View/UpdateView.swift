//
//  UpdateView.swift
//  PicoReminder3
//
//  Created by Brett Huffman on 10/18/20.
//
//  Project 2
//  Create an app that will work like most task listing applications.
//
//  Credit to CoreData Sessions from CS 5222 and BetterProgramming website
//

import SwiftUI
import CoreData

struct UpdateView : View {
    
    @ObservedObject var model : dataModel
    
    var body : some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                HStack {
                    Text("What Do You Want To Remember?").fontWeight(Font.Weight.bold)
                }
                HStack {
                    TextField("Update", text: $model.updateTxt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack {
                    if !model.taskHasDate == true {
                        // Show only the radio button to add date
                        Button(action: model.toggleShowAddDate, label: {
                            Image(systemName: "circle")
                                .font(.system(size: 20.0))
                            Text("Add Date/Time")
                        })
                    }
                    else {
                        // Date Set -- label + Date Pickers
                        VStack {
                            Button(action: model.toggleShowAddDate, label: {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 20.0))
                                Text("Add Date/Time")
                            })
                            // Show the Date/Time Selector boxes
                            DatePicker("",selection: $model.updateTaskDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                            DatePicker("",selection: $model.updateTaskDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
                    
                }
                HStack {
                    Button(action: model.closeUpdateView) {
                        Text("Cancel")
                            .frame(width: 100 , height: 40, alignment: .center)
                    }
                    .background(Color.blue)
                     .foregroundColor(Color.white)
                     .cornerRadius(5)
                    Spacer()
                    Button(action: model.updateData) {
                        Text("Update")
                            .frame(width: 100 , height: 40, alignment: .center)
                    }
                    .background(Color.blue)
                     .foregroundColor(Color.white)
                     .cornerRadius(5)
                }
                .padding()
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.2))
        .edgesIgnoringSafeArea(.all)
    }
}
