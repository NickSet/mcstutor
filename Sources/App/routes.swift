import Authentication
import Fluent
import FluentMySQL
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
        let context = [String:String]()
        // make sure we have an authenticated user
        let session = try req.session()
        guard let _ = session["user_id"] else {
            throw Abort(.unauthorized)
        }
        
        return try req.view().render("student-entry", context)
    }
    
    router.post("student-entry") { req -> Future<View> in
        return try req.view().render("student-entry")
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
