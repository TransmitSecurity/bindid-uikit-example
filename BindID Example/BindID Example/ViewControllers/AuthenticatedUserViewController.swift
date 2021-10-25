//
//  AuthenticatedUserViewController.swift
//  BindID Example
//
//  Created by Shachar Udi on 07/06/2021.
//

import UIKit

class AuthenticatedUserViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    public var idToken: String = ""
    public var accessToken: String = ""
    
    internal var sortedPassportKeys: [String] = []
    internal var userPassport: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Passport"
        setPassportTableData()
    }
        
    private func setPassportTableData() {
        // Parse the ID token payload received from BindID to obtain information about the user
        guard let tokenData = try? JWTDecoder.shared.decodePayload(idToken) else {
            NSLog("Error decoding BindID Token: \(idToken)")
            return
        }
        
        userPassport = JWTParser.shared.parseIDTokenData(tokenData)
        sortedPassportKeys = Array(userPassport.keys).sorted()
        
        tableView.reloadData()
    }
}

extension AuthenticatedUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPassport.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passport_cell", for: indexPath)
        
        guard sortedPassportKeys.indices.contains(indexPath.row) else {
            NSLog("Sorted passport keys array does not contain the current indexPath row: \(indexPath.row)")
            return cell
        }
        
        let currentKey = String(sortedPassportKeys[indexPath.row])
        
        cell.textLabel?.text = currentKey
        cell.detailTextLabel?.text = userPassport[currentKey]
        
        return cell
    }
}
