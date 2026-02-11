//
//  LoginView.swift
//  prepy
//
//  Экран входа в стиле макета: логотип, email/пароль, Log In, Apple/Google, Sign Up.
//  Supabase Auth (email) включён.
//

import SwiftUI
import Supabase

// MARK: - Цвета и стиль (как в макете)

private let backgroundColor = Color(white: 0.08)
private let cardBackground = Color(white: 0.12)
private let textPrimary = Color.white
private let textSecondary = Color.gray
private let accentOrange = Color.orange
private let borderColor = Color(white: 0.25)

// MARK: - LoginView

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var onSuccess: (() -> Void)?

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    logoSection
                    titleSection
                    inputSection
                    loginButton
                    orDivider
                    socialButtons
                    signUpPrompt
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(onSuccess: {
                showSignUp = false
                onSuccess?()
            })
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - Лого и заголовок

    private var logoSection: some View {
        Image(systemName: "graduationcap.circle.fill")
            .font(.system(size: 72))
            .foregroundStyle(accentOrange)
            .padding(.bottom, 16)
    }

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("Start Your Journey")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(textPrimary)
            Text("Your AI-powered path to Band 8+")
                .font(.system(size: 15))
                .foregroundColor(textSecondary)
        }
        .padding(.bottom, 36)
    }

    // MARK: - Поля ввода

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.system(size: 14))
                    .foregroundColor(textSecondary)
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 18))
                        .foregroundColor(textSecondary)
                    TextField("student@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundColor(textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Password")
                        .font(.system(size: 14))
                        .foregroundColor(textSecondary)
                    Spacer()
                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(.system(size: 14))
                    .foregroundColor(accentOrange)
                }
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .font(.system(size: 18))
                        .foregroundColor(textSecondary)
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .textContentType(.password)
                            .foregroundColor(textPrimary)
                    } else {
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .foregroundColor(textPrimary)
                    }
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 18))
                            .foregroundColor(textSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Кнопка Log In

    private var loginButton: some View {
        Button {
            Task { await signIn() }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log In")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(accentOrange)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading || email.isEmpty || password.isEmpty)
        .padding(.bottom, 28)
    }

    // MARK: - OR и соц. кнопки

    private var orDivider: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(borderColor)
                .frame(height: 1)
            Text("OR")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(textSecondary)
            Rectangle()
                .fill(borderColor)
                .frame(height: 1)
        }
        .padding(.bottom, 28)
    }

    private var socialButtons: some View {
        VStack(spacing: 12) {
            socialButton(icon: "apple.logo", title: "Continue with Apple") {
                // TODO: Sign in with Apple
            }
            socialButton(icon: "g.circle.fill", title: "Continue with Google") {
                // TODO: Sign in with Google
            }
        }
        .padding(.bottom, 32)
    }

    private func socialButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(textPrimary)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
        }
    }

    // MARK: - Sign Up внизу

    private var signUpPrompt: some View {
        HStack(spacing: 4) {
            Text("New here?")
                .font(.system(size: 15))
                .foregroundColor(textSecondary)
            Button("Sign Up") {
                showSignUp = true
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(accentOrange)
        }
    }

    // MARK: - Auth

    private func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await SupabaseConfig.client.auth.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            await MainActor.run { onSuccess?() }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - SignUpView

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var onSuccess: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.system(size: 14))
                                .foregroundColor(textSecondary)
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundColor(textSecondary)
                                TextField("student@example.com", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .foregroundColor(textPrimary)
                            }
                            .padding(16)
                            .background(cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14))
                                .foregroundColor(textSecondary)
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundColor(textSecondary)
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .textContentType(.newPassword)
                                        .foregroundColor(textPrimary)
                                } else {
                                    SecureField("Password", text: $password)
                                        .textContentType(.newPassword)
                                        .foregroundColor(textPrimary)
                                }
                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(textSecondary)
                                }
                            }
                            .padding(16)
                            .background(cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                        }
                        if let successMessage {
                            Text(successMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.green)
                        }

                        Button {
                            Task { await signUp() }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accentOrange)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentOrange)
                }
            }
        }
    }

    private func signUp() async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await SupabaseConfig.client.auth.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            await MainActor.run {
                successMessage = "Check your email to confirm your account."
                onSuccess?()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - ForgotPasswordView

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.system(size: 15))
                        .foregroundColor(textSecondary)

                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(textSecondary)
                        TextField("student@example.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(textPrimary)
                    }
                    .padding(16)
                    .background(cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    if let successMessage {
                        Text(successMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                    }

                    Button {
                        Task { await resetPassword() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Reset Link")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentOrange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading || email.isEmpty)

                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentOrange)
                }
            }
        }
    }

    private func resetPassword() async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        let redirectURL = URL(string: "prepy://reset-password")!

        do {
            try await SupabaseConfig.client.auth.resetPasswordForEmail(
                email.trimmingCharacters(in: .whitespacesAndNewlines),
                redirectTo: redirectURL
            )
            await MainActor.run {
                successMessage = "Check your email for the reset link."
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview("Login") {
    LoginView()
}

#Preview("Sign Up") {
    SignUpView()
}
