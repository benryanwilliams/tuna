//
//  SceneDelegate.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var loginController = LoginController()
    
    //MARK: Spotify Properties
    
    var playURI: String = ""
    var lastPlayerState: SPTAppRemotePlayerState?
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: NetworkManager.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = SpotifyAuth.current?.accessToken
        appRemote.delegate = self
        return appRemote
    }()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    // For spotify authorization and authentication flow
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let parameters = loginController.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            NetworkManager.authorizationCode = code
            loginController.fetchSpotifyAccessToken()
        } else if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            if var spotifyAuth = SpotifyAuth.current {
                spotifyAuth.accessToken = accessToken
                SpotifyAuth.setCurrent(spotifyAuth, writeToUserDefaults: true)
            } else {
                let spotifyAuth = SpotifyAuth(tokenType: nil, refreshToken: nil, accessToken: accessToken, expiresIn: nil, scope: nil)
                SpotifyAuth.setCurrent(spotifyAuth, writeToUserDefaults: true)
            }
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
}

//MARK: Spotify Methods
extension SceneDelegate {
    func connect() {
        self.appRemote.authorizeAndPlayURI(self.playURI)
    }
}

extension SceneDelegate: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        self.appRemote = appRemote
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
}

