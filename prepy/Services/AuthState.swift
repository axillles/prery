//
//  AuthState.swift
//  prepy
//
//  Состояние авторизации: есть ли сессия. Для переключения Login ↔ MainView.
//

internal import Combine
import SwiftUI
import Supabase

@MainActor
final class AuthState: ObservableObject {
    @Published private(set) var isSignedIn = false

    /// Вызвать после успешного входа, чтобы сразу переключить UI (пока поток authStateChanges не обновился).
    func setSignedIn(_ value: Bool) {
        isSignedIn = value
    }

    private var authStateTask: Task<Void, Never>?

    init() {
        authStateTask = Task { [weak self] in
            for await (_, session) in await SupabaseConfig.client.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self?.isSignedIn = (session != nil)
                }
            }
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    func checkSession() async {
        do {
            let session = try await SupabaseConfig.client.auth.session
            await MainActor.run { isSignedIn = session != nil }
        } catch {
            await MainActor.run { isSignedIn = false }
        }
    }
}
