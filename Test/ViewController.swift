//
//  ViewController.swift
//  Test
//
//  Created by Mac2 on 11/25/16.
//  Copyright © 2016 org.cuappdev.project2. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let dataURLString = "https://api.projectoxford.ai/vision/v1.0/describe?"
    
    var currentPhoto: UIImage!
    
    //var text = "default"
    var descriptionTextView = UITextView(frame: CGRect(x: 2.0, y: 450, width: 400, height: 100))
    var confidenceTextView = UITextView(frame: CGRect(x: 350, y: 450, width: 400, height: 100))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let rightBarButton = UIBarButtonItem(title: "Camera", style: .plain, target: self, action: #selector(cameraButtonWasTapped))
        navigationItem.rightBarButtonItem = rightBarButton
        let leftBarButton = UIBarButtonItem(title: "Description", style: .plain, target: self, action: #selector(calledAPI))
        navigationItem.leftBarButtonItem = leftBarButton
        
        descriptionTextView.backgroundColor = UIColor.white
        descriptionTextView.center = CGPoint(x: view.center.x, y: view.frame.height * 0.75)
        descriptionTextView.textAlignment = .center
        descriptionTextView.isEditable = false
        //descriptionTextView.text = "Test"
        descriptionTextView.font = UIFont(name: "Helvetica", size: 20)
        view.addSubview(descriptionTextView)
        
        confidenceTextView.backgroundColor = UIColor.white
        confidenceTextView.center = CGPoint(x: view.center.x, y: view.frame.height * 0.9)
        confidenceTextView.textAlignment = .center
        confidenceTextView.isEditable = false
        confidenceTextView.font = UIFont(name: "Helvetica", size: 14)
        view.addSubview(confidenceTextView)
 
    }
    
    func calledAPI() {
        getDataFromURL { (data: Data?) in
            if let unwrappedData = data {
                if let dictionary = self.getDictionaryFromData(data: unwrappedData) {
                    if let descriptions = dictionary["description"] as? [String:Any] {
                        if let caption = descriptions["captions"] as? [[String:Any]] {
                            var imageDescription = caption[0]["text"] as? String
                            let confidenceLevel = caption[0]["confidence"] as? Double
                            imageDescription = "Description: " + imageDescription!
                            DispatchQueue.main.async {
                                self.descriptionTextView.text = imageDescription
                                var cText = String(describing: confidenceLevel!)
                                cText = "Confidence: " + cText
                                self.confidenceTextView.text = cText
                                print(confidenceLevel)
                            }
                            
                            //self.descriptionTextView.text = imageDescription
                            //self.descriptionTextView.text = "THIS IS A SUCCESS"
                            //self.text = "success"
                            //self.confidenceTextView.text = String(describing: confidenceLevel)
                            print(imageDescription)
                            
                            
                            
                            print("Inside Loop")
                            self.changeText(textInput: imageDescription!)
                        }
                    }
                    //print(dictionary)
                    print("OUTSIDE")
                }
                
            }
        }
    }
    func changeText(textInput: String) {
        //text = textInput
        //descriptionTextView.text = text
    }
    
    
    func updatePhoto() {
        if (currentPhoto) != nil {
            let photoImageView = UIImageView(frame: CGRect(x: self.view.frame.width/2.0, y: self.view.frame.height/2.0, width: 350, height: 350))
            photoImageView.center = CGPoint(x: self.view.frame.width/2.0, y: self.view.frame.height/2.0)
            
            photoImageView.image = currentPhoto
            photoImageView.clipsToBounds = true
            self.view.addSubview(photoImageView)
        }
        
    }
    
    func getDictionaryFromData(data: Data) -> [String:Any]? {
        
        if let jsonSerialization = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            if let dictionary = jsonSerialization as? [String:Any] {
                return dictionary
            }
        }
        
        
        return nil
    }

    func getDataFromURL(completion: @escaping (Data?) -> ()) {
        
        
        if let url = URL(string: dataURLString) {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("22d5c4cdb44b40a6bb36cb4445dc5771", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            urlRequest.httpMethod = "POST"
            
            let request = NSMutableURLRequest(url: url)
            request.addValue("22d5c4cdb44b40a6bb36cb4445dc5771", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            
            if (currentPhoto) != nil {
                
                let photoData = UIImageJPEGRepresentation(currentPhoto, 0.9)
                urlRequest.httpBody = photoData
               
            }
            else {
                let stringPost="{\"url\":\"http://cdn.history.com/sites/2/2015/03/hungry-history-cooking-for-the-commander-in-chief-20th-century-white-house-chefs-iStock_000004638435Medium-E.jpeg\"}" // Key and Value
                let data = stringPost.data(using: String.Encoding.utf8)
                urlRequest.httpBody = data
            }
            
            
            let session = URLSession.shared
            
            
            // with: urlRequest
            let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 200 {
                        print("success")
                        
                        completion(data)
                    } else {
                        
                        print("failed with http status code \(httpResponse.statusCode)")
                    }
                }
            })
            
            task.resume()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            /// add that image to the photos array
            currentPhoto = photo
            updatePhoto()
        }
        
        /// We need to dismiss the image picker after we have selected an image to get back to this view controller
        picker.dismiss(animated: true, completion: nil)
    }

    func cameraButtonWasTapped() {
        self.descriptionTextView.text = ""
        self.confidenceTextView.text = ""
        /// We initialize a UIImagePickerController which will display our camera or photo library
        let imagePicker = UIImagePickerController()
        /// Set the delegate to self so we can intercept the media the user picks when the controller is on screen
        imagePicker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        /// We present the image picker using a modal segue
        present(imagePicker, animated: true, completion: {
            print("Just presented the image picker")
        })
    }

}

