//
//  User.swift
//  BeReal
//
//  Created by shaun amoah on 9/24/25.
//
import Foundation
import ParseSwift

struct User: ParseUser {
    // Required ParseUser properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Required ParseUser authentication properties
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    
    // Custom properties (add any additional user properties here)
    // For example:
    // var displayName: String?
    // var profileImage: ParseFile?
}
