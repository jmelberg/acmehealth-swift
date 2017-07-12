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

import Foundation
import Alamofire

/** Given accessToken and provider/user id -> returns all appointments */
let authorizationServerURL = "http://localhost:8088"

func loadAppointments(token: String, id: String, completionHandler: @escaping ([NSDictionary]?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    let url = authorizationServerURL + "/appointments/" + id
    Alamofire.request(url, headers: headers)
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                // Only pull appointments that match patient ID
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

/* *Given accessToken  -> returns all providers */
func loadPhysicians(token: String, completionHandler: @escaping ([NSDictionary]?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    let url = authorizationServerURL + "/providers"
    Alamofire.request(url, headers: headers)
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

/** Creates new appointment */
func createAppointment(params: [String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
    let url = authorizationServerURL + "/appointments"
    Alamofire.request(url, method: .post, parameters: params)
    .responseJSON { response in
            if let JSON = response.result.value {
                completionHandler(JSON as? NSDictionary, nil)
            }
    }
}

/** Deletes appointment */
func removeAppointment(token: String, id : String, completionHandler: @escaping (Bool?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    let url = authorizationServerURL + "/appointments/" + id
    Alamofire.request(url, method: .delete, headers: headers)
        .validate()
        .responseJSON { response in
            if response.response?.statusCode == 204 {
                completionHandler(true, nil)
            }
    }
}
