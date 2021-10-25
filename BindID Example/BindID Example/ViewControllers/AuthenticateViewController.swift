//
//  ViewController.swift
//  BindID Example
//
//  Created by Shachar Udi on 06/06/2021.
//

import UIKit
import XmBindIdSDK

class AuthenticateViewController: UIViewController {

    @IBOutlet weak var authenticateButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Authenticate"
        authenticateButton.setLoading(true)
        authenticateButton.layer.cornerRadius = 12
        initializeBindID()
    }

    @IBAction func didPressAuthenticate() {
        authenticateWithBindID()
    }
    
    // MARK: - BindID SDK Initialization
    
    private func initializeBindID() {
        /**
            Configure the BindID SDK with your client ID, and to work with the BindID sandbox environment.
         */
        
        let config = XmBindIdConfig(serverEnvironment: XmBindIdServerEnvironment(environmentMode: Environment.mode), clientId: Environment.bindIDClientID)

        XmBindIdSdk.shared.initialize(config: config) { [weak self] (_, error) in
            if let e = error {
                fatalError("Failed to initialize SDK: \(e.code!)")
                // To troubleshoot errors, check out the docs: https://developer.bindid.io/docs/api/ios/XmBindIdErrorCode
            } else {
                NSLog("BindID SDK initialized successfully")
                self?.enableAuthenticationInMainThread()
            }
        }
    }
    
    private func enableAuthenticationInMainThread() {
        DispatchQueue.main.async { [weak self] in
            self?.authenticateButton.setLoading(false)
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToAuthenticatedUserVC(idToken: String, accessToken: String) {
        let authenticatedUserViewController = storyboard!.instantiateViewController(identifier: "AuthenticatedUserViewController") as! AuthenticatedUserViewController
        authenticatedUserViewController.idToken = idToken
        authenticatedUserViewController.accessToken = accessToken
        navigationController?.pushViewController(authenticatedUserViewController, animated: true)
    }
    
    // MARK:- Handle JWT Validation results
    
    private func handleJWTValidation(isValid: Bool, tokenResponse: XmBindIdExchangeTokenResponse) {
        guard isValid else {
            handleAppErrorWithMessage("The JWT (idToken) is not valid. Please check your configuration")
            return
        }
        navigateToAuthenticatedUserVC(idToken: tokenResponse.idToken, accessToken: tokenResponse.accessToken)
    }
    
    
    // MARK: BindID SDK API
    
    private func authenticateWithBindID() {
        /**
         Authenticate the user
         */
        
        let request = XmBindIdAuthenticationRequest(redirectUri: Environment.bindIDRedirectURI)
        request.usePkce = true // This enables using a PKCE flow (RFC-7636) to securely obtain the ID and access token through the client.
        request.scope = [.openId, .networkInfo, .email] // openId is the default configuration, you can also add .email, .networkInfo, .phone
        XmBindIdSdk.shared.authenticate(bindIdRequestParams: request) { [weak self] (response, error) in
            if let e = error {
                self?.handleBindIDError(error: e)
            } else if let requestResponse = response {
                self?.exchange(response: requestResponse)
            }
        }
    }

    private func exchange(response: XmBindIdResponse) {
        /**
         Exchange the authentication response for the ID and access token using a PKCE token exchange
         */
        XmBindIdSdk.shared.exchangeToken(exchangeRequest: XmBindIdExchangeTokenRequest.init(codeResponse: response)) { [weak self] (response, error) in
            if let e = error {
                self?.handleBindIDError(error: e)
            } else if let tokenResponse = response {
                self?.validateTokenResponse(tokenResponse)
            }
        }
    }
    
    // MARK:- Validate the Token Exchange Response
    
    private func validateTokenResponse(_ tokenResponse: XmBindIdExchangeTokenResponse) {
        JWTValidator.shared.validate(tokenResponse.idToken) { [weak self] isValid, jwtValidationError in
            guard jwtValidationError == nil else {
                self?.handleAppErrorWithMessage(jwtValidationError!)
                return
            }
            self?.handleJWTValidation(isValid: isValid, tokenResponse: tokenResponse)
        }
    }
    
    // MARK:- Handle Errors

    private func handleBindIDError(error: XmBindIdError) {
        // Display an error message to the user
        let message: String
        
        switch error.code {
        case .userCanceled: message = "The user has canceled the authentication."
        case .internetConnection: message = "Authentication failed. Please check your internet connection and try again."
        case .sdkNotInitialized: message = "Authentication failed. The BindID SDK is not initialized."
        default: message = error.message ?? ""
        }
        
        showAlert(title: "BindID Authentication Error", message: message)
    }
    
    private func handleAppErrorWithMessage(_ message: String) {
        showAlert(title: "Authentication Error", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
