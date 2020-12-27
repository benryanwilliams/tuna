//
//  LoginController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit
import CryptoKit //for SHA256
import SnapKit

class LoginController: UIViewController {
    
    var codeVerifier: String = ""
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: NetworkManager.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = SpotifyAuth.current?.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: NetworkManager.configuration, delegate: self)
        return manager
    }()
    private var lastPlayerState: SPTAppRemotePlayerState?

    // MARK: - Subviews

    private let connectLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect your Spotify account"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .tunaGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Continue with Spotify", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        return button
    }()
    private let disconnectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .tunaGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Sign out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapDisconnect(_:)), for: .touchUpInside)
        return button
    }()

    //MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setCodeVerifier()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViewBasedOnConnected()
    }
    
    //MARK: Methods
    func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(connectLabel)
        view.addSubview(connectButton)
        view.addSubview(disconnectButton)

        updateViewBasedOnConnected()
    }
    
    ///create a code verifier that meets Spotify's requirement in order to fetch code and access token
    func setCodeVerifier() {
        guard let data = "SecretPassword".data(using: .utf8) else { return }
        let digest = SHA256.hash(data: data)
        let digestString = digest.map { String(format: "%02X", $0) }.joined()
        let codeChallengeMethod = Data(digestString.utf8).base64EncodedString()
        codeVerifier = codeChallengeMethod
    }

    func updateViewBasedOnConnected() {
        if appRemote.isConnected == true {
            connectButton.isHidden = true
            disconnectButton.isHidden = false
            connectLabel.isHidden = true
        } else { //show login
            disconnectButton.isHidden = true
            connectButton.isHidden = false
            connectLabel.isHidden = false
        }
    }

    // MARK: - Actions

    @objc func didTapPauseOrPlay(_ button: UIButton) {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapDisconnect(_ button: UIButton) {
        if appRemote.isConnected == true {
            appRemote.disconnect()
        }
    }

    @objc func didTapConnect(_ button: UIButton) {
        guard let sessionManager = sessionManager else { return }
        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scopes, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            sessionManager.initiateSession(with: scopes, options: .clientOnly, presenting: self)
        }
    }

    // MARK: - Private Helpers
    
    ///fetch access token and fetch user
    func fetchSpotifyAccessToken() {
        guard let _ = NetworkManager.authorizationCode else { return } //makes sure we have authorization code
        appRemote.connect() //connect appRemote to pause Spotify
        //fetch access token
        NetworkManager.fetchAccessToken { (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
//                    self.stopActivityIndicator()
                    let alertController = UIAlertController(title: "Error fetching token", message: error.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            case .success(let spotifyAuth):
                NetworkManager.fetchUser(accessToken: spotifyAuth.accessToken) { (result) in
                    DispatchQueue.main.async {
//                        self.stopActivityIndicator()
                        switch result {
                        case .failure(let error):
                            let alertController = UIAlertController(title: "Error fetching user", message: error.localizedDescription, preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(OKAction)
                            self.present(alertController, animated: true, completion: nil)
                        case .success(let user):
                            let user = User(user: user)
                            User.setCurrent(user, writeToUserDefaults: true)
                            print("Got user \(user.name)")
//                            self.view.window?.rootViewController = TabBarController()
                            self.view.window?.makeKeyAndVisible()
                        }
                    }
                }
            }
        }
    }
    
    // MARK:- viewDidLayoutSubviews

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let buttonWidth = view.width * 0.8
        let buttonHeight: CGFloat = 50
        let bufferSize: CGFloat = 20
        
        connectLabel.frame = CGRect(
            x: (view.width - buttonWidth) / 2,
            y: (view.height - (buttonHeight * 2) - bufferSize) / 2,
            width: buttonWidth,
            height: buttonHeight
        )
        
        connectButton.frame = CGRect(
            x: (view.width - buttonWidth) / 2,
            y: (connectLabel.bottom + bufferSize),
            width: buttonWidth,
            height: buttonHeight
        )
        
        disconnectButton.frame = CGRect(
            x: (view.width - buttonWidth) / 2,
            y: (connectLabel.bottom + bufferSize),
            width: buttonWidth,
            height: buttonHeight
        )
    }

    
}



// MARK: - SPTAppRemoteDelegate
extension LoginController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote.playerAPI?.pause(nil)
        self.appRemote.disconnect()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension LoginController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        
    }
}

// MARK: - SPTSessionManagerDelegate
extension LoginController: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            print("AUTHENTICATE with WEBAPI")
        } else {
            let alertController = UIAlertController(title: "Authorization Failed", message: error.localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        let alertController = UIAlertController(title: "Session Renewed", message: session.description, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }
}
