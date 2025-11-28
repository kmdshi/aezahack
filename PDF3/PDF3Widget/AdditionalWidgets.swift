import WidgetKit
import SwiftUI

// MARK: - Quick Actions Widget

struct QuickActionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionsEntry {
        QuickActionsEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> ()) {
        let entry = QuickActionsEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> ()) {
        let entries: [QuickActionsEntry] = [QuickActionsEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct QuickActionsEntry: TimelineEntry {
    let date: Date
}

struct QuickActionsWidgetView: View {
    var entry: QuickActionsProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "doc.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text("PDF3")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Quick Actions Grid
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    QuickActionButton(
                        icon: "camera.fill",
                        title: "Сканировать",
                        color: .blue,
                        url: "pdf3://scan"
                    )
                    
                    QuickActionButton(
                        icon: "plus.circle.fill",
                        title: "Создать PDF",
                        color: .green,
                        url: "pdf3://create"
                    )
                }
                
                HStack(spacing: 8) {
                    QuickActionButton(
                        icon: "signature",
                        title: "Подписать",
                        color: .orange,
                        url: "pdf3://sign"
                    )
                    
                    QuickActionButton(
                        icon: "square.and.arrow.up.fill",
                        title: "Поделиться",
                        color: .purple,
                        url: "pdf3://share"
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

struct QuickActionsWidget: Widget {
    let kind: String = "QuickActionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickActionsProvider()) { entry in
            QuickActionsWidgetView(entry: entry)
        }
        .configurationDisplayName("PDF3 Действия")
        .description("Быстрый доступ к основным функциям")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Statistics Widget

struct StatisticsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(
            date: Date(),
            totalDocuments: 0,
            todayDocuments: 0,
            totalPages: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StatisticsEntry) -> ()) {
        let stats = WidgetDataProvider.shared.getStatistics()
        let entry = StatisticsEntry(
            date: Date(),
            totalDocuments: stats.totalDocuments,
            todayDocuments: stats.todayDocuments,
            totalPages: stats.totalPages
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatisticsEntry>) -> ()) {
        let stats = WidgetDataProvider.shared.getStatistics()
        let entries: [StatisticsEntry] = [
            StatisticsEntry(
                date: Date(),
                totalDocuments: stats.totalDocuments,
                todayDocuments: stats.todayDocuments,
                totalPages: stats.totalPages
            )
        ]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct StatisticsEntry: TimelineEntry {
    let date: Date
    let totalDocuments: Int
    let todayDocuments: Int
    let totalPages: Int
}

struct StatisticsWidgetView: View {
    var entry: StatisticsProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text("Статистика")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Spacer()
            
            // Statistics
            VStack(spacing: 6) {
                StatisticRow(
                    value: "\(entry.totalDocuments)",
                    label: "документов",
                    icon: "doc.fill",
                    color: .blue
                )
                
                StatisticRow(
                    value: "\(entry.todayDocuments)",
                    label: "сегодня",
                    icon: "clock.fill",
                    color: .green
                )
                
                StatisticRow(
                    value: "\(entry.totalPages)",
                    label: "страниц",
                    icon: "doc.plaintext.fill",
                    color: .orange
                )
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .widgetURL(URL(string: "pdf3://statistics"))
    }
}

struct StatisticRow: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatisticsProvider()) { entry in
            StatisticsWidgetView(entry: entry)
        }
        .configurationDisplayName("PDF3 Статистика")
        .description("Информация о ваших документах")
        .supportedFamilies([.systemSmall])
    }
}