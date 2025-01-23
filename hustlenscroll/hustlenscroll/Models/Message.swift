import Foundation
import SwiftUI

struct Message: Identifiable, Codable {
    let id: UUID
    let senderId: String
    let senderName: String
    let senderRole: String
    let timestamp: Date
    let content: String
    let opportunity: Opportunity?
    var isRead: Bool
    var isArchived: Bool
    var opportunityStatus: OpportunityStatus?
    let opportunityId: UUID?
    
    enum OpportunityStatus: String, Codable {
        case pending
        case accepted
        case rejected
    }
    
    init(
        id: UUID = UUID(),
        senderId: String,
        senderName: String,
        senderRole: String,
        timestamp: Date,
        content: String,
        opportunity: Opportunity? = nil,
        isRead: Bool = false,
        isArchived: Bool = false,
        opportunityStatus: OpportunityStatus? = nil,
        opportunityId: UUID? = nil
    ) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.timestamp = timestamp
        self.content = content
        self.opportunity = opportunity
        self.isRead = isRead
        self.isArchived = isArchived
        self.opportunityStatus = opportunity != nil ? .pending : nil
        self.opportunityId = opportunityId ?? (opportunity != nil ? id : nil)
    }
}

struct Opportunity: Codable {
    let title: String
    let description: String
    let type: OpportunityType
    let requiredInvestment: Double?
    let monthlyRevenue: Double?
    let monthlyExpenses: Double?
    let revenueShare: Double?
    
    enum OpportunityType: String, Codable {
        case startup
        case freelance
        case investment
    }
} 