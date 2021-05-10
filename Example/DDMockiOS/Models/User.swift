//
//  User.swift
//  DDMockiOS_Example
//
//  Created by Plester, Timothy (AU - Melbourne) on 31/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

class User: Codable {
    let userId: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let emailAddress: String
}
