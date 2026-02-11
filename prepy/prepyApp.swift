//
//  prepyApp.swift
//  prepy
//
//  Created by Артем Гаврилов on 9.02.26.
//

import SwiftUI

@main
struct prepyApp: App {
    @StateObject private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            Group {
                if authState.isSignedIn {
                    MainView()
                } else {
                    LoginView(onSuccess: {
                        authState.setSignedIn(true)
                    })
                }
            }
            .task {
                await authState.checkSession()
            }
        }
    }
}
