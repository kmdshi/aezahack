import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    let onCompletion: () -> Void
    
    let onboardingData = [
        OnboardingData(
            imageName: "onboarding_scan_colorful",
            title: "File to PDF",
            subtitle: "📄🔄",
            description: "Convert any file format to PDF instantly. Photos, documents, images - all in one tap."
        ),
        OnboardingData(
            imageName: "onboarding_organize_colorful", 
            title: "AI Document Scanner",
            subtitle: "🤖📄",
            description: "Advanced AI technology recognizes and optimizes your documents automatically."
        ),
        OnboardingData(
            imageName: "onboarding_share_colorful",
            title: "Wireless Print",
            subtitle: "📱🖨️", 
            description: "Print your documents directly from your phone via WiFi to any compatible printer."
        )
    ]
    
    var body: some View {
        ZStack {
            // Paper background
            AppColors.paperGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        OnboardingPageView(data: onboardingData[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                
                // Page indicators and controls
                VStack(spacing: 32) { // Увеличен отступ
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? AppColors.primaryBlue : AppColors.inactiveColor)
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentPage)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            if currentPage < onboardingData.count - 1 {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                            } else {
                                onCompletion()
                            }
                        } label: {
                            Text(currentPage == onboardingData.count - 1 ? "Get Started" : "Next")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.primaryBlue)
                                .cornerRadius(12)
                        }
                        
                        Button("Skip") {
                            onCompletion()
                        }
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

// MARK: - OnboardingPageView
struct OnboardingPageView: View {
    let data: OnboardingData
    
    var body: some View {
        VStack(spacing: 0) {
            // Top spacer - уменьшен
            Spacer()
                .frame(maxHeight: 40)
            
            // Custom visualization - уменьшен размер
            createAdobeStyleVisualization()
            
            // Spacing между изображением и текстом
            Spacer()
                .frame(height: 24)
            
            // Text content с гарантированным пространством
            VStack(spacing: 16) {
                Text(data.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(data.description)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil) // Убираем ограничение на количество строк
                    .fixedSize(horizontal: false, vertical: true) // Позволяем тексту занять нужную высоту
                    .padding(.horizontal, 24) // Уменьшаем отступы
            }
            .frame(minHeight: 120) // Гарантируем минимальную высоту для текста
            
            // Bottom spacer - уменьшен
            Spacer()
                .frame(maxHeight: 80)
        }
        .padding()
    }
    
    @ViewBuilder
    private func createAdobeStyleVisualization() -> some View {
        if let uiImage = UIImage(named: data.imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320, maxHeight: 300) // Уменьшен размер
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: AppColors.shadowColor, radius: 16, x: 0, y: 8)
        } else {
            // Create Adobe Acrobat style visualizations
            if data.title.contains("File to PDF") {
                createFileConversionVisualization()
            } else if data.title.contains("AI Document Scanner") {
                createAdobeEditVisualization()
            } else if data.title.contains("Wireless Print") {
                createWirelessPrintVisualization()
            } else {
                createAdobeShareVisualization()
            }
        }
    }
    
    private func createFileConversionVisualization() -> some View {
        ZStack {
            // Современный градиентный фон с оттенками фиолетового и синего
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.1, blue: 0.4),   // фиолетовый
                        Color(red: 0.1, green: 0.15, blue: 0.3),  // темно-синий
                        Color(red: 0.15, green: 0.08, blue: 0.35) // темно-фиолетовый
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 320, height: 300)
                .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 8)
            
            // Фоновые эффекты конвертации
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            Color.purple.opacity(0.1), 
                            Color.blue.opacity(0.05), 
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: CGFloat(80 + index * 40)
                    ))
                    .frame(width: CGFloat(160 + index * 80), height: CGFloat(160 + index * 80))
                    .offset(
                        x: CGFloat(index * 30 - 20),
                        y: CGFloat(-index * 20 + 10)
                    )
                    .blur(radius: 5)
            }
            
            VStack(spacing: 20) {
                Spacer()
                
                // Центральная композиция: входящие файлы -> конвертация -> PDF
                HStack(spacing: 25) {
                    // СЛЕВА: Различные типы файлов
                    VStack(spacing: 12) {
                        // Стек файлов разных типов
                        ZStack {
                            // JPG файл
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.orange.opacity(0.9), Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 65)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text("🖼️")
                                            .font(.system(size: 20))
                                        Text("JPG")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                )
                                .offset(x: -15, y: -10)
                                .rotation3DEffect(.degrees(15), axis: (x: 0, y: 1, z: 0))
                            
                            // DOCX файл
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 65)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text("📝")
                                            .font(.system(size: 20))
                                        Text("DOCX")
                                            .font(.system(size: 7, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                )
                                .offset(x: 0, y: 5)
                            
                            // TXT файл
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.green.opacity(0.9), Color.mint.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 65)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text("📃")
                                            .font(.system(size: 20))
                                        Text("TXT")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                )
                                .offset(x: 15, y: -5)
                                .rotation3DEffect(.degrees(-15), axis: (x: 0, y: 1, z: 0))
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                        
                        Text("Various Files")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // В ЦЕНТРЕ: Процесс конвертации
                    VStack(spacing: 8) {
                        // Иконка конвертации с вращением
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 30
                                ))
                                .frame(width: 60, height: 60)
                            
                            Text("🔄")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        // Стрелки прогресса
                        HStack(spacing: 3) {
                            ForEach(0..<3) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.purple.opacity(0.7))
                                    .frame(width: 8, height: 3)
                            }
                            Text("→")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.purple)
                        }
                        
                        Text("Converting")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    
                    // СПРАВА: PDF результат
                    VStack(spacing: 12) {
                        // PDF файл
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.white, Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 55, height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 4) {
                                Text("📄")
                                    .font(.system(size: 24))
                                
                                Text("PDF")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.red)
                                
                                // Индикатор качества
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 4, height: 4)
                                    Text("Ready")
                                        .font(.system(size: 6, weight: .medium))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        Text("PDF Output")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Индикаторы возможностей снизу
                HStack(spacing: 25) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("📁")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.orange.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Any Format")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("⚡")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.purple.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Fast Convert")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.red.opacity(0.4), Color.red.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("📄")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.red.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Perfect PDF")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 300)
    }
    
    private func createAdobeScanVisualization() -> some View {
        ZStack {
            // Неоморфизм фон с размытыми геометрическими фигурами
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(
                    colors: [Color(red: 0.98, green: 0.98, blue: 0.99), Color(red: 0.95, green: 0.96, blue: 0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 320, height: 300)
                .overlay(
                    // Внутренние тени для неоморфизма
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .shadow(color: Color.gray.opacity(0.15), radius: 20, x: -8, y: -8)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 8)
            
            VStack(spacing: 24) {
                Spacer()
                
                // Центральная композиция: 3D телефон с лучом света
                ZStack {
                    // Проецируемый PDF документ (результат)
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 140, height: 180)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .overlay(
                                VStack(spacing: 6) {
                                    // PDF иконка и заголовок
                                    HStack {
                                        Text("📄")
                                            .font(.system(size: 16))
                                        Text("PDF")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppColors.primaryBlue)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.top, 10)
                                    
                                    // Линии документа
                                    ForEach(0..<8) { lineIndex in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 100, height: 2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 12)
                                    }
                                    
                                    Spacer()
                                    
                                    // Статус качества
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 6, height: 6)
                                        Text("Perfect Quality")
                                            .font(.system(size: 8, weight: .medium))
                                            .foregroundColor(.green)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 10)
                                }
                            )
                    }
                    .offset(y: 40)
                    
                    // 3D iPhone с подсветкой
                    ZStack {
                        // Тень
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 80, height: 140)
                            .offset(x: 4, y: 6)
                            .blur(radius: 8)
                        
                        // Корпус
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(
                                colors: [Color(red: 0.15, green: 0.15, blue: 0.18), Color(red: 0.08, green: 0.08, blue: 0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 140)
                        
                        // Экран с лучом света
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 70, height: 120)
                            .overlay(
                                // Проецируемый луч света
                                LinearGradient(
                                    colors: [AppColors.primaryBlue.opacity(0.8), Color.clear],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                                .mask(
                                    Path { path in
                                        // Трапециевидная форма луча
                                        path.move(to: CGPoint(x: 35, y: 60))
                                        path.addLine(to: CGPoint(x: 25, y: 120))
                                        path.addLine(to: CGPoint(x: 45, y: 120))
                                        path.closeSubpath()
                                    }
                                )
                            )
                    }
                    .offset(x: -60, y: -50)
                }
                
                Spacer()
                
                // Индикаторы снизу
                HStack(spacing: 30) {
                    VStack(spacing: 6) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [AppColors.primaryBlue.opacity(0.2), AppColors.primaryBlue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("📱")
                                    .font(.system(size: 16))
                            )
                            .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("Scan")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 6) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("✨")
                                    .font(.system(size: 16))
                            )
                            .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("Enhance")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 6) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("📄")
                                    .font(.system(size: 16))
                            )
                            .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("PDF")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 300)
    }
    
    private func createAdobeEditVisualization() -> some View {
        ZStack {
            // Технологичный темно-синий фон
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.12, blue: 0.25),
                        Color(red: 0.05, green: 0.08, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 320, height: 300)
                .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 8)
            
            // Фоновые технологичные эффекты
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.06), 
                            Color.blue.opacity(0.03), 
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: CGFloat(80 + index * 60)
                    ))
                    .frame(width: CGFloat(160 + index * 120), height: CGFloat(160 + index * 120))
                    .offset(
                        x: CGFloat(index * 50 - 40),
                        y: CGFloat(-index * 40 + 30)
                    )
                    .blur(radius: 6)
            }
            
            VStack(spacing: 28) {
                Spacer()
                
                // Центральная AI-композиция
                ZStack {
                    // Документ под сканированием
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 140, height: 180) // Уменьшен размер для помещения в фон
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                        .overlay(
                            VStack(spacing: 8) {
                                // Заголовок документа
                                HStack {
                                    Text("📄")
                                        .font(.system(size: 18))
                                    Text("DOCUMENT")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(.horizontal, 12) // Уменьшен padding под новый размер документа
                                .padding(.top, 12)
                                
                                // Текстовые линии документа
                                VStack(spacing: 6) {
                                    ForEach(0..<8) { lineIndex in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: CGFloat(90 + (lineIndex % 2) * 15), height: 3) // Уменьшено под новый размер документа
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.horizontal, 12) // Уменьшен padding
                                
                                Spacer()
                            }
                        )
                    
                    // AI рамка сканирования
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(LinearGradient(
                            colors: [Color.cyan, Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 3)
                        .frame(width: 150, height: 190) // Уменьшен размер под новый документ
                        .shadow(color: Color.cyan.opacity(0.6), radius: 8, x: 0, y: 0)
                    
                    // AI точки по углам
                    ForEach(0..<4) { cornerIndex in
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.cyan, Color.blue.opacity(0.8)],
                                center: .center,
                                startRadius: 1,
                                endRadius: 8
                            ))
                            .frame(width: 16, height: 16)
                            .shadow(color: Color.cyan.opacity(0.8), radius: 4, x: 0, y: 0)
                            .offset(
                                x: cornerIndex % 2 == 0 ? -75 : 75, // Обновлено под новую ширину 150
                                y: cornerIndex < 2 ? -95 : 95       // Обновлено под новую высоту 190
                            )
                    }
                    
                    // AI сканирующие лучи
                    ForEach(0..<3) { rayIndex in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(LinearGradient(
                                colors: [Color.cyan.opacity(0.8), Color.cyan.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 150, height: 2) // Обновлено под новую ширину документа
                            .offset(y: CGFloat(-60 + rayIndex * 60))
                            .blur(radius: 0.5)
                    }
                    
                    // AI процессинг индикатор
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("AI PROCESSING")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.7))
                        )
                    }
                    .offset(y: -110) // Уменьшен offset под новый размер документа
                }
                
                Spacer()
                
                // AI технологии индикаторы
                HStack(spacing: 25) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.cyan.opacity(0.5), Color.cyan.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("🤖")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.cyan.opacity(0.5), radius: 6, x: 0, y: 2)
                        
                        Text("AI Recognition")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.cyan)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("🔍")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.blue.opacity(0.5), radius: 6, x: 0, y: 2)
                        
                        Text("Auto Detect")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.purple.opacity(0.5), Color.purple.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("⚡")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.purple.opacity(0.5), radius: 6, x: 0, y: 2)
                        
                        Text("Optimize")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.purple)
                    }
                }
                .offset(y: -50) // Поднимаем иконки еще выше
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 300)
    }
    
    private func createWirelessPrintVisualization() -> some View {
        ZStack {
            // Современный серо-синий градиентный фон
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.2, blue: 0.3),   // серо-синий
                        Color(red: 0.08, green: 0.12, blue: 0.2),  // темно-синий
                        Color(red: 0.12, green: 0.15, blue: 0.25)  // средний тон
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 320, height: 300)
                .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 8)
            
            // WiFi волны фоном
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(Color.green.opacity(0.1 - CGFloat(index) * 0.02), lineWidth: 2)
                    .frame(width: CGFloat(80 + index * 60), height: CGFloat(80 + index * 60))
                    .offset(x: -80, y: -50)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Основная композиция: телефон -> WiFi -> принтер
                HStack(spacing: 40) {
                    // СЛЕВА: iPhone с документом
                    VStack(spacing: 8) {
                        ZStack {
                            // Корпус iPhone
                            RoundedRectangle(cornerRadius: 22)
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.2, green: 0.2, blue: 0.25), Color(red: 0.1, green: 0.1, blue: 0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 70, height: 130)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            // Экран с документом
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .frame(width: 60, height: 110)
                                .overlay(
                                    VStack(spacing: 4) {
                                        // Заголовок документа
                                        HStack {
                                            Text("📄")
                                                .font(.system(size: 10))
                                            Text("Document.pdf")
                                                .font(.system(size: 6, weight: .medium))
                                                .foregroundColor(.black)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.top, 6)
                                        
                                        // Содержание документа
                                        VStack(spacing: 2) {
                                            ForEach(0..<8) { _ in
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 45, height: 1.5)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .padding(.horizontal, 6)
                                        
                                        Spacer()
                                        
                                        // Кнопка печати
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue)
                                            .frame(width: 45, height: 20)
                                            .overlay(
                                                HStack(spacing: 2) {
                                                    Text("🖨️")
                                                        .font(.system(size: 8))
                                                    Text("Print")
                                                        .font(.system(size: 6, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            )
                                            .padding(.bottom, 8)
                                    }
                                )
                        }
                        
                        Text("iPhone")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // В ЦЕНТРЕ: WiFi сигнал и стрелка
                    VStack(spacing: 12) {
                        // WiFi иконка с анимированными волнами
                        ZStack {
                            ForEach(0..<3, id: \.self) { index in
                                Path { path in
                                    let radius = CGFloat(15 + index * 10)
                                    path.addArc(center: CGPoint(x: 0, y: 0), radius: radius, startAngle: .degrees(30), endAngle: .degrees(150), clockwise: false)
                                }
                                .stroke(Color.green.opacity(0.8 - CGFloat(index) * 0.2), lineWidth: 3)
                                .frame(width: 50, height: 50)
                            }
                            
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                        }
                        
                        // Стрелка передачи данных
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.green.opacity(0.8))
                                    .frame(width: 4, height: 4)
                            }
                            Text("→")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        Text("WiFi")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    // СПРАВА: Принтер
                    VStack(spacing: 8) {
                        ZStack {
                            // Корпус принтера
                            VStack(spacing: 0) {
                                // Верхняя часть принтера
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(
                                        colors: [Color(red: 0.9, green: 0.9, blue: 0.9), Color(red: 0.8, green: 0.8, blue: 0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 65, height: 25)
                                    .overlay(
                                        // Лоток для бумаги
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                            .frame(width: 50, height: 8)
                                            .offset(y: -3)
                                    )
                                
                                // Основной корпус
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(
                                        colors: [Color(red: 0.85, green: 0.85, blue: 0.85), Color(red: 0.75, green: 0.75, blue: 0.75)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 70, height: 50)
                                    .overlay(
                                        VStack(spacing: 2) {
                                            // Экран принтера
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(Color.black)
                                                .frame(width: 20, height: 8)
                                                .overlay(
                                                    Text("●")
                                                        .font(.system(size: 4))
                                                        .foregroundColor(.green)
                                                )
                                            
                                            // Кнопки
                                            HStack(spacing: 3) {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.6))
                                                    .frame(width: 6, height: 6)
                                                Circle()
                                                    .fill(Color.gray.opacity(0.6))
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                        .offset(y: -8)
                                    )
                            }
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                            
                            // Печатаемый документ
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 35, height: 45)
                                .overlay(
                                    VStack(spacing: 1) {
                                        ForEach(0..<6) { _ in
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.4))
                                                .frame(width: 25, height: 1)
                                        }
                                    }
                                )
                                .offset(x: 20, y: 15)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 1, y: 1)
                        }
                        
                        Text("Printer")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Индикаторы функций снизу
                HStack(spacing: 25) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.green.opacity(0.4), Color.green.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("📶")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.green.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("WiFi Connect")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("📄")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Send Document")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("🖨️")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.orange.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Print")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 300)
    }
    
    private func createAdobeShareVisualization() -> some View {
        ZStack {
            // Футуристичный темный фон с градиентами
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.08, blue: 0.2),  // темно-синий
                        Color(red: 0.1, green: 0.05, blue: 0.15),  // темно-фиолетовый
                        Color(red: 0.02, green: 0.06, blue: 0.18)   // глубокий синий
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 320, height: 300)
                .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 8)
            
            // Фоновые неоновые эффекты
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.08), 
                            Color.purple.opacity(0.05), 
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: CGFloat(60 + index * 40)
                    ))
                    .frame(width: CGFloat(120 + index * 80), height: CGFloat(120 + index * 80))
                    .offset(
                        x: CGFloat(index * 40 - 60),
                        y: CGFloat(-index * 30 + 40)
                    )
                    .blur(radius: 4)
            }
            
            VStack(spacing: 20) {
                Spacer()
                
                // Футуристичная композиция: рука + телефон + документ + AI
                ZStack {
                    // Размытый документ на поверхности
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 120, height: 160)
                            .blur(radius: 8)
                            .overlay(
                                VStack(spacing: 4) {
                                    ForEach(0..<8) { _ in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 80, height: 2)
                                            .blur(radius: 1)
                                    }
                                }
                            )
                    }
                    .offset(y: 60)
                    
                    // Стилизованная рука с телефоном
                    ZStack {
                        // Рука (упрощенная форма)
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 40))
                            path.addCurve(to: CGPoint(x: 25, y: 0), 
                                        control1: CGPoint(x: 8, y: 25), 
                                        control2: CGPoint(x: 18, y: 5))
                            path.addCurve(to: CGPoint(x: 60, y: 10), 
                                        control1: CGPoint(x: 35, y: -2), 
                                        control2: CGPoint(x: 50, y: 2))
                            path.addCurve(to: CGPoint(x: 40, y: 50), 
                                        control1: CGPoint(x: 65, y: 25), 
                                        control2: CGPoint(x: 50, y: 40))
                            path.closeSubpath()
                        }
                        .fill(LinearGradient(
                            colors: [Color(red: 0.85, green: 0.7, blue: 0.6), Color(red: 0.75, green: 0.6, blue: 0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                        
                        // Футуристичный телефон
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(LinearGradient(
                                        colors: [Color.cyan.opacity(0.6), Color.purple.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 2)
                                    .shadow(color: Color.cyan.opacity(0.5), radius: 4)
                            )
                            .overlay(
                                VStack(spacing: 2) {
                                    Text("AI SCANNING")
                                        .font(.system(size: 4, weight: .bold))
                                        .foregroundColor(.cyan)
                                    
                                    // Видоискатель
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.cyan, lineWidth: 1)
                                        .frame(width: 30, height: 25)
                                        .overlay(
                                            // Сканирующие линии
                                            VStack(spacing: 1) {
                                                ForEach(0..<3) { _ in
                                                    Rectangle()
                                                        .fill(Color.cyan.opacity(0.7))
                                                        .frame(height: 0.5)
                                                }
                                            }
                                        )
                                }
                            )
                            .offset(x: 30, y: -20) // позиция телефона в руке
                    }
                    .offset(x: -60, y: -40) // позиция всей руки с телефоном
                }
                
                Spacer()
                
                // AI технологические индикаторы
                HStack(spacing: 25) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.cyan.opacity(0.4), Color.cyan.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("🤖")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.cyan.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("AI Detection")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.cyan)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.1)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("✂️")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.purple.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Auto Crop")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.cyan.opacity(0.4), Color.purple.opacity(0.2)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 16
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("✨")
                                    .font(.system(size: 14))
                            )
                            .shadow(color: Color.cyan.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        Text("Enhance")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(Color.cyan)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 300)
    }
}

// MARK: - Data Models
struct OnboardingData {
    let imageName: String
    let title: String
    let subtitle: String
    let description: String
}

// MARK: - Preview
#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}