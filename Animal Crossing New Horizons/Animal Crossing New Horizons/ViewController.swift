//
//  ViewController.swift
//  Animal Crossing New Horizons
//
//  Created by Thomas Dye on 5/18/20.
//  Copyright © 2020 Thomas Dye. All rights reserved.
//

import UIKit

struct Villager: Codable {
    var villager_key: String?
    var villager_url: String?
    var villager_api_request_url: String?
}

struct Today: Codable {
    var message: String?
    var events: [String]?
    var villager_images: [String]?
    
}

class ViewController: UIViewController {

    @IBOutlet weak var todaysMessageLabel: UILabel!
    @IBOutlet weak var villagerImage: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var todaysMessageTitleLabel: UILabel!
    
    var villagers: [Villager]? = []
    var unwrappedVillagers: [Villager] = []
    var allImageURLs: [String] = []
    var allImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createVillagers()
        setTodaysDate()
    }
    
    func setTodaysDate() {
        
        let todaysDate = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedTodaysDate = format.string(from: todaysDate)
        
        todaysMessage(date: formattedTodaysDate)
        
    }
    
    // Create Villagers
    func createVillagers() {
    
        let villagersURL = URL(string: "https://nookipedia.com/api/villager/")
        guard let unwrappedURL = villagersURL else { return }
        var request = URLRequest(url: unwrappedURL)
    
        request.addValue("9154c917-3979-4f39-9ad2-c417280c7bf6", forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { (possibleData, response, error) in
            if let data = possibleData {
                print("Villagers Data Received: \(data)")
                
                do {
                    let villagersFromJSON = try JSONDecoder().decode([Villager].self, from: data) as [Villager]
                    
                    for newVillager in villagersFromJSON {
                        self.villagers!.append(newVillager)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // Get todaysMessage for given date
    func todaysMessage(date: String) {
        
        let todaysMessageURL = URL(string: "https://nookipedia.com/api/today/\(date)/")
        guard let unwrappedURL = todaysMessageURL else { return }
        var request = URLRequest(url: unwrappedURL)
        request.addValue("9154c917-3979-4f39-9ad2-c417280c7bf6", forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { (possibleData, response, error) in
            if let data = possibleData {
                
                DispatchQueue.main.async {
                print("Today's Message Data Received: \(data)")
    
                do {
                    let todaysMessageFromJSON = try JSONDecoder().decode(Today.self, from: data) as Today
                    guard let events = todaysMessageFromJSON.events,
                        let imageURL = todaysMessageFromJSON.villager_images?.first else { return }
                    
                    // Need to use allImages for cases where more than one image returns
                    self.allImageURLs = todaysMessageFromJSON.villager_images!
                    var eventString: String = "\n"
                    for event in events {
                        eventString.append("-" + event + "\n\n")
                    }
                    self.todaysMessageLabel.text = "We have the following announcements for today:\n\(eventString)"
                    self.loadImage(url: URL(string: imageURL)!)
                } catch {
                    print(error.localizedDescription)
                    
                    }
                }
            }
        }.resume()
    }
    
    // Load image function
    func loadImage(url: URL) {
        DispatchQueue.main.async { [weak self] in
            self!.allImages = []
            for url in self!.allImageURLs {
                print("url: \(url)")
                if let data = try? Data(contentsOf: URL(string: url)!) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self!.allImages.append(image)
                            self?.villagerImage.animationImages = self?.allImages
                            self?.villagerImage.animationDuration = 2.0
                            self?.villagerImage.startAnimating()
                        }
                    }
                }
            }
        }
    }
    
    // Change date button tapped
    @IBAction func changeDateButtonTapped(_ sender: Any) {
        let todaysDate = Date()
        let selectedDate = datePicker.date
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: selectedDate)
        let formattedTodaysDate = format.string(from: todaysDate)
        print(formattedDate)
        
        // Set todays message to selected date
        todaysMessage(date: formattedDate)
        
        // If today's date is not equal to selected date
        if formattedTodaysDate != formattedDate {
            format.dateFormat = "MMM dd, yyyy"
            let formattedDateForTitle = format.string(from: selectedDate)
            todaysMessageTitleLabel.text = "\(formattedDateForTitle)"
        }
    }
}
