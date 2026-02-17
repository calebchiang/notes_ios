//
//  Note.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-17.
//

import Foundation

struct Note: Codable, Identifiable {
    let id: UInt
    let user_id: UInt
    let notebook_id: UInt
    let title: String
    let content: String?
    let created_at: String
    let updated_at: String
}
