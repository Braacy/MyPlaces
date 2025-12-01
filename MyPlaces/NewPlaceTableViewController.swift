//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 03.11.2025.
//

import UIKit
import RealmSwift
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    var imageIsChanged = false
    var currentPlace: Place!
    var currentRainting = 0.0
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var raitingControl: RaitingControl!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setupEditScreen()
        
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.currentRainting = rating
        }
    }
// MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(imageLiteralResourceName: "camera")
            let photoIcon = UIImage(imageLiteralResourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                 message: nil,
                                                 preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
        else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    
    func savePlace() {
        let image = imageIsChanged ? placeImage.image : UIImage(imageLiteralResourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             raiting: currentRainting)
        
        if currentPlace != nil {
            try! realm.write{
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.raiting = newPlace.raiting
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    
    }

    private func setupEditScreen() {
    if currentPlace != nil {
        
        setupNavigationBar()
        imageIsChanged = true
        
        guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
        placeImage.image = image
        placeImage.contentMode = .scaleAspectFill
        
        placeName.text = currentPlace?.name
        placeLocation.text = currentPlace?.location
        placeType.text = currentPlace?.type
        cosmosView.rating = currentPlace.raiting
    }
}
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
// MARK: - Text field delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию "Done"
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
}
// MARK: - Work with image

extension NewPlaceTableViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
}
