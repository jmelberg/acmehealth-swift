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
import AppAuth
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func signInAction(_ sender: AnyObject) {
        self.loadingIndicator.startAnimating()
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        /** Authenticate with Okta */
        if let authenticated = appAuth.loadState() {
            if authenticated == false {
                appAuth.authenticate(self) {
                    response, err in
                    /** Set up authorization server */
                    if response == true {
                        appAuth.authorizationServerConfig(controller: self) {
                            response, err in
                            if response == true {
                                /** Pull user attributes by calling userInfo endpoint */
                                appAuth.pullAttributes() {
                                    response, err in
                                    if err == nil{
                                        /** Create local user from attributes */
                                        self.createUser(response!)
                                    } else {  print(err as Any)}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** Create local user based on OIDC idToken */
    func createUser(_ json : NSDictionary) {

        let newUser = AcmeUser (
            firstName : (json["given_name"] != nil ? "\(json["given_name"]!)" : "John"),
            lastName: (json["family_name"] != nil ? "\(json["family_name"]!)" : "Smith") ,
            email : (json["email"] != nil ? "\(json["email"]!)" : "example@example.com"),
            provider: "Healthcare Cross",
            picture : (json["picture"] != nil ? "\(json["picture"]!)" : "https://randomuser.me/api/portraits/thumb/men/1.jpg"),
            id : "\(json["sub"]!)"
        )
        
        /** If no user ID -> Login again */
        if newUser.id == nil {   self.navigationController?.popToRootViewController(animated: true) }
        
        /** Load appointments from auth server */
        let accessToken = appAuth.authServerState?.lastTokenResponse?.accessToken
        
        loadAppointments(accessToken!, id: newUser.id) {
            response, err in
            appointmentData = response!
        }
        
        /** Load physicians from auth server */
        loadPhysicians(accessToken!) {
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
