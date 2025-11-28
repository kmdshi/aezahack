import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DocumentEntry {
        DocumentEntry(date: Date(), documents: getSampleDocuments())
    }

    func getSnapshot(in context: Context, completion: @escaping (DocumentEntry) -> ()) {
        let entry = DocumentEntry(date: Date(), documents: getRecentDocuments())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DocumentEntry] = []
        
        // Generate a timeline consisting of entries an hour apart, starting from the current date
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DocumentEntry(date: entryDate, documents: getRecentDocuments())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getRecentDocuments() -> [WidgetDocument] {
        let documents = WidgetDataProvider.shared.getRecentDocuments()
        return documents.prefix(3).map { doc in
            WidgetDocument(name: doc.name, date: doc.date, pageCount: doc.pageCount)
        }
    }
    
    private func getSampleDocuments() -> [WidgetDocument] {
        return [
            WidgetDocument(name: "Добро пожаловать!", date: Date(), pageCount: 1),
            WidgetDocument(name: "Создайте свой первый PDF", date: Date().addingTimeInterval(-3600), pageCount: 1)
        ]
    }
}

struct DocumentEntry: TimelineEntry {
    let date: Date
    let documents: [WidgetDocument]
}

struct WidgetDocument {
    let name: String
    let date: Date
    let pageCount: Int
}

struct PDF3WidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text("PDF3")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(entry.documents.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Documents list
            if entry.documents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("Нет документов")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(entry.documents.prefix(3).enumerated()), id: \.offset) { index, document in
                        DocumentRowView(document: document, isLast: index == min(2, entry.documents.count - 1))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .widgetURL(URL(string: "pdf3://open"))
    }
}

struct DocumentRowView: View {
    let document: WidgetDocument
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Document icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                
                // Document info
                VStack(alignment: .leading, spacing: 2) {
                    Text(document.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(formatDate(document.date))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text("\(document.pageCount) стр.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            
            if !isLast {
                Divider()
                    .padding(.leading, 44)
            }
        }
        .contentShape(Rectangle())
        .widgetURL(URL(string: "pdf3://open/\(document.name)"))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "Сегодня, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "HH:mm"
            return "Вчера, \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "dd.MM"
            return formatter.string(from: date)
        }
    }
}

struct PDF3Widget: Widget {
    let kind: String = "PDF3Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PDF3WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PDF3 Документы")
        .description("Быстрый доступ к вашим PDF документам")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    PDF3Widget()
} timeline: {
    DocumentEntry(date: .now, documents: [
        WidgetDocument(name: "Важный договор", date: Date(), pageCount: 8),
        WidgetDocument(name: "Справка из банка", date: Date().addingTimeInterval(-3600), pageCount: 2),
        WidgetDocument(name: "Презентация", date: Date().addingTimeInterval(-7200), pageCount: 15)
    ])
}