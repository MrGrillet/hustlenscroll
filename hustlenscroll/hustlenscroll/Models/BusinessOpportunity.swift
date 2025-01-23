import Foundation
import SwiftUI

struct BusinessOpportunity: GameEventProtocol, Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let type: EventType
    let source: OpportunitySource
    let opportunityType: OpportunityType
    let monthlyRevenue: Double
    let monthlyExpenses: Double
    let setupCost: Double
    let potentialSaleMultiple: Double
    let revenueShare: Double
    var currentExitMultiple: Double
    let symbol: String
    let socialPostContent: SocialPostContent?
    let originalOpportunityId: UUID?
    
    struct SocialPostContent: Codable, Hashable {
        let defaultText: String
        let images: [String]
    }
    
    // Implement hash(into:) for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement == for Hashable conformance
    static func == (lhs: BusinessOpportunity, rhs: BusinessOpportunity) -> Bool {
        lhs.id == rhs.id
    }
    
    var monthlyCashflow: Double {
        monthlyRevenue - monthlyExpenses
    }
    
    var currentExitValue: Double {
        monthlyCashflow * 12 * currentExitMultiple
    }
    
    enum OpportunitySource: String, Codable {
        case bank
        case investor
        case incubator
        case competitor
        case customer
        case socialMedia
        case partner
        case broker
    }
    
    enum OpportunityType: String, Codable {
        case startup
        case smallBusiness
        case franchise
        case acquisition
        case investment
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        source: OpportunitySource,
        opportunityType: OpportunityType,
        monthlyRevenue: Double,
        monthlyExpenses: Double,
        setupCost: Double,
        potentialSaleMultiple: Double,
        revenueShare: Double = 100.0,
        type: EventType = .opportunity,
        currentExitMultiple: Double? = nil,
        symbol: String,
        socialPostContent: SocialPostContent? = nil,
        originalOpportunityId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.source = source
        self.opportunityType = opportunityType
        self.monthlyRevenue = monthlyRevenue
        self.monthlyExpenses = monthlyExpenses
        self.setupCost = setupCost
        self.potentialSaleMultiple = potentialSaleMultiple
        self.revenueShare = revenueShare
        self.currentExitMultiple = currentExitMultiple ?? potentialSaleMultiple
        self.symbol = symbol
        self.socialPostContent = socialPostContent
        self.originalOpportunityId = originalOpportunityId
    }
} 