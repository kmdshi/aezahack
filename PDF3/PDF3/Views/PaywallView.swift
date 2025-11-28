import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showingPurchase = false
    let appState: AppState?
    
    init(appState: AppState? = nil) {
        self.appState = appState
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Features Section
                    featuresSection
                    
                    // Pricing Plans
                    pricingSection
                    
                    // Purchase Button
                    purchaseButton
                    
                    // Terms and restore
                    bottomSection
                }
                .padding(.horizontal, 20)
            }
            .background(AppColors.backgroundGradient)
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding()
                
                Spacer()
                
                Text("Restore")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.primaryBlue)
                    .onTapGesture {
                        // Handle restore purchases
                    }
                    .padding()
            }
            
            VStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.primaryGradient)
                
                Text("PDF3 Premium")
                    .font(AppFonts.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Unlock unlimited scanning power")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 20) {
            FeatureRow(
                icon: "camera.fill",
                title: "Unlimited Scanning",
                description: "Scan as many documents as you need",
                gradient: AppColors.scanGradient
            )
            
            FeatureRow(
                icon: "pencil",
                title: "Pro Editing Tools",
                description: "Access all premium editing features",
                gradient: AppColors.editGradient
            )
            
            FeatureRow(
                icon: "signature",
                title: "Digital Signatures",
                description: "Add unlimited digital signatures to documents",
                gradient: AppColors.signGradient
            )
            
            FeatureRow(
                icon: "icloud.fill",
                title: "Cloud Sync",
                description: "Sync documents across all devices",
                gradient: AppColors.convertGradient
            )
            
            FeatureRow(
                icon: "shield.checkered",
                title: "Priority Support",
                description: "Get help when you need it most",
                gradient: AppColors.lightGradient
            )
        }
        .padding(.bottom, 30)
    }
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(AppFonts.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 10)
            
            VStack(spacing: 12) {
                PricingCard(
                    plan: .yearly,
                    isSelected: selectedPlan == .yearly,
                    onSelect: { selectedPlan = .yearly }
                )
                
                PricingCard(
                    plan: .monthly,
                    isSelected: selectedPlan == .monthly,
                    onSelect: { selectedPlan = .monthly }
                )
            }
        }
        .padding(.bottom, 30)
    }
    
    private var purchaseButton: some View {
        Button(action: {
            showingPurchase = true
        }) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title3)
                
                Text("Start Premium - \(selectedPlan.displayPrice)")
                    .font(AppFonts.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppColors.primaryGradient)
            .cornerRadius(16)
            .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 20)
        .alert("Purchase", isPresented: $showingPurchase) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                // Simulate successful purchase
                appState?.upgradeToPremiun()
                dismiss()
            }
        } message: {
            Text("Start your premium subscription for \(selectedPlan.displayPrice)?")
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 12) {
            Text("Auto-renewal. Cancel anytime in Settings.")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button("Terms of Service") {
                    // Handle terms
                }
                .font(AppFonts.caption)
                .foregroundColor(AppColors.primaryBlue)
                
                Button("Privacy Policy") {
                    // Handle privacy
                }
                .font(AppFonts.caption)
                .foregroundColor(AppColors.primaryBlue)
            }
        }
        .padding(.bottom, 30)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct PricingCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.title)
                            .font(AppFonts.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if plan == .yearly {
                            Text("SAVE 60%")
                                .font(AppFonts.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.scanColor)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(plan.subtitle)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.displayPrice)
                        .font(AppFonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if plan == .yearly {
                        Text("$2.49/month")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .strikethrough()
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.textSecondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: AppColors.shadowColor, radius: isSelected ? 8 : 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? AppColors.primaryBlue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum SubscriptionPlan: CaseIterable {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
    
    var subtitle: String {
        switch self {
        case .monthly:
            return "Unlimited scans per month"
        case .yearly:
            return "Unlimited scans per year"
        }
    }
    
    var displayPrice: String {
        switch self {
        case .monthly:
            return "$4.99/month"
        case .yearly:
            return "$29.99/year"
        }
    }
    
    var priceValue: Double {
        switch self {
        case .monthly:
            return 4.99
        case .yearly:
            return 29.99
        }
    }
}

#Preview {
    PaywallView()
}