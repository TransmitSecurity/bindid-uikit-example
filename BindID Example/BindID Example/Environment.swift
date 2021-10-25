//
//  Environment.swift
//  BindID Example
//
//  Created by Shachar Udi on 08/06/2021.
//

import Foundation
import XmBindIdSDK

struct Environment {
    static let mode: XmBindIdServerEnvironmentMode = .sandbox
    static let hostName: String = Environment.mode.rawValue
    static let bindIDClientID: String = "YOUR_BINDID_CLIENT_ID"
    static let bindIDRedirectURI: String = "YOUR_BINDID_REDIRECT_URI"
}
