//
//  Tutor.swift
//  App
//
//  Created by Nicholas Setliff on 2/23/19.
//
import Authentication
import FluentMySQL
import Foundation
import Vapor

struct Tutor: Content, MySQLModel, Migration {
    var id: Int?
    var username: String
    var password: String
}

extension Tutor: BasicAuthenticatable {
    static let usernameKey = \Tutor.username
    
    static let passwordKey = \Tutor.password
    
}
