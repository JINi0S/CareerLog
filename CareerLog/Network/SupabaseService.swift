//
//  SupabaseService.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/9/25.
//


import Supabase

protocol SupabaseService {
    var client: SupabaseClient { get }
}
