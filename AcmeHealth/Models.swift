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


/** Sample Data & Global Vars */
var appointmentData: [NSDictionary]!
var user: AcmeUser!
var physicians : [NSDictionary]!

/** Create new user for lifecycle of open app */
class AcmeUser {
    var firstName = "John"
    var lastName = "Smith"
    var provider = "Healthcare Cross"
    var email = "example@example.com"
    var physician: String?
    var picture = "https://randomuser.me/api/portraits/thumb/men/1.jpg"
    var id = ""
    
    func setFirst(firstName: String) {   self.firstName = firstName}
    func setLast(lastName: String) {self.lastName = lastName }
    func setProvider(provider: String) { self.provider = provider }
    func getDetails() -> String { return "\(firstName) \(lastName) \nEmail: \(email) \nPicture: \(picture)" }

    init(firstName: String, lastName:String, email: String, picture:String, id: String) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.picture = picture
        self.id = id
    }
}

/** Given physican id -> returns physician name */
func getPhysician(id: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (id == "\(physician["id"]!)") {
            return "\(physician["name"]!)"
        }
    }
    return nil
}

/** Given physican name -> returns physician id */
func getPhysicianID(name: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (name == "\(physician["name"]!)") {
            return "\(physician["id"]!)"
        }
    }
    return nil
}

/** Given physican id -> returns physician profile image url */
func getPhysicianUrl(id: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (id == "\(physician["id"]!)") {
            return "\(physician["profileImageUrl"]!)"
        }
    }
    return nil
}

/** Loads user image */
func loadImage() -> UIImage {
    if let url = URL(string: activeUser.picture) {
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)!
        }
    }
    // Return default
    return UIImage(named: "acme-logo")!
}


/** Loads provider image */
func loadProviderImage(name: String) -> UIImage {
    let urlString = getPhysicianUrl(id: getPhysicianID(name: name)!)
    if let url = URL(string: urlString!) {
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)!
        }
    }
    /** Return default */
    return UIImage(named: "acme-logo")!
}

/** Returns the active user */
func getActiveUser() -> AcmeUser { return user }

/** Returns the first physcian in list */
func getActiveProvider() -> NSDictionary { return physicians[0] }

