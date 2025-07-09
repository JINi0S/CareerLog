//
//  CoverLetterTagService.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/9/25.
//

import Foundation

final class CoverLetterTagService: SupabaseService {
    var client = SupabaseClientProvider.shared
    private var cachedTags: [CoverLetterTag]? = nil

    private let tagTableTitle = "CoverLetterTag"
    private let tagRelationTableTitle = "CoverLetterTagRelation"

    func fetchAllTags(forceRefresh: Bool = false) async throws -> [CoverLetterTag] {
        if let tags = cachedTags, !forceRefresh {
            return tags
        }
        let response: [CoverLetterTagResponse] = try await client
            .from(tagTableTitle)
            .select()
            .order("created_at", ascending: true)
            .execute()
            .value
        let tags = response.map { $0.toDomain() }
        cachedTags = tags
        return tags
    }
    
//    func clearCache() {
//            cachedTags = nil
//     }

    func insertTag(name: String) async throws -> CoverLetterTag {
        let tag = CoverLetterTagInsertRequest(name: name)
        let response: CoverLetterTagResponse = try await client
            .from(tagTableTitle)
            .insert(tag)
            .select()
            .single()
            .execute()
            .value
        dump(response)
        return response.toDomain()
    }
    
    func updateTag(id: Int, newName: String) async throws {
        try await client
            .from(tagTableTitle)
            .update(["name": newName])
            .eq("id", value: id)
            .execute()
    }

    func deleteTag(id: Int) async throws {
        try await client
            .from(tagTableTitle)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - 태그 연결(Relation)
    func attachTagToContent(contentId: Int, tagId: Int) async throws {
        let relation = CoverLetterTagRelationInsertRequest(cover_letter_content_id: contentId, tag_id: tagId)
        try await client
            .from(tagRelationTableTitle)
            .insert(relation)
            .execute()
    }

    func detachTagFromContent(contentId: Int, tagId: Int) async throws {
        try await client
            .from(tagRelationTableTitle)
            .delete()
            .eq("cover_letter_content_id", value: contentId)
            .eq("tag_id", value: tagId)
            .execute()
    }
}
