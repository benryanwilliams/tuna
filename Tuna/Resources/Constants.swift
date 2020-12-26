//
//  Constants.swift
//  Tuna
//
//  Created by Ben Williams on 27/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import Foundation

/*
Scopes let you specify exactly what types of data your application wants to
access, and the set of scopes you pass in your call determines what access
permissions the user is asked to grant.
For more information, see https://developer.spotify.com/web-api/using-scopes/.
*/
let scopes: SPTScope = [
                            .userReadEmail, .userReadPrivate,
                            .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
                            .streaming, .appRemoteControl,
                            .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
                            .userLibraryModify, .userLibraryRead,
                            .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                            .userFollowRead, .userFollowModify,
                        ]
let stringScopes = [
                        "user-read-email", "user-read-private",
                        "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                        "streaming", "app-remote-control",
                        "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                        "user-library-modify", "user-library-read",
                        "user-top-read", "user-read-playback-position", "user-read-recently-played",
                        "user-follow-read", "user-follow-modify",
                    ]

struct Constants {
    
    static let currentUser = "currentUser"
    static let accessTokenKey = "accessTokenKey"
    static let authorizationCodeKey = "authorizationCodeKey"
    static let refreshTokenKey = "refreshTokenKey"
    static let spotifyAuthKey = "spotifyAuthKey"
    
//    enum Views {
//        //https://github.com/ninjaprox/NVActivityIndicatorView
//        static var indicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .ballSpinFadeLoader, color: .label, padding: 0.0)
//    }
    
    enum Images {
        static let heart = UIImage(named: "heart")!
        static let heartFilled = UIImage(named: "heartFilled")!
        static let play = UIImage(named: "play")!
        static let pause = UIImage(named: "pause")!
        static let skipForward15 = UIImage(named: "skipforward15")!
        static let skipBack15 = UIImage(named: "skipback15")!
        static let spotifyIcon = UIImage(named: "spotify.png")!
    }
}
