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
import Alamofire
import OktaAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func signInAction(sender: AnyObject) {
        self.loadingIndicator.startAnimating()
        
        /** Authenticate with Okta */
        if OktaAuth.tokens?.get(forKey: "accessToken") == nil {
            OktaAuth.login()
                .start(self) {
                    response, error in
                    
                    if error != nil { print(error!) }
                    
                    if let authResponse = response {
                        // Store tokens in the keychain
                        OktaAuth.tokens?.set(value: authResponse.accessToken!, forKey: "accessToken")
                        OktaAuth.tokens?.set(value: authResponse.idToken!, forKey: "idToken")
                        
                        OktaAuth.userinfo() {
                            response, error in
                            if error == nil {
                                self.createUser(json: response!)
                            } else {
                                print(error!)
                            }
                        }
                    }
            }
        }
        
    }
    
    override func viewDidLoad() { super.viewDidLoad() }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** Create local user based on OIDC idToken */
    func createUser(json: [String: Any]) {
        let newUser = AcmeUser (
            firstName : json["given_name"] as! String,
            lastName: json["family_name"] as! String,
            email : json["email"] as! String,
            picture : json["picture"] as! String,
            id : "\(json["sub"]!)"
        )
        
        /** If no user ID -> Login again */
        if newUser.id == "nil" {   self.navigationController?.popToRootViewController(animated: true) }
        
        /** Load appointments from auth server */
        let accessToken = OktaAuth.tokens?.get(forKey: "accessToken")
        
        loadAppointments(token: accessToken!, id: newUser.id) {
            response, err in
            
            appointmentData = response!
        }
        
        /** Load physicians from auth server */
        loadPhysicians(token: accessToken!) {
            response, err in
            
            physicians = response!
            // Segue after load
            let home = self.storyboard?.instantiateViewController(withIdentifier: "MainController")
            self.present(home!, animated: false, completion: nil)
        }
        
        user = newUser
        print(user.getDetails())
    }
}
