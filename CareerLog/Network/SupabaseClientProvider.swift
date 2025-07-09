//
//  SupabaseClientProvider.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/9/25.
//


import Foundation
import Supabase

final class SupabaseClientProvider {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: "")!,
        supabaseKey: ""
    )
}
