import WidgetKit
import SwiftUI

// MARK: - Widget Data Provider

struct VantagWidgetEntry: TimelineEntry {
    let date: Date
    let formattedTime: String
    let formattedAmount: String
    let spendingLevel: String
    let pursuitName: String
    let pursuitProgressText: String
    let pursuitProgress: Double
    let pursuitTarget: Double
    let hasPursuit: Bool
    let locale: String

    static var placeholder: VantagWidgetEntry {
        VantagWidgetEntry(
            date: Date(),
            formattedTime: "0h 0m",
            formattedAmount: "$0",
            spendingLevel: "low",
            pursuitName: "",
            pursuitProgressText: "",
            pursuitProgress: 0,
            pursuitTarget: 0,
            hasPursuit: false,
            locale: "en"
        )
    }
}

struct VantagWidgetProvider: TimelineProvider {
    private let appGroupId = "group.com.vantag.app"

    func placeholder(in context: Context) -> VantagWidgetEntry {
        VantagWidgetEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (VantagWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VantagWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> VantagWidgetEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)

        return VantagWidgetEntry(
            date: Date(),
            formattedTime: userDefaults?.string(forKey: "formattedTime") ?? "0h 0m",
            formattedAmount: userDefaults?.string(forKey: "formattedAmount") ?? "$0",
            spendingLevel: userDefaults?.string(forKey: "spendingLevel") ?? "low",
            pursuitName: userDefaults?.string(forKey: "pursuitName") ?? "",
            pursuitProgressText: userDefaults?.string(forKey: "pursuitProgressText") ?? "",
            pursuitProgress: userDefaults?.double(forKey: "pursuitProgress") ?? 0,
            pursuitTarget: userDefaults?.double(forKey: "pursuitTarget") ?? 0,
            hasPursuit: userDefaults?.bool(forKey: "hasPursuit") ?? false,
            locale: userDefaults?.string(forKey: "locale") ?? "en"
        )
    }
}

// MARK: - Colors

extension Color {
    static let widgetBackground = Color(red: 0.145, green: 0.145, blue: 0.227) // #25253A
    static let widgetTextPrimary = Color(red: 0.961, green: 0.961, blue: 0.961) // #F5F5F5
    static let widgetTextSecondary = Color(red: 0.690, green: 0.690, blue: 0.690) // #B0B0B0
    static let widgetTextTertiary = Color(red: 0.416, green: 0.416, blue: 0.478) // #6A6A7A
    static let widgetAccent = Color(red: 0.424, green: 0.388, blue: 1.0) // #6C63FF
    static let widgetPositive = Color(red: 0.180, green: 0.800, blue: 0.443) // #2ECC71
    static let widgetWarning = Color(red: 1.0, green: 0.549, blue: 0.0) // #FF8C00
    static let widgetNegative = Color(red: 0.906, green: 0.298, blue: 0.235) // #E74C3C
    static let widgetProgressBg = Color(red: 0.227, green: 0.227, blue: 0.306) // #3A3A4E
}

// MARK: - Small Widget View

struct VantagSmallWidgetView: View {
    let entry: VantagWidgetEntry

    var spendingColor: Color {
        switch entry.spendingLevel {
        case "medium": return .widgetWarning
        case "high": return .widgetNegative
        default: return .widgetPositive
        }
    }

    var todayLabel: String {
        entry.locale == "tr" ? "Bugün" : "Today"
    }

    var body: some View {
        HStack(spacing: 0) {
            // Spending Level Indicator
            Rectangle()
                .fill(spendingColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                // Today Label
                Text(todayLabel)
                    .font(.system(size: 11))
                    .foregroundColor(.widgetTextTertiary)
                    .tracking(0.5)

                // Time Value
                Text(entry.formattedTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.widgetTextPrimary)

                // Amount Value
                Text(entry.formattedAmount)
                    .font(.system(size: 14))
                    .foregroundColor(.widgetTextSecondary)
            }
            .padding(.leading, 12)

            Spacer()
        }
        .padding(12)
        .background(Color.widgetBackground)
    }
}

// MARK: - Medium Widget View

struct VantagMediumWidgetView: View {
    let entry: VantagWidgetEntry

    var spendingColor: Color {
        switch entry.spendingLevel {
        case "medium": return .widgetWarning
        case "high": return .widgetNegative
        default: return .widgetPositive
        }
    }

    var todayLabel: String {
        entry.locale == "tr" ? "Bugün" : "Today"
    }

    var setGoalLabel: String {
        entry.locale == "tr" ? "Hedef belirle" : "Set a goal"
    }

    var progressPercent: Double {
        guard entry.pursuitTarget > 0 else { return 0 }
        return min(entry.pursuitProgress / entry.pursuitTarget, 1.0)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left Section: Today's Spending
            HStack(spacing: 0) {
                Rectangle()
                    .fill(spendingColor)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(todayLabel)
                        .font(.system(size: 11))
                        .foregroundColor(.widgetTextTertiary)
                        .tracking(0.5)

                    Text(entry.formattedTime)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.widgetTextPrimary)

                    Text(entry.formattedAmount)
                        .font(.system(size: 13))
                        .foregroundColor(.widgetTextSecondary)
                }
                .padding(.leading, 12)
            }

            Spacer()

            // Divider
            Rectangle()
                .fill(Color.widgetTextTertiary)
                .frame(width: 1)
                .padding(.vertical, 8)

            Spacer()

            // Right Section: Pursuit
            if entry.hasPursuit && !entry.pursuitName.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.pursuitName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.widgetTextPrimary)
                        .lineLimit(1)

                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.widgetProgressBg)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.widgetAccent)
                                .frame(width: geometry.size.width * progressPercent, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(entry.pursuitProgressText)
                        .font(.system(size: 11))
                        .foregroundColor(.widgetTextSecondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 4) {
                    Text("🎯")
                        .font(.system(size: 24))

                    Text(setGoalLabel)
                        .font(.system(size: 11))
                        .foregroundColor(.widgetTextTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(Color.widgetBackground)
    }
}

// MARK: - Widget Configurations

struct VantagSmallWidget: Widget {
    let kind: String = "VantagSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VantagWidgetProvider()) { entry in
            VantagSmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Spending")
        .description("See your daily spending in work hours.")
        .supportedFamilies([.systemSmall])
    }
}

struct VantagMediumWidget: Widget {
    let kind: String = "VantagMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VantagWidgetProvider()) { entry in
            VantagMediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Spending & Goals")
        .description("Daily spending and savings goal progress.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct VantagWidgetBundle: WidgetBundle {
    var body: some Widget {
        VantagSmallWidget()
        VantagMediumWidget()
    }
}

// MARK: - Previews

struct VantagWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VantagSmallWidgetView(entry: VantagWidgetEntry(
                date: Date(),
                formattedTime: "2h 15m",
                formattedAmount: "₺450",
                spendingLevel: "low",
                pursuitName: "",
                pursuitProgressText: "",
                pursuitProgress: 0,
                pursuitTarget: 0,
                hasPursuit: false,
                locale: "tr"
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small Widget")

            VantagMediumWidgetView(entry: VantagWidgetEntry(
                date: Date(),
                formattedTime: "2h 15m",
                formattedAmount: "₺450",
                spendingLevel: "medium",
                pursuitName: "iPhone 16",
                pursuitProgressText: "120/400 s",
                pursuitProgress: 120,
                pursuitTarget: 400,
                hasPursuit: true,
                locale: "tr"
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium Widget")
        }
    }
}
