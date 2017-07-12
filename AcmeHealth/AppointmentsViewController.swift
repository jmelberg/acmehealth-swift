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
import OktaAuth

class AppointmentsViewController: UITableViewController {
    
    var currentAppointments:[NSDictionary] = []
    
    /** UILabel for "No Appointments */
    let empty: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Redirect back to login if not authenticated */
        if let authenticated = OktaAuth.tokens?.get(forKey: "accessToken") {
            if authenticated == "" {
                navigationController?.popToRootViewController(animated: true)
            }
        }
        self.refreshControl?.addTarget(
            self,
            action: #selector(self.refresh(_:)),
            for: UIControlEvents.valueChanged)
    }
    
    /** Refresh the tableView to show updated data */
 func refresh(_ sender: AnyObject) {
        loadAppointments(token: (OktaAuth.tokens?.get(forKey: "accessToken"))!, id: user.id) {
            response, err in
            appointmentData = response!
            self.currentAppointments = appointmentData
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.refresh("" as AnyObject)
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /** Creates custom view if NO Appointments */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentAppointments.count == 0 {
            empty.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)
            empty.text = "No appointments available"
            empty.font = empty.font.withSize(25)
            empty.textColor = UIColor(red: 154.0/255.0, green: 157.0/255.0, blue: 156.0/255.0, alpha: 1.0)
            empty.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
            empty.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = empty
            return 0
        } else {
            self.tableView.backgroundColor = UIColor.groupTableViewBackground
            empty.text = ""
            self.tableView.backgroundView = empty;
            return currentAppointments.count

        }
    }

    /** Format cell with provider image, name, status, and time */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath)
        let appointment = currentAppointments[indexPath.row] as NSDictionary
        if let pictureLabel = cell.viewWithTag(99) as? UIImageView {
            pictureLabel.layer.cornerRadius = pictureLabel.frame.size.height / 2
            pictureLabel.layer.cornerRadius = pictureLabel.frame.size.width / 2

            pictureLabel.layer.masksToBounds = false
            pictureLabel.clipsToBounds = true
            
            pictureLabel.image = loadProviderImage(name: getPhysician(id: "\(appointment["providerId"]!)")!)
            
            if let status = appointment["status"] as? String! {
                if status == "REQUESTED" {
                    pictureLabel.layer.borderColor = UIColor.yellow.cgColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = "PENDING APPROVAL"
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.gray
                        }
                    }
                } else if status == "CONFIRMED" {
                    pictureLabel.layer.borderColor = UIColor.green.cgColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = "CONFIRMED"
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.red
                        }
                    }
                } else if status == "DENIED" {
                    pictureLabel.layer.borderColor = UIColor.red.cgColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = "NOT APPROVED"
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.gray
                        }
                    }
                } else {
                    pictureLabel.layer.borderColor = UIColor.black.cgColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = ""
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.gray
                        }
                    }
                }
            }
        }
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            if let name = getPhysician(id: "\(appointment["providerId"]!)") {
                titleLabel.text = name
            }
        }
        
        /** Format Date */
        let startDate = appointment["startTime"] as? String!
        let endDate = appointment["endTime"] as? String!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDate = dateFormatter.date(from: startDate!)
        let endFormattedDate = dateFormatter.date(from: endDate!)
        if let timeLabel = cell.viewWithTag(101) as? UILabel {
            dateFormatter.dateFormat = "hh:mm a"
            timeLabel.text = "\(dateFormatter.string(from: formattedDate!)) - \(dateFormatter.string(from: endFormattedDate!))"
        }
        if let dateLabel = cell.viewWithTag(102) as? UILabel {
            dateFormatter.dateFormat = "EEE MMM dd"
            dateLabel.text = dateFormatter.string(from: formattedDate!)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /** Delete an appointment */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let appointment = currentAppointments[indexPath.row] as NSDictionary
            
            let accessToken = OktaAuth.tokens?.get(forKey: "accessToken")
            removeAppointment(token: accessToken!, id: "\(appointment["$loki"]!)") {
                response, err in
                print(response!)
                self.refresh(self)
            }
        }
    }
}
