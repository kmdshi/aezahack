import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @State private var showingPaywall = false
    @State private var showingShareSheet = false
    
    private var shareText: String {
        "Check out this amazing PDF Converter app - PDF3! 📱📄 Convert, scan, and edit PDFs with ease!"
    }
    
    private var shareAppStoreURL: URL {
        // Замените на реальную ссылку на App Store когда приложение будет опубликовано
        URL(string: "https://apps.apple.com/app/pdf3/") ?? URL(string: "https://apps.apple.com")!
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("Settings")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top)
                        
                        // Settings Options
                        VStack(spacing: 20) {
                            PremiumSettingsButton {
                                showingPaywall = true
                            }
                            
                            SettingsButton(
                                title: "Rate This App",
                                icon: "star.fill",
                                emoji: "⭐️",
                                color: .yellow
                            ) {
                                rateApp()
                            }
                            
                            SettingsButton(
                                title: "Share This App",
                                icon: "square.and.arrow.up",
                                emoji: "📤",
                                color: AppColors.primaryBlue
                            ) {
                                showingShareSheet = true
                            }
                            
                            SettingsButton(
                                title: "Terms of Use",
                                icon: "doc.text",
                                emoji: "📋",
                                color: .orange
                            ) {
                                showingTerms = true
                            }
                            
                            SettingsButton(
                                title: "Privacy Policy",
                                icon: "lock.shield",
                                emoji: "🛡️",
                                color: .green
                            ) {
                                showingPrivacy = true
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                        
                        // App Version
                        Text("PDF Converter Pro v1.0")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding(.top, 44),
                alignment: .topLeading
            )
            .sheet(isPresented: $showingTerms) {
                TermsOfUseView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyPolicyView()
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingShareSheet) {
                SettingsShareSheet(activityItems: [shareText, shareAppStoreURL])
            }
        }
    }
    
    private func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/idXXXXXXXXXX") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let emoji: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(emoji)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Tap to open")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TermsOfUseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Terms of Use")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Last updated: November 26, 2024")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            TermsSection(
                                title: "1. Acceptance of Terms",
                                content: "By downloading, installing, or using PDF Converter Pro (the \"App\"), you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the App."
                            )
                            
                            TermsSection(
                                title: "2. Use of the App",
                                content: "You may use this App for personal and commercial purposes to convert, edit, and manage PDF documents. You agree not to use the App for any illegal or unauthorized purposes."
                            )
                            
                            TermsSection(
                                title: "3. User Content",
                                content: "You retain ownership of all documents and content you process through the App. We do not access, store, or transmit your documents to external servers unless explicitly stated."
                            )
                            
                            TermsSection(
                                title: "4. Limitations of Liability",
                                content: "The App is provided \"as is\" without warranties of any kind. We shall not be liable for any damages arising from the use of the App, including but not limited to data loss or corruption."
                            )
                            
                            TermsSection(
                                title: "5. Premium Features",
                                content: "Some features require a premium subscription. Subscription fees are charged to your iTunes account and will automatically renew unless cancelled at least 24 hours before the end of the current period."
                            )
                            
                            TermsSection(
                                title: "6. Modifications",
                                content: "We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms."
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Last updated: November 26, 2024")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            TermsSection(
                                title: "1. Information We Collect",
                                content: "We may collect usage statistics and crash reports to improve the App. We do not collect personal information without your consent. Documents you process remain on your device."
                            )
                            
                            TermsSection(
                                title: "2. How We Use Information",
                                content: "Any information collected is used solely to improve App functionality, fix bugs, and enhance user experience. We do not sell or share your data with third parties."
                            )
                            
                            TermsSection(
                                title: "3. Data Storage",
                                content: "All documents and files are processed locally on your device. We do not upload your files to our servers unless you explicitly choose to use cloud features."
                            )
                            
                            TermsSection(
                                title: "4. Camera and File Access",
                                content: "The App requests camera access for document scanning and file access for importing documents. These permissions are used solely for App functionality."
                            )
                            
                            TermsSection(
                                title: "5. Analytics",
                                content: "We may use anonymized analytics to understand how users interact with the App. This data cannot be traced back to individual users."
                            )
                            
                            TermsSection(
                                title: "6. Your Rights",
                                content: "You have the right to request deletion of any data we may have collected. Contact us for any privacy-related concerns or requests."
                            )
                            
                            TermsSection(
                                title: "7. Contact Us",
                                content: "If you have any questions about this Privacy Policy, please contact us at privacy@pdfconverter.app"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text(content)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .cardStyle()
    }
}

struct PremiumSettingsButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryGradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("PDF3 Premium")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("NEW")
                            .font(AppFonts.tiny)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.scanColor)
                            .cornerRadius(6)
                    }
                    
                    Text("Unlimited scanning • From $2.49/month")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primaryBlue.opacity(0.1),
                                AppColors.lightBlue.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                            .stroke(AppColors.primaryBlue.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SettingsShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<SettingsShareSheet>) {
        // Nothing to update
    }
}