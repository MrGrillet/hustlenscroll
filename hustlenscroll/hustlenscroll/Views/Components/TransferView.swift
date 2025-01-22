import SwiftUI

struct TransferView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    let fromAccountType: AccountType
    @State private var toAccountType: AccountType = .checking
    @State private var amount = ""
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private func formatCurrency(_ value: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    private var fromBalance: Double {
        switch fromAccountType {
        case .checking:
            return gameState.currentPlayer.bankBalance
        case .savings:
            return gameState.currentPlayer.savingsBalance
        case .familyTrust:
            return gameState.familyTrustBalance
        case .creditCard:
            return gameState.creditCardBalance
        case .blackCard:
            return gameState.blackCardBalance
        case .platinumCard:
            return gameState.platinumCardBalance
        default:
            return 0
        }
    }
    
    private var availableAccounts: [AccountType] {
        var accounts: [AccountType] = [
            .checking,
            .savings,
            .familyTrust,
            .creditCard,
            .blackCard,
            .platinumCard
        ]
        // Remove the current account from options
        accounts.removeAll { $0 == fromAccountType }
        return accounts
    }
    
    private var isValidAmount: Bool {
        guard let transferAmount = Double(amount) else { return false }
        return transferAmount > 0 && transferAmount <= fromBalance
    }
    
    private func handleTransfer() {
        guard let transferAmount = Double(amount), isValidAmount else { return }
        
        // Deduct from source account
        switch fromAccountType {
        case .checking:
            gameState.currentPlayer.bankBalance -= transferAmount
        case .savings:
            gameState.currentPlayer.savingsBalance -= transferAmount
        case .familyTrust:
            gameState.familyTrustBalance -= transferAmount
        default:
            return
        }
        
        // Add to destination account
        switch toAccountType {
        case .checking:
            gameState.currentPlayer.bankBalance += transferAmount
        case .savings:
            gameState.currentPlayer.savingsBalance += transferAmount
        case .familyTrust:
            gameState.familyTrustBalance += transferAmount
        case .creditCard:
            gameState.creditCardBalance -= transferAmount
        case .blackCard:
            gameState.blackCardBalance -= transferAmount
        case .platinumCard:
            gameState.platinumCardBalance -= transferAmount
        default:
            return
        }
        
        // Record transaction
        gameState.transactions.append(Transaction(
            date: Date(),
            description: "Transfer from \(fromAccountType.title) to \(toAccountType.title)",
            amount: transferAmount,
            isIncome: false
        ))
        
        gameState.saveState()
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("From Account")) {
                    Text(fromAccountType.title)
                    Text("Available Balance: " + formatCurrency(fromBalance))
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("To Account")) {
                    Picker("Select Account", selection: $toAccountType) {
                        ForEach(availableAccounts, id: \.self) { accountType in
                            Text(accountType.title).tag(accountType)
                        }
                    }
                }
                
                Section(header: Text("Transfer Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button("Transfer") {
                        handleTransfer()
                    }
                    .disabled(!isValidAmount)
                }
            }
            .navigationTitle("Transfer Money")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
} 