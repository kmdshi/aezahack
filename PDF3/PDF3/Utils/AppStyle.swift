import SwiftUI

struct AppColors {
    // Primary colors - более яркая и современная палитра
    static let primaryBlue = Color(red: 0.2, green: 0.5, blue: 1.0) // #3380FF - более яркий синий
    static let darkBlue = Color(red: 0.1, green: 0.3, blue: 0.8) // #1A4DCC - глубокий синий
    static let lightBlue = Color(red: 0.5, green: 0.7, blue: 1.0) // #80B3FF - светло-синий
    static let accentBlue = Color(red: 0.0, green: 0.4, blue: 0.9) // #0066E6 - акцентный
    
    // Цветная палитра для типов документов
    static let scanColor = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66 - зеленый для сканирования
    static let convertColor = Color(red: 1.0, green: 0.6, blue: 0.2) // #FF9933 - оранжевый для конвертации
    static let editColor = Color(red: 0.8, green: 0.3, blue: 1.0) // #CC4DFF - фиолетовый для редактирования
    static let signColor = Color(red: 1.0, green: 0.3, blue: 0.5) // #FF4D80 - розовый для подписи
    
    // Градиенты - более яркие и насыщенные
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, darkBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lightGradient = LinearGradient(
        colors: [lightBlue, primaryBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.99, blue: 1.0),
            Color(red: 0.92, green: 0.95, blue: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Цветные градиенты для карточек
    static let scanGradient = LinearGradient(
        colors: [scanColor, Color(red: 0.15, green: 0.7, blue: 0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let convertGradient = LinearGradient(
        colors: [convertColor, Color(red: 0.9, green: 0.5, blue: 0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let editGradient = LinearGradient(
        colors: [editColor, Color(red: 0.7, green: 0.2, blue: 0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let signGradient = LinearGradient(
        colors: [signColor, Color(red: 0.9, green: 0.2, blue: 0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    
    // Градиент для удаления
    static let deleteGradient = LinearGradient(
        colors: [Color.red, Color(red: 0.8, green: 0.1, blue: 0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Supporting colors
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.1)
    static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let cardBackground = Color.white
    static let shadowColor = Color.black.opacity(0.15)
    
    // Paper colors for onboarding
    static let paperColor = Color(red: 0.98, green: 0.97, blue: 0.95) // #FAF7F2 - цвет бумаги
    static let paperGradient = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.98, blue: 0.96),
            Color(red: 0.96, green: 0.95, blue: 0.93)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Цвета для статусов
    static let activeColor = Color(red: 0.1, green: 0.8, blue: 0.1)
    static let inactiveColor = Color.gray
    static let highlightColor = Color(red: 1.0, green: 0.8, blue: 0.0)
}

struct AppFonts {
    static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .medium)
    static let caption = Font.system(size: 14, weight: .regular)
    static let small = Font.system(size: 12, weight: .regular)
    static let tiny = Font.system(size: 10, weight: .medium)
}

struct AppConstants {
    static let cornerRadius: CGFloat = 20
    static let smallCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let itemSpacing: CGFloat = 16
    static let shadowRadius: CGFloat = 12
    static let animationDuration: Double = 0.3
    
    // PDF specific
    static let pdfEmojis = ["📄", "📝", "🔄", "✍️", "📁", "📋", "📊", "🔍", "📤", "📥"]
    
    // Delete action
    static let deleteIconSize: CGFloat = 24
    static let deleteButtonSize: CGFloat = 50
}

extension View {
    func modernCardStyle() -> some View {
        self
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
            .shadow(color: AppColors.shadowColor, radius: AppConstants.shadowRadius, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
    
    func colorfulCardStyle(gradient: LinearGradient) -> some View {
        self
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
            .shadow(color: AppColors.shadowColor, radius: AppConstants.shadowRadius, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    func cardStyle() -> some View {
        modernCardStyle()
    }
    
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .font(AppFonts.headline)
            .padding(.vertical, 18)
            .padding(.horizontal, 36)
            .background(AppColors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
            .shadow(color: AppColors.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(AppColors.primaryBlue)
            .font(AppFonts.headline)
            .padding(.vertical, 18)
            .padding(.horizontal, 36)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(AppColors.primaryBlue, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
            .shadow(color: AppColors.shadowColor, radius: 6, x: 0, y: 4)
    }
    
    func deleteButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .frame(width: AppConstants.deleteButtonSize, height: AppConstants.deleteButtonSize)
            .background(AppColors.deleteGradient)
            .clipShape(Circle())
            .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
    }
    
    func iconButtonStyle(gradient: LinearGradient = AppColors.lightGradient) -> some View {
        self
            .frame(width: 60, height: 60)
            .background(gradient)
            .clipShape(Circle())
            .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 6)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}