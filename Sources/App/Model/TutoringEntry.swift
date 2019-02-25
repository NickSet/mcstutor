//
//  TutoringEntry.swift
//  App
//
//  Created by Nicholas Setliff on 2/24/19.
//

import FluentMySQL
import Foundation
import Vapor

struct TutoringEntry: Content, MySQLModel, Migration {
    var id: Int?
    var tutor: Int
    var tutee: String
    var course: String
    var timeIn: Date
    var timeOut: Date?
    var athelete: Bool
    var isActive: Bool
    
    init(id: Int? = nil, tutor: Int, tutee: String, course: String, timeIn: Date, timeOut: Date? = nil, athelete: Bool, isActive: Bool = true) {
        self.id = id
        self.tutor = tutor
        self.tutee = tutee
        self.course = course
        self.timeIn = timeIn
        self.timeOut = timeOut
        self.athelete = athelete
        self.isActive = isActive
    }
}

