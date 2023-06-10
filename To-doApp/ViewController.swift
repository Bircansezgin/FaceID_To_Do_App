import UIKit
import CoreData
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var savedTexts = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
   
        savedTexts = fetchItems()
        
        navigationItem.hidesBackButton = true
    }

    @IBAction func addButtonClick(_ sender: Any) {
        addButton()
    }
    
    @IBAction func lockClick(_ sender: Any) {
        exit(-1)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let text = savedTexts[indexPath.row].value(forKey: "text") as? String {
            cell.textLabel?.text = text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(at: indexPath)
        }
    }
}

extension ViewController {
    func addButton() {
        let alert = UIAlertController(title: "Add To Do List", message: "Enter", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter Here!"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Save", style: .destructive) { _ in
            if let textField = alert.textFields?.first {
                if let enteredText = textField.text {
                    self.saveText(withText: enteredText)
                }
            }
        }
        alert.addAction(cancel)
        alert.addAction(save)
        
        present(alert, animated: true)
    }
    
    func saveText(withText text: String) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: managedContext)
            
            if let trueEntity = entity {
                let newItem = NSManagedObject(entity: trueEntity, insertInto: managedContext)
                newItem.setValue(text, forKey: "text")
                savedTexts.insert(newItem, at: 0)
            }
            
            do {
                try managedContext.save()
                tableView.reloadData()
                
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            } catch let error as NSError {
                print("Veri Kaydedilemedi \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchItems() -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToDoList")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.reversed() // Verileri ters sırala
        } catch let error as NSError {
            print("Veri alınamadı: \(error), \(error.userInfo)")
            return []
        }
    }
    
    func deleteItem(at indexPath: IndexPath) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(savedTexts[indexPath.row])
            savedTexts.remove(at: indexPath.row)
            
            do {
                try managedContext.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                print("Error > \(error)")
            }
        }
    }
}
