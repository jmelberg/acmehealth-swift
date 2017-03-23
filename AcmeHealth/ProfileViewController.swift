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

class ProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var physicianName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var providerPicker: UIPickerView!
    
    var pickerHidden = true
    var submitHidden = true
    
    @IBAction func editProfile(sender: AnyObject) {
        submitHidden = false
        // NOT IMPLEMENTED
        toggleSubmit()
        tabBarController?.selectedIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("User: \(user.firstName) \(user.lastName)")
        profileName.text = "\(user.firstName) \(user.lastName)"
        profileEmail.text = "\(user.email)"
        providerName.text = "\(user.provider)"
        
        /** Load image */
        if let url = URL(string: user.picture){
            if let data = try? Data(contentsOf: url) {
                profileImage.image = UIImage(data: data)
            }
        } else {
            profileImage.image = UIImage(named: "acme-logo")
        }
        
        /** Format img */
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
        
        if let currentPhysician = user.physician {
            physicianName.text = "\(currentPhysician)"
        } else {
            physicianName.text = "Please Select Physician"
        }
        
        self.providerPicker.dataSource = self
        self.providerPicker.delegate = self
        self.tableView.reloadData()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 0 {
            togglePicker()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if pickerHidden && indexPath.section == 2 && indexPath.row == 1 {
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func togglePicker() {
        pickerHidden = !pickerHidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleSubmit() {
        submitHidden = !submitHidden
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
        physicianName.text = physicians[row]["name"] as? String
    }
}
