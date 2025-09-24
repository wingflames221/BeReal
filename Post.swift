//
//  Post.swift
//  BeReal
//
//  Created by shaun amoah on 9/23/25.
//
import Foundation
import ParseSwift

struct Post: ParseObject {
    // Required ParseObject properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Custom properties
    var author: User?
    var caption: String?
    var image: ParseFile?
    var location: String?
}
