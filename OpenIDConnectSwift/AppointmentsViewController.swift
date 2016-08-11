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

class AppointmentsViewController: UITableViewController {
    var currentAppointments:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentAppointments = appointmentData
        if currentAppointments.count < 1 {
            let empty: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            empty.text = "No appointments available"
            empty.font = empty.font.fontWithSize(25)
            empty.textColor = UIColor(red: 154.0/255.0, green: 157.0/255.0, blue: 156.0/255.0, alpha: 1.0)
            empty.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
            empty.textAlignment = NSTextAlignment.Center
            self.tableView.backgroundView = empty
        }
        self.refreshControl?.addTarget(self, action: #selector(AppointmentsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject) {
        loadAppointments() {
            response, err in
            appointmentData = response!
            self.currentAppointments = appointmentData
            if self.currentAppointments.count < 1 {
                let empty: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
                empty.text = "No appointments available"
                empty.font = empty.font.fontWithSize(25)
                empty.textColor = UIColor(red: 154.0/255.0, green: 157.0/255.0, blue: 156.0/255.0, alpha: 1.0)
                empty.backgroundColor = UIColor.groupTableViewBackgroundColor()
                empty.textAlignment = NSTextAlignment.Center
                self.tableView.backgroundView = empty
            } else {
                self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            }

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentAppointments.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("appointmentCell", forIndexPath: indexPath)
        let appointment = currentAppointments[indexPath.row] as NSDictionary
        if let pictureLabel = cell.viewWithTag(99) as? UIImageView {
            pictureLabel.layer.cornerRadius = pictureLabel.frame.size.height / 2
            pictureLabel.layer.cornerRadius = pictureLabel.frame.size.width / 2

            pictureLabel.layer.masksToBounds = false
            pictureLabel.clipsToBounds = true

            pictureLabel.image = UIImage(named: "\(appointment["providerId"]!)")
            if let status = appointment["status"] as? String! {
                if status == "REQUESTED" {
                    pictureLabel.layer.borderColor = UIColor.yellowColor().CGColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = "PENDING APPROVAL"
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.grayColor()
                        }
                    }
                } else if status == "CONFIRMED" {
                    pictureLabel.layer.borderColor = UIColor.greenColor().CGColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = "CONFIRMED"
                    }
                } else if status == "DENIED" {
                    pictureLabel.layer.borderColor = UIColor.redColor().CGColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = "NOT APPROVED"
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.grayColor()
                        }
                    }
                } else {
                    pictureLabel.layer.borderColor = UIColor.blackColor().CGColor
                    pictureLabel.layer.borderWidth = 2.0
                    if let statusLabel = cell.viewWithTag(103) as? UILabel {
                        statusLabel.text = ""
                        if let timeLabel = cell.viewWithTag(101) as? UILabel {
                            timeLabel.textColor = UIColor.grayColor()
                        }
                    }
                }
            }
        }
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            if let name = getPhysician("\(appointment["providerId"]!)") {
                titleLabel.text = name
            }
        }
        
        // Format Date
        let startDate = appointment["startTime"] as? String!
        let endDate = appointment["endTime"] as? String!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDate = dateFormatter.dateFromString(startDate!)
        let endFormattedDate = dateFormatter.dateFromString(endDate!)
        if let timeLabel = cell.viewWithTag(101) as? UILabel {
            dateFormatter.dateFormat = "hh:mm a"
            timeLabel.text = "\(dateFormatter.stringFromDate(formattedDate!)) - \(dateFormatter.stringFromDate(endFormattedDate!))"
        }
        if let dateLabel = cell.viewWithTag(102) as? UILabel {
            dateFormatter.dateFormat = "EEE MMM dd"
            dateLabel.text = dateFormatter.stringFromDate(formattedDate!)
        }

        return cell
    }
}
