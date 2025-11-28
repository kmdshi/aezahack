import WidgetKit
import SwiftUI

@main
struct PDF3WidgetBundle: WidgetBundle {
    var body: some Widget {
        PDF3Widget()
        QuickActionsWidget()
        StatisticsWidget()
    }
}