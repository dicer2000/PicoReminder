//
//  ContentView.swift
//  PicoReminder3
//
//  Created by Brett Huffman on 10/18/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext

    /*
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    */
    
    
    var body: some View {
        
        NavigationView {
            Home()
                .navigationBarTitle("Pico Reminder", displayMode: .inline)
                .navigationBarTitleDisplayMode(.inline)
                .background(NavigationConfigurator { nc in
                                nc.navigationBar.barTintColor = .blue
                                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
                            })
                
//                .background(Color.orange.opacity(0.2))
        }

    }
    
}
    
struct Home : View {
        
    @StateObject var model = dataModel()

    var body: some View {
        
        VStack {
            List {
                ForEach(model.data,id: \.objectID) { obj in
                    
                    HStack {
                    Text(model.getValue(obj: obj))
                    }
                        .onTapGesture { model.openUpdateView(obj: obj) }
                    
    //                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: model.deleteData(IndexSet:))
            }
            
            HStack(spacing: 15) {
                TextField("New Reminder", text: $model.txt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: model.writeData, label: {
                    Image(systemName: "plus.circle")
                })
                .disabled(model.txt.count == 0)
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

struct UpdateView : View {
    
    @ObservedObject var model : dataModel
    
    var body : some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                HStack {
                    Text("Reminder Update").fontWeight(Font.Weight.bold)
                }
                HStack {
                    TextField("Update", text: $model.updateTxt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack {
                    Button(action: model.closeUpdateView) {
                        Text("Cancel")
                    }
                    Spacer()
                    Button(action: model.updateData) {
                        Text("Update")
                    }

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

// MVVM Pattern

class dataModel : ObservableObject {
    @Published var data : [NSManagedObject] = []
    @Published var txt = ""
    @Published var isUpdate = false
    @Published var updateTxt = ""
    @Published var selectedObj = NSManagedObject()
    
    let context = persistentContainer.viewContext
    
    init() {
        readData()
    }
    
    func readData() {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    
        do {
            let results = try context.fetch(request)
            self.data = results as! [NSManagedObject]
        }
        catch {
            print(error.localizedDescription)
        }
    
    }
    
    func writeData() {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Data",
                                                         into: context)
        
        // Must have a value
        if txt.count < 1 {
            return;
        }
        entity.setValue(txt, forKey: "value")
        
        do {
            // Try a save, if successful append to entity list
            try context.save()
            self.data.append(entity)
            // Clear from textbox
            txt = ""
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    func deleteData(IndexSet : IndexSet) {
        // Deleting an item
        for index in IndexSet {
            do {
                let obj = data[index]
                context.delete(obj)
                
                try context.save()
                
                let index = data.firstIndex(of: obj)
                data.remove(at: index!)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateData() {
        // Update the data eleement
        let index = data.firstIndex(of: selectedObj)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
            
            let obj = results.first { (obj) -> Bool in
                if obj == selectedObj { return true }
                else { return false }
            }
            
            obj?.setValue(updateTxt, forKey: "value")
            
            try context.save()
            
            data[index!] = obj!
            isUpdate.toggle()
            updateTxt = ""
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func getValue(obj : NSManagedObject) -> String {
        let val = obj.value(forKey: "value") ?? ""
        return val as! String;
//        return obj.value(forKey: "value") as! String
    }
    
    func openUpdateView(obj: NSManagedObject) {
        selectedObj = obj
        updateTxt = getValue(obj: obj)
        isUpdate.toggle()
    }
    
    func closeUpdateView() {
        isUpdate.toggle()
        updateTxt = ""
    }
}




private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
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
