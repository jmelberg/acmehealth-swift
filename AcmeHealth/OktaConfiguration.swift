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

class OktaConfiguration {
    let issuer: String!                             // Base url of Okta Developer domain
    let clientID: String!                           // Client ID of Application
    let redirectURI: String!                        // Reverse DNS notation of base url with oauth route
    let authorizationServerURL: String!             // API URI for token authentication
    let authIssuer: String!                         // Authorization Issuer URI
    let idTokenScopes : [String]!
    let authorizationServerScopes: [String]!
    
    
    init(){
        issuer = "https://jordandemo.oktapreview.com"
        clientID = "Jw1nyzbsNihSuOETY3R1"
        redirectURI = "com.acmehealth://oauth"
        authorizationServerURL = "http://localhost:8088"
        authIssuer = "https://jordandemo.oktapreview.com/oauth2/aus9wtufc8L041qj50h7"
        idTokenScopes = [
            "openid",
            "profile",
            "email",
            "offline_access"
        ]
        authorizationServerScopes = [
            "appointments:read",
            "appointments:write",
            "appointments:cancel",
            "providers:read"
        ]
    }
}
