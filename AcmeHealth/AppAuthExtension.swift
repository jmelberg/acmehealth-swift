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
import AppAuth
import Alamofire

class AppAuthExtension: NSObject, OIDAuthStateChangeDelegate {
    
    /** AppAuth authStates */
    var authState:OIDAuthState?
    var authServerState: OIDAuthState?
    
    /**  Saves the current authState into NSUserDefaults  */
    func saveState() {
        if(authState == nil && authServerState == nil){
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "com.okta.authState")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "com.okta.authServerState")
        }
        if(authState != nil){
            let archivedAuthState = NSKeyedArchiver.archivedDataWithRootObject(authState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthState, forKey: "com.okta.authState")
        }
        if (authServerState != nil) {
            let archivedAuthServerState = NSKeyedArchiver.archivedDataWithRootObject(authServerState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthServerState, forKey: "com.okta.authServerState")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**  Loads the current authState from NSUserDefaults */
    func loadState() -> Bool? {
        if let archivedAuthState = NSUserDefaults.standardUserDefaults().objectForKey("com.okta.authState") as? NSData {
            if let archivedAuthServerState = NSUserDefaults.standardUserDefaults().objectForKey("com.okta.authServerState") as? NSData {
                if let authState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthState) as? OIDAuthState {
                    if let authServerState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthServerState) as? OIDAuthState {
                        setAuthServerState(authServerState)
                        return true
                    }
                    setAuthState(authState)
                }
            }
        }
        return false
    }
    
    private func setAuthState(authState:OIDAuthState?){
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.stateChanged()
    }
    
    private func setAuthServerState(authState:OIDAuthState?){
        self.authServerState = authState
        self.authServerState?.stateChangeDelegate = self
        self.stateChanged()
    }
    
    /**  Required method  */
    func stateChanged(){ self.saveState() }
    
    /**  Required method  */
    func didChangeState(state: OIDAuthState) { self.stateChanged() }
    
    /**  Verifies authState was performed  */
    func checkAuthState() -> Bool {
        if (authState != nil) { return true  }
        else { return false }
    }
    
    /** Verify scopes contain required values */
    func formatScopes(scopes: [String]) -> [String] {
        let requiredScopes = ["openid", "profile", "email", "offline_access"]
        var scrubbedScopes = scopes
        for requirement in requiredScopes {
            if !scopes.contains(requirement){
                scrubbedScopes.append(requirement)
            }
        }
        return scrubbedScopes
    }
    
    /** Handle Okta authentication -> Returns idToken where user attributes are parsed */
    func authenticate(controller: UIViewController, completionHandler: (Bool?, NSError?) -> ()){
        let issuer = NSURL(string: config.issuer)
        let redirectURI = NSURL(string: config.redirectURI)
        
        /** Discovers Endpoints via OIDC metadata */
        OIDAuthorizationService.discoverServiceConfigurationForIssuer(issuer!) {
            serviceConfig, error in
            
            if ((serviceConfig == nil)) {
                print("Error retrieving discovery document: \(error?.localizedDescription)")
                return
            }
            print("Retrieved configuration: \(serviceConfig!)")
            
            /** Build Authentication Request for idToken */
            let scrubbedScopes = self.formatScopes(config.idTokenScopes)
            let request = OIDAuthorizationRequest(configuration: serviceConfig!,
                                                  clientId: config.clientID,
                                                  scopes: scrubbedScopes,
                                                  redirectURL: redirectURI!,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            print("Initiating Okta Authorization Request: \(request)")
            appDelegate.currentAuthorizationFlow =
                OIDAuthState.authStateByPresentingAuthorizationRequest(request, presentingViewController: controller){
                    authorizationResponse, error in
                    if(authorizationResponse != nil) {
                        self.setAuthState(authorizationResponse)
                        completionHandler(true, nil)
                    } else {
                        print("Authorization Error: \(error!.localizedDescription)")
                        self.setAuthState(nil)
                    }
            }
        }
    }
    
    /** Handle custom authorization server authentication -> Returns token for handshake between API */
    func authorizationServerConfig(controller: UIViewController, completionHandler: (Bool?, NSError?) -> ()) {
        
        let issuer = NSURL(string: config.authIssuer)
        OIDAuthorizationService.discoverServiceConfigurationForIssuer(issuer!) {
            authServerConfig, error in
            if((authServerConfig == nil)) {
                print("Error retrieving discovery documement: \(error?.localizedDescription)")
            }
            print("Retrieved configuration: \(authServerConfig!)")
            
            /** Build Authentication Request for accessToken */
            let request = OIDAuthorizationRequest(configuration: authServerConfig!,
                                                  clientId: config.clientID,
                                                  scopes: config.authorizationServerScopes,
                                                  redirectURL: NSURL(string: config.redirectURI)!,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            print("Initiating Authorization Server Request: \(request)")
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.currentAuthorizationFlow =
                OIDAuthState.authStateByPresentingAuthorizationRequest(request, presentingViewController: controller){
                    authorizationResponse, error in
                    if(authorizationResponse != nil) {
                        self.setAuthServerState(authorizationResponse)
                        completionHandler(true, nil)
                    } else {
                        print("\(error)");
                        print("Authorization Error: \(error!.localizedDescription)")
                        self.setAuthServerState(nil)
                    }
            }
        }
    }
    
    /** Calls userInfo endpoint and returns JSON reponse */
    func pullAttributes(completionHandler: (NSDictionary?, NSError?) ->()){
        /** Call userinfo endpoint to retrieve user info */
        let userinfoEndpoint = authState?.lastAuthorizationResponse
            .request.configuration.discoveryDocument?.userinfoEndpoint
        if(userinfoEndpoint  == nil ) {
            print("Userinfo endpoint not declared in discovery document")
            return
        }

        /** Update OIDC accessToken */
        var token = authState?.lastTokenResponse?.accessToken
        authState?.withFreshTokensPerformAction(){
            accessToken, idToken, error in
            if(error != nil){
                print("Error fetching fresh tokens: \(error!.localizedDescription)")
                return
            }
            /** Update accessToken */
            if(token != accessToken){ token = accessToken }
        }
        
        /** Given accessToken  -> returns all providers */
        func callUserInfoEndpoint(token: String, url: String, completionHandler: (NSDictionary?, NSError?) -> ()){
            let headers = ["Authorization" : "Bearer \(token)",
                           "Accept" :  "application/json"]
            Alamofire.request(.POST, url, headers : headers)
                .validate()
                .responseJSON { response in
                    if let JSON = response.result.value {
                        completionHandler(JSON as? NSDictionary , nil)
                    }
            }
        }
        
        /** Call /userinfo from discovery document */
        callUserInfoEndpoint(token!, url: userinfoEndpoint!.absoluteString!) {
            response, err in
            completionHandler(response!, nil)
        }
    }
}
