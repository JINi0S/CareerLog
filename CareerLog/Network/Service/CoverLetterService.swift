//
//  CoverLetterService.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/1/25.
//

import Foundation
import Supabase

final class CoverLetterService: SupabaseService {
    var client = SupabaseClientProvider.shared
    
    // MARK: - Insert
    func insert(coverLetter: CoverLetterInsertRequest) async throws -> CoverLetter {
        let response: CoverLetterResponse = try await client
            .from("CoverLetter")
            .insert(coverLetter)
            .select("*")
            .single()
            .execute()
            .value
        
        return response.toDomain()
    }
    
    func insertContent(_ content: CoverLetterContentInsertRequest) async throws -> CoverLetterContent {
        let response: CoverLetterContentResponse = try await client
            .from("CoverLetterContent")
            .insert(content)
            .select("*")
            .single()
            .execute()
            .value

        return response.toDomain()
    }
    
    // MARK: - Fetch
    func fetchAll() async throws -> [CoverLetter] {
        let rows: [CoverLetterResponse] = try await client
            .from("CoverLetter")
            .select()
            .order("due_date", ascending: false)
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }
    
    func fetchContentsWithTags(for coverLetterId: Int) async throws -> [CoverLetterContent] {
        // CoverLetterContent 가져오기
        struct ContentResponse: Decodable {
            let id: Int
            let cover_letter_id: Int
            let question: String
            let character_limit: Int?
            let answer: [String]
            let created_at: Date
        }

        let contents: [ContentResponse] = try await client
            .from("CoverLetterContent")
            .select()
            .eq("cover_letter_id", value: coverLetterId)
            .order("created_at", ascending: true)
            .execute()
            .value

        // Relation + 태그 가져오기 (태그가 없는 content도 있을 수 있음)
        struct RelationResponse: Decodable {
            let cover_letter_content_id: Int
            let tag_id: Int
            let CoverLetterTag: CoverLetterTagResponse
        }

        let relations: [RelationResponse] = try await client
            .from("CoverLetterTagRelation")
            .select("cover_letter_content_id, tag_id, CoverLetterTag(*)")
            .in("cover_letter_content_id", values: contents.map { $0.id })
            .execute()
            .value

        // contentId 기준으로 [tag] 딕셔너리 만들기
        let tagsByContentId = Dictionary(grouping: relations, by: { $0.cover_letter_content_id })
            .mapValues { $0.map { $0.CoverLetterTag.toDomain() } }

        // content 모델 조합
        return contents.map { item in
            CoverLetterContent(
                id: item.id,
                coverLetterId: item.cover_letter_id,
                question: item.question,
                tag: tagsByContentId[item.id] ?? [],
                answers: item.answer,
                characterLimit: item.character_limit,
                createdAt: item.created_at
            )
        }
    }
    
    // MARK: - Update
    func updateContent(content: CoverLetterContentUpdateRequest) async throws {
        try await client
            .from("CoverLetterContent")
            .update(content)
            .eq("id", value: content.id)
            .eq("cover_letter_id", value: content.cover_letter_id)
            .select("*")
            .execute()
    }
    
    func updateCoverLetter(coverLetter: CoverLetterUpdateRequest) async throws {
       try await client
            .from("CoverLetter")
            .update(coverLetter)
            .eq("id", value: coverLetter.id)
            .execute()
    }
    
    // MARK: - Delete
    func deleteCoverLetter(coverLetterId: Int) async throws {
       let res = try await client
            .from("CoverLetter")
            .delete()
            .eq("id", value: coverLetterId)
            .execute()
        print(res)
    }
    
    func deleteContent(contentId: Int, coverLetterId: Int) async throws {
        try await client
            .from("CoverLetterContent")
            .delete()
            .eq("id", value: contentId)
            .eq("cover_letter_id", value: coverLetterId)
            .execute()
    }
}
