import Authentication
import Fluent
import FluentMySQL
import Foundation
import Leaf
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get { req in
        return req.redirect(to: "/login")
    }
    
    router.get("login") { req -> Future<View> in
        let context = [String: String]()
        return try req.view().render("login", context)
    }
    
    router.get("student-entry") { req -> Future<View> in
        // make sure we have an authenticated user
        let session = try req.session()
        guard let _ = session["user_id"] else {
            throw Abort(.unauthorized)
        }
        
        struct EntryContext: Codable {
            var entries: [TutoringEntry]
        }
        
        return TutoringEntry.query(on: req).filter(\.isActive == true).all().flatMap(to: View.self) { entries in
            let context = EntryContext(entries: entries)
            return try req.view().render("student-entry", context)
        }
    }
    
    router.post("entry-signout") { req -> Future<Response> in
        let session = try req.session()
        guard let _ = session["user_id"] else {
            throw Abort(.unauthorized)
        }
        
        
        let name: String = try req.content.syncGet(at: "tutee")
        print(name)
        return TutoringEntry.query(on: req).filter(\.tutee == name).filter(\.isActive == true).first().flatMap(to: Response.self) { entry in
            guard var entry = entry else {
                throw Abort(.notFound)
            }
            entry.isActive = false
            return entry.save(on: req).map(to: Response.self) { entry in
                return req.redirect(to: "/student-entry")
            }
        }
        
    }
    
    router.post("student-entry") { req -> Future<Response> in
        let session = try req.session()
        guard let tutorID = session["user_id"] else {
            throw Abort(.unauthorized)
        }
        
        let name: String = try req.content.syncGet(at: "name")
        let courseDescription: String = try req.content.syncGet(at: "course")
        let dateString: String = try req.content.syncGet(at: "date")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateIn: Date? = dateFormatter.date(from: dateString)
        
        let course = String(courseDescription[..<String.Index(encodedOffset: 8)])
        let entry = TutoringEntry(tutor: Int(tutorID) ?? 0, tutee: name, course: course, timeIn: dateIn ?? Date(), athelete: false)
        return entry.save(on: req).map(to: Response.self) { entry in
            return req.redirect(to: "/student-entry")
        }
    }

    router.post("login") { req -> Future<AnyResponse> in
        // pull out the two login fields
        let username: String = try req.content.syncGet(at: "username")
        let password: String = try req.content.syncGet(at: "password")
        
        // convert them to a basic authorization struct
        let authenticationPassword = BasicAuthorization(username: username, password: password)

        // attempt to find those credentials in our database
        return Tutor.authenticate(using: authenticationPassword, verifier: BCryptDigest(), on: req).map(to: AnyResponse.self) { user in
            if let user = user {
                // they were found! Save their data in their session
                let session = try req.session()
                session["user_id"] = String(user.id!)
                session["username"] = user.username
                
                // now redirect to /projects/mine (we haven't made this yet!)
                let redirect = req.redirect(to: "/student-entry")
                return AnyResponse(redirect)
            } else {
                // user wasn't found - re-render the login page
                let context = ["error": true]
                let page = try req.view().render("login", context)
                return AnyResponse(page)
            }
        }
    }
}
