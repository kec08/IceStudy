import WidgetKit
import SwiftUI

@main
struct IceStudyWidgetBundle: WidgetBundle {
    var body: some Widget {
        IceStudyWidget()
        DailyAverageWidget()
    }
}
