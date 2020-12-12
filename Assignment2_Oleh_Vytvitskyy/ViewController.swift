//
//  ViewController.swift
//  Assignment2_Oleh_Vytvitskyy
//
//  Created by oleh on 2020-11-20.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Properties
    @IBOutlet weak var chartView: SKView!
    @IBOutlet weak var segmentProvince: UISegmentedControl!
    @IBOutlet weak var labelProvince: UILabel!
    @IBOutlet weak var labelDaily: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    
    var jsonData: [[String:Any]] = []
    var dates = [String] ()
    var values = [Int] ()
    @IBOutlet weak var pickerDate: UIPickerView!
    
    var prov : String = "Canada"
    let urlString = "http://ejd.songho.ca/ios/covid19.json"

    var startDate : Date?
    var currDate : Date?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pickerDate.delegate = self
        pickerDate.dataSource = self
                
        // get json data
        requestJson(urlString)
        
        // Present scene
        if let scene = SKScene(fileNamed: "ChartScene")
        {
            scene.scaleMode = .aspectFit
            chartView.presentScene(scene)
            
        }
        
        
       
    }
    
    
    
    // MARK: 4.
    // delegate functions for pickerview
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.dates.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dates[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // get the title of selected row
        let date = self.pickerView(pickerView, titleForRow: row, forComponent: 0) ?? ""
        
        updateView()
    }
    
    
    
    
    
    
    
    @IBAction func changeProvince(_ sender: Any)
    {
        switch (segmentProvince.selectedSegmentIndex) {
            case 0:
                labelProvince.text = "COVID-19: Canada"
                prov = "Canada"
            case 1:
                labelProvince.text = "COVID-19: Ontario"
                prov = "Ontario"
            case 2:
                labelProvince.text = "COVID-19: Quebec"
                prov = "Quebec"
            case 3:
                labelProvince.text = "COVID-19: BC"
                prov = "British Columbia"
            default:
                labelProvince.text = "COVID-19: Canada"
                prov = "Canada"
        }
        
        // I don't get why it doesn't update it..
        
        updateView()
        
    
        if let scene = chartView.scene as? ChartScene
        {
            scene.updateChart(values, startDate: self.startDate!, currDate: self.currDate!)
        }
    }
    
    
    
    // MARK: 1.
    
    func requestJson (_ urlString: String)
    {
        // create a valid URL
        
        guard let url = URL(string: urlString) else {
            self.showAlert(message: "Cannot create a URL")
            return
        }
        
        // create a session data task before request data
        
        let task = URLSession.shared.dataTask(with: url){ [self] (data,response, error) in
            // error checking
            if let error = error{
                self.showAlert(message: error.localizedDescription)
                return
            }
            guard let data = data else {
                self.showAlert(message: "Data is nil.")
                return
            }
            
            // Parse JSON Data Here
            self.parseJson(data)
            
        }
        
        task.resume()
    }
    
    
    
    // MARK: 2.
    
    func showAlert(title:String = "Error", message:String)
    {
        DispatchQueue.main.async{
            // create alert controller
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // add default button
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            // show it
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: 5.
    
    func parseJson(_ data: Data)
    {
        do
        {
            // convert root node of json to array of dictionaries
            if let json = try JSONSerialization.jsonObject(with:data,
                                                           options:[]) as? [[String:Any]]
            {
                self.jsonData = json // remember the JSON data
                //print(jsonData)  <- works
                
                // generate “dates” array for UIpickerView (see #3)
                // MARK: 3.
                var dataSet: Set<String> = []   // create a temporary set
                for dict in json                // json is array of dict.
                {
                    // find date key in the dict.
                    if let date = dict["date"] as? String {
                        dataSet.insert(date)
                    }
                }
                self.dates = dataSet.sorted()
                
                // MARK: 6.
                // allocate “values” array for line graph (see #7)
                // & generate array of daily confirmed cases
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateString = "2020-01-31"
                let firstDate = formatter.date(from: dateString) ?? Date()
                
                self.startDate = firstDate
                
                let SecPerDay : Double = 60 * 60 * 24
                //let lDate = firstDate.addingTimeInterval(SecPerDay * 316.0)
                let last = dates.last
                let lastDate = formatter.date(from: last ?? "2020-12-01")
                self.currDate = lastDate
                let sec = lastDate?.timeIntervalSince(firstDate)
                
                let dayCount = Int(sec! / SecPerDay + 0.5) + 1
                self.values = [Int] (repeating: 0, count: dayCount)
                
                //print(self.values.count) <-- confirms works
                
                // MARK: 7.
                // generate array of daily cofirmed cases
                for i in 0 ..< values.count
                {
                    let date = firstDate.addingTimeInterval(Double(i) * SecPerDay)
                    let dateStr = formatter.string(from: date)
                    
                    //find matching province
                    if let index = jsonData.firstIndex(where: { $0["prname"] as? String == self.prov &&
                                                                $0["date"] as? String == dateStr
                    })
                    {
                        // found date, put the value from JSON
                        values[i] = jsonData[index]["numtoday"] as? Int ?? 0
                    }
                    else
                    {
                        // not found = 0
                        values[i] = 0
                    }
                }
                print("Values for Canada on Dec 10: \(values[314])") // <- Dec 10 was 6739 for Canada total - works!
            }
            else
            {
                showAlert(message: "Invalid JSON format")
                return
            }
            
            DispatchQueue.main.async
            {
            
                // reload pickerView
                self.pickerDate?.reloadAllComponents()
                
                // select the latest date by default
                self.pickerDate?.selectRow(self.dates.count-1, inComponent: 0, animated: false)
                
                // Update the labels
                self.updateView()
                
            }
        }
        catch
        {
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    
    func updateView(){
        let index = self.pickerDate.selectedRow(inComponent: 0)
        let dateStr = self.pickerView(self.pickerDate, titleForRow: index, forComponent: 0) ?? ""
        
        // find matching data in JSON
        if let i = self.jsonData.firstIndex(where: { $0["prname"] as? String == self.prov &&
                                                    $0["date"] as? String == dateStr
        })
        {
            self.labelDaily.text = String(self.jsonData[i]["numtoday"] as? Int ?? 0)
            self.labelTotal.text = String(self.jsonData[i]["numtotal"] as? Int ?? 0)
        }else{
            self.labelDaily.text = "N/A"
            self.labelTotal.text = "N/A"
        }
    
    
        if let scene = chartView.scene as? ChartScene {
            scene.updateChart(values, startDate: self.startDate!, currDate: self.currDate!)
        }
    }
  
    

}

