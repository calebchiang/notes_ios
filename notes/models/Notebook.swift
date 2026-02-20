import Foundation

struct Notebook: Codable, Identifiable {
    let id: UInt
    let user_id: UInt
    let title: String
    let color: String
    let category: String?
    let created_at: String
    let updated_at: String
}

