import SwiftUI

struct RoleDetailSheet: View {
    let role: Role
    let isSelected: Bool
    let onSelect: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var monthlyIncome: Double {
        role.monthlySalary
    }
    
    private var monthlyExpenses: Double {
        role.monthlyExpenses
    }
    
    private var monthlyCashflow: Double {
        monthlyIncome - monthlyExpenses
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(role.title)
                            .font(.title)
                            .bold()
                        Text("Monthly Income: \(monthlyIncome, format: .currency(code: "USD"))")
                            .foregroundColor(.green)
                    }
                    .padding(.bottom)
                    
                    // Expenses
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Expenses")
                            .font(.headline)
                        ForEach([
                            ("Housing", role.expenses.rent),
                            ("Cell & Internet", role.expenses.cellAndInternet),
                            ("Student Loans", role.expenses.studentLoans),
                            ("Credit Card", role.expenses.creditCard),
                            ("Car Note", role.expenses.carNote)
                        ], id: \.0) { expense in
                            if expense.1 > 0 {
                                HStack {
                                    Text(expense.0)
                                    Spacer()
                                    Text(expense.1, format: .currency(code: "USD"))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        Divider()
                        HStack {
                            Text("Total Expenses")
                                .bold()
                            Spacer()
                            Text(monthlyExpenses, format: .currency(code: "USD"))
                                .foregroundColor(.red)
                                .bold()
                        }
                    }
                    .padding(.bottom)
                    
                    // Cash Flow
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Cash Flow")
                            .font(.headline)
                        HStack {
                            Text("Net Income")
                                .bold()
                            Spacer()
                            Text(monthlyCashflow, format: .currency(code: "USD"))
                                .foregroundColor(monthlyCashflow >= 0 ? .green : .red)
                                .bold()
                        }
                    }
                    
                    Spacer()
                    
                    // Select Button
                    Button {
                        onSelect(true)
                        dismiss()
                    } label: {
                        Text("Select This Role")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
} 
