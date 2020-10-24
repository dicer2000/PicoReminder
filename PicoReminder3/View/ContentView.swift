//
//  ContentView.swift
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

struct ContentView: View {

    @State var isActive:Bool = false

    var body: some View {
        
        VStack {
        if !self.isActive {

            Text("Pico Reminder")
                .font(Font.largeTitle)
            Text("~Brett Huffman~")
                .font(Font.title)
            Text("CS 5222 - Project 2")
                .font(Font.title)
            
        } else {

    /* Fetch way of getting data.  Not using
     //    @Environment(\.managedObjectContext) private var viewContext
     @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    */
            
            // Setup a nav view
            NavigationView {
                Home()
                    .navigationBarTitle("Pico Reminder", displayMode: .inline)
                    .navigationBarTitleDisplayMode(.inline)
                    .background(NavigationConfigurator { nc in
                                    nc.navigationBar.barTintColor = .blue
                                    nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
                                })
                    
            }
        }
    }
    .onAppear {
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            //
            withAnimation {
                self.isActive = true
            }
        }
    }
    }
}
    
struct Home : View {
        
    @StateObject var model = dataModel()

    var body: some View {
        

        VStack {
            GeometryReader { geometry in

            List {
                ForEach(model.data,id: \.objectID) { obj in
                    
                    HStack() {

                        // If completed item, show this view
                        if(model.getComplete(obj: obj)) {
                            Button(action: {}, label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 34.0))
                                    .foregroundColor(.blue)
                            })
                            Text(model.getTitle(obj: obj))
                                .font(.system(size: 20.0))
                                .strikethrough(true)
                                .frame(width: geometry.size.width-180, alignment: .leading)
                        }
                        else {  // If NOT completed item, show this
                            Button(action: {}, label: {
                                Image(systemName: "circle")
                                    .font(.system(size: 34.0))
                                    .foregroundColor(.blue)
                            })
                            .onTapGesture { model.setComplete(completeObj: obj) }
                            
                            Text(model.getTitle(obj: obj))
                            .font(.system(size: 20.0))
                                .frame(width: geometry.size.width-180, alignment: .leading)
                                .onTapGesture { model.openUpdateView(obj: obj) }
                        }
                        
                        if model.getTaskHasDate(obj: obj) {
                            VStack() {
                                Text(model.getDate(obj: obj), formatter: superShortDate)
                                Text(model.getDate(obj: obj), formatter: superShortTime)
                            }
                            .frame(width: 60, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .onTapGesture { if !model.getComplete(obj: obj) { model.openUpdateView(obj: obj)} }
                        }
                        
                    }
                    

                    
    //                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: model.deleteData(IndexSet:))
            }
            }
            
            HStack(spacing: 15) {
                TextField("New Reminder", text: $model.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: model.createData, label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30.0))
                })
                .disabled(model.title.count == 0)
            }
            .padding()
            .background(Color.orange.opacity(0.2))
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $model.isUpdate) {
            // Update the view
            UpdateView(model: model)
            
        }
    }
}






private let superShortDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
}()
private let superShortTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext,persistentContainer.viewContext)
    }
}



struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}
