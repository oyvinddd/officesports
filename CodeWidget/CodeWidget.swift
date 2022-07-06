//
//  CodeWidget.swift
//  CodeWidget
//
//  Created by Øyvind Hauge on 23/06/2022.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> CodeContainerEntry {
        CodeContainerEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CodeContainerEntry) -> Void) {
        let entry = CodeContainerEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [CodeContainerEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = CodeContainerEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CodeContainerEntry: TimelineEntry {
    let date: Date
}

struct CodeWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        QRCodeView()
    }
}

@main struct CodeWidget: Widget {
    let kind = "QRCodeWidget"
    let displayName = "QR Code Widget"
    let description = "A widget for your QR codes!"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CodeWidgetEntryView(entry: entry)
        }
        .supportedFamilies([WidgetFamily.systemSmall])
        .configurationDisplayName(displayName)
        .description(description)
    }
}

struct CodeWidget_Previews: PreviewProvider {
    static var previews: some View {
        CodeWidgetEntryView(entry: CodeContainerEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
