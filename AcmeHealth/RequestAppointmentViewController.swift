/** Author: Jordan Melberg **/

/** Copyright © 2016, Okta, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

class RequestAppointmentViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var doctorPicker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reasonText: UITextView!
    @IBAction func datePickerValue(sender: AnyObject) {
        datePickerChanged()
    }
    
    @IBAction func requestAppointment(sender: AnyObject) {
        if date != nil || doctorLabel != nil || reasonText != nil{
            requestAppointment()
        } else {
            print("Missing fields")
        }
        
    }
    @IBAction func exitRequest(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var datePickerHidden = true
    var pickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerChanged()
        self.doctorPicker.dataSource = self
        self.doctorPicker.delegate = self
        self.doctorLabel.text = "\(physicians[0]["name"]!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            toggleDatepicker()
        }
        if indexPath.section == 0 && indexPath.row == 0 {
            togglePicker()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if datePickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        }
        else if pickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    
    func datePickerChanged () {
        dateLabel.text = DateFormatter.localizedString(from: date.date, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.short)
    }
    
    func toggleDatepicker() {
        datePickerHidden = !datePickerHidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func togglePicker() {
        pickerHidden = !pickerHidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return physicians.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let name = physicians[row]["name"] as? String
        return name!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        doctorLabel.text = physicians[row]["name"] as? String
        togglePicker()
    }
    
        
    func formatDate(date : String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        let formattedDate = dateFormatter.date(from: date)
        
        // Convert from date to string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: formattedDate!)

    }
    
    func requestAppointment() {
        let id = getPhysicianID(name: "\(self.doctorLabel.text!)")!
        let formattedDate = formatDate(date: "\(self.date.date)")
        let params = [
            "comment" : self.reasonText.text,
            "startTime": formattedDate!,
            "providerId" : id,
            "patient" : "\(user.firstName) \(user.lastName)",
            "patientId" : user.id
            ] as [String : Any]
        
        createAppointment(params: params){
            response, error in
            print(response!)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    

}
