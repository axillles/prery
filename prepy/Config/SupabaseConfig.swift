//
//  SupabaseConfig.swift
//  prepy
//
//  Конфигурация Supabase. Подставьте свой URL и anon key из Dashboard → Settings → API.
//

import Foundation
import Supabase

enum SupabaseConfig {
    /// URL проекта: https://YOUR_PROJECT_REF.supabase.co
    static let url = URL(string: "https://ljtokxmvdapozoruqsxl.supabase.co")!

    /// anon public key (безопасен для клиента). После включения Auth используйте его для запросов.
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqdG9reG12ZGFwb3pvcnVxc3hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MTI1MDUsImV4cCI6MjA4NjM4ODUwNX0.KQyJ39Ac56fNQUIcVDkCG1DZqeZ2XVZgERCX7IfBw-o"

    /// Общий клиент для запросов к БД и Storage.
    static let client: SupabaseClient = {
        SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }()
}
