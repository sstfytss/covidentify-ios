//
//  LoginInfo.swift
//  covidentify-ios
//
//  Created by Shun Sakai on 12/7/22.
//

import Foundation

struct LoginInfo: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }

    let id: Int
    let device_id: Int
    let first_name: String
    let last_name: String
    let email: String
    let password: String
}
