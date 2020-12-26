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
        label.backgroundColor = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Continue with Spotify", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        return button
    }()
    private let disconnectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Sign out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapDisconnect(_:)), for: .touchUpInside)
        return button
    }()
    private let pauseAndPlayButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapPauseOrPlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.textColor = .black
        trackLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        trackLabel.textAlignment = .center
        return trackLabel
    }()

    //MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        transparentNavigationBar()
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
        view.addSubview(imageView)
        view.addSubview(trackLabel)
        view.addSubview(pauseAndPlayButton)
        let constant: CGFloat = 16.0
//        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        connectButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(1.4)
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(50)
        }
//        disconnectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        disconnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        disconnectButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(1.4)
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(50)
        }
        connectLabel.centerXAnchor.constraint(equalTo: connectButton.centerXAnchor).isActive = true
        connectLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -constant).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        imageView.bottomAnchor.constraint(equalTo: trackLabel.topAnchor, constant: -constant).isActive = true
        trackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: constant).isActive = true
        trackLabel.bottomAnchor.constraint(equalTo: connectLabel.topAnchor, constant: -constant).isActive = true
        pauseAndPlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pauseAndPlayButton.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: constant).isActive = true
        pauseAndPlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pauseAndPlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
    
    func update(playerState: SPTAppRemotePlayerState) {
        if lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        lastPlayerState = playerState
        trackLabel.text = playerState.track.name
        if playerState.isPaused {
            pauseAndPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
        } else {
            pauseAndPlayButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }

    func updateViewBasedOnConnected() {
        if appRemote.isConnected == true {
            connectButton.isHidden = true
            disconnectButton.isHidden = false
            connectLabel.isHidden = true
            imageView.isHidden = false
            trackLabel.isHidden = false
            pauseAndPlayButton.isHidden = false
        } else { //show login
            disconnectButton.isHidden = true
            connectButton.isHidden = false
            connectLabel.isHidden = false
            imageView.isHidden = true
            trackLabel.isHidden = true
            pauseAndPlayButton.isHidden = true
        }
    }

    func fetchArtwork(for track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imageView.image = image
            }
        })
    }

    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
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
//        startActivityIndicator()
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
}

// MARK: - SPTAppRemoteDelegate
extension LoginController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote.playerAPI?.pause(nil)
        self.appRemote.disconnect()
//        updateViewBasedOnConnected()
//        appRemote.playerAPI?.delegate = self
//        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//            if let error = error {
//                print("Error subscribing to player state:" + error.localizedDescription)
//            }
//        })
//        fetchPlayerState()
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
        update(playerState: playerState)
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
