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
    router.get() { req -> Future<View> in
        let context = [String: String]()
        return try req.view().render("login", context)
    }

    router.get("login") { req -> Future<View> in
        let context = [String: String]()
        return try req.view().render("login", context)
    }
    
    router.post("login") { req -> Future<AnyResponse> in
        // pull out the two login fields
        let username: String = try req.content.syncGet(at: "username")
        let password: String = try req.content.syncGet(at: "password")
    
        // convert them to a basic authorization struct
        let authenticationPassword = BasicAuthorization(username: username, password: password)
    
        // attempt to find those credentials in our database
        return Tutor.authenticate(using: authenticationPassword, verifier: BCryptDigest(), on: req).map(to: AnyResponse.self) { tutor in
            if let tutor = tutor {
                // they were found! Save their data in their session
                let session = try req.session()
                session["user_id"] = String(tutor.id!)
                session["username"] = tutor.username
            
                // now redirect to /projects/mine (we haven't made this yet!)
                let redirect = req.redirect(to: "/projects/mine")
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
