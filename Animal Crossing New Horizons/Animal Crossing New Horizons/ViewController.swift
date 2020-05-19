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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createVillagers()
        todaysMessage(date: "20200518")
    }
    
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
//                        guard let names = newVillager.villager_key else { return }
//                        print(names)
                        self.villagers!.append(newVillager)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
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
                    guard let message = todaysMessageFromJSON.message,
                        let events = todaysMessageFromJSON.events,
                        let imageURL = todaysMessageFromJSON.villager_images?.first else { return }
                    var eventString: String = "\n"
                    for event in events {
                        eventString.append("-" + event + "\n")
                    }
                    self.todaysMessageLabel.text = "\(message) \(eventString)"
                    self.loadImage(url: URL(string: imageURL)!)
                } catch {
                    print(error.localizedDescription)
                    
                    }
                }
            }
        }.resume()
    }
    
    func loadImage(url: URL) {
        DispatchQueue.main.async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.villagerImage.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func changeDateButtonTapped(_ sender: Any) {
        let todaysDate = Date()
        let selectedDate = datePicker.date
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: selectedDate)
        let formattedTodaysDate = format.string(from: todaysDate)
        print(formattedDate)
        
        todaysMessage(date: formattedDate)
        
        if formattedTodaysDate != formattedDate {
            format.dateFormat = "MMM dd, yyyy"
            let prettyFormattedDate = format.string(from: selectedDate)
            todaysMessageTitleLabel.text = "\(prettyFormattedDate)"
            
        }
    }
}
