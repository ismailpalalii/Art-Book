//
//  DetailsViewController.swift
//  ArtBook
//
//  Created by ismail palali on 14.01.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callGesture()
        
        if chosenPainting != "" {
            //Core Date
            
            saveButton.isEnabled = false
            
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingUUID?.uuidString
            // isme gore filtre yapmak
            fetch.predicate = NSPredicate(format: "id = %@",idString!)
            fetch.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetch)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                           let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            }catch {
                print("error")
            }
            
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
    }
    
    func callGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gesture)
        
        imageView.isUserInteractionEnabled = true
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        view.addGestureRecognizer(imageGesture)
    }
    
    @objc func addImage() {
        //RESIM & GORSEL ALMA
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        //zoomlama icin
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Secilen gorseli alma
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // Core contex ulasmak icin tanimlama yapilir
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //veri kaydetme
        
        newPainting.setValue(artistText.text, forKey: "artist")
        newPainting.setValue(nameText.text, forKey: "name")
        if let year = Int(yearText.text!) {newPainting.setValue(year, forKey: "year")}
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.4)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        }catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
