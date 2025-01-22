import Foundation

struct BusinessResponseMessages {
    static let userRejectionMessages = [
        "I've reviewed the opportunity, but I don't think I can make it work with my current finances.",
        "Thanks for thinking of me, but I'll have to pass on this one due to budget constraints.",
        "I appreciate the offer, but I don't have the capital available right now.",
        "After checking my finances, I don't think I can take this on at the moment."
    ]
    
    static let userAcceptanceMessages = [
        "I've reviewed the numbers and I'd like to move forward with this opportunity.",
        "This looks like a great fit. I'm ready to proceed with the deal.",
        "I'm excited about this opportunity and would like to move forward.",
        "The numbers work for me. Let's make this happen."
    ]
    
    static let brokerFollowUpMessages = [
        "Great! I'll reach out to your accountant to handle the paperwork.",
        "Excellent! I'll coordinate with your accountant to finalize everything.",
        "Perfect! I'll work with your accountant to get everything set up.",
        "Wonderful! I'll connect with your accountant to process the deal."
    ]
    
    static let brokerRejectionResponses = [
        "I understand. Let me know if your situation changes in the future.",
        "No problem at all. I'll keep you in mind for other opportunities that might be a better fit.",
        "Thanks for considering it. I'll reach out if something more suitable comes up.",
        "I appreciate your honesty. Feel free to reach out when the timing is better."
    ]
    
    static let accountantConfirmations = [
        "Just to confirm, the deal for {company} has been completed. Congratulations on your new venture!",
        "Great news! The paperwork for {company} is all set. The business is now officially yours.",
        "I've processed all the documentation for {company}. Everything is finalized and ready to go.",
        "The acquisition of {company} is complete. All the necessary transfers have been processed."
    ]
    
    static func getRandomMessage(_ messages: [String], replacements: [String: String] = [:]) -> String {
        var message = messages.randomElement() ?? messages[0]
        for (key, value) in replacements {
            message = message.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return message
    }
} 