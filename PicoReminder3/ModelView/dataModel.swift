//
//  dataModel.swift
//  PicoReminder3
//
//  Created by Brett Huffman on 10/18/20.
//
//  Project 2
//  Create an app that will work like most task listing applications.
//
//  Credit to CoreData Sessions from CS 5222 and BetterProgramming website
//

import CoreData

// MVVM Pattern

class dataModel : ObservableObject {
    // Setup all our Observer/Publisher vars
    @Published var data : [PicoReminder3.Data] = []
    @Published var title = ""
    @Published var taskDate = Date.init()
    @Published var isUpdate = false
    @Published var updateTxt = ""
    @Published var updateTaskDate = Date.init()
    @Published var selectedObj: PicoReminder3.Data?    // Improved version :: Was NSManagedObject()
    @Published var taskHasDate = false
    
    let context = persistentContainer.viewContext
    
    init() {
        readData()
    }
    
    // Read the data from DB
    func readData() {

//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    
        let request: NSFetchRequest<PicoReminder3.Data> = PicoReminder3.Data.fetchRequest()
        do {
            let results = try context.fetch(request)
            self.data = results // as! [NSManagedObject]
        }
        catch {
            print(error.localizedDescription)
        }
    
    }
    
    // Create a new task
    func createData() {
        
        // Must have a value
        if title.count < 1 {
            return;
        }
        
        /*
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Data",
                                                         into: context)
        entity.setValue(title, forKey: "title")
        entity.setValue(UUID(), forKey: "id")
        */
        
        let entity = PicoReminder3.Data(context: context)
        entity.title = title
        entity.id = UUID()
        
        do {
            // Try a save, if successful append to entity list
            try context.save()
            self.data.append(entity)

            
            // Try to open for an edit now
            selectedObj = entity
            updateTxt = title
            isUpdate.toggle()
            
            // Clear from textbox
            title = ""
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    // Delete a task
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
    
    // Update a task
    func updateData() {
        // Update the data eleement
//        let index = data.firstIndex(of: selectedObj)
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        
        // Improved way of getting data
        guard let selected = selectedObj else { return }
        let index = data.firstIndex(of: selected)
        let request: NSFetchRequest<PicoReminder3.Data> = PicoReminder3.Data.fetchRequest()
    
        do {
            let results = try context.fetch(request) // as! [NSManagedObject]
            
            let obj = results.first { (obj) -> Bool in
                    if obj == selectedObj { return true }
                    else { return false }
                }
            
            obj?.setValue(updateTxt, forKey: "title")
            obj?.setValue(taskHasDate, forKey: "taskHasDate")
            obj?.setValue(updateTaskDate, forKey: "taskDate")
            
            try context.save()
            
            data[index!] = obj!
            isUpdate.toggle()
            updateTxt = ""
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // Get the task title from an object
    func getTitle(obj : NSManagedObject) -> String {
        let val = obj.value(forKey: "title") ?? ""
        return val as! String
    }
    
    // Open the Update View (getting all the items out of the selected object
    func openUpdateView(obj: PicoReminder3.Data) {
        selectedObj = obj
        updateTxt = getTitle(obj: obj)
        updateTaskDate = getDate(obj: obj)
        taskHasDate = getTaskHasDate(obj: obj)
        isUpdate.toggle()
    }
    
    // Close the Update View
    func closeUpdateView() {
        isUpdate.toggle()
        updateTxt = ""
    }
    
    // Get if the task is complete (passing in task object)
    func getComplete(obj : PicoReminder3.Data) -> Bool {
        let val = obj.value(forKey: "complete") ?? false
        return val as! Bool
    }
    
    // Set an item complete (passing in a task object)
    func setComplete(completeObj : PicoReminder3.Data) {
        // Update the data eleement
        let index = data.firstIndex(of: completeObj)
        
        let request: NSFetchRequest<PicoReminder3.Data> = PicoReminder3.Data.fetchRequest()
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    
        do {
            let results = try context.fetch(request) // Old: as! [NSManagedObject]
            
            let obj = results.first { (obj) -> Bool in
                if obj == completeObj { return true }
                else { return false }
            }
            
            obj?.setValue(true, forKey: "complete")
            
            try context.save()
            
            data[index!] = obj!
        }
        catch {
            print(error.localizedDescription)
        }
    }

    // Get the Task Date (passing in a task object)
    func getDate(obj : NSManagedObject) -> Date {
        let val = obj.value(forKey: "taskDate") ?? Date.init()
        return val as! Date
    }
    
    // New way of get date by just using the selectedObj
    func getDate() -> Date {
        let val = selectedObj?.value(forKey: "taskDate") ?? Date.init()
        return val as! Date
    }
    
    // Get if a Task has the Date (passing in task object)
    func getTaskHasDate(obj : NSManagedObject) -> Bool {
        let val = obj.value(forKey: "taskHasDate") ?? false
        return val as! Bool
    }

    // Toggle showing a date (for radio button)
    func toggleShowAddDate() {
        taskHasDate.toggle()
    }
    
    /*
    func toggleAddDateTime() {
        let index = data.firstIndex(of: selectedObj)
        var val = obj.value(forKey: "toggleAddDateTime") as! Bool
        val.toggle()
        taskHasDate = val
    }
    */
}
