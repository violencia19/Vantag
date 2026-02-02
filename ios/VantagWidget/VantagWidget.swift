//
//  VantagWidget.swift
//  VantagWidget
//
//  Custom widget for Vantag - displays spending in work hours
//

import WidgetKit
import SwiftUI

// MARK: - Widget Data

struct VantagWidgetEntry: TimelineEntry {
    let date: Date
    let formattedTime: String
    let formattedAmount: String
    let spendingLevel: String // "low", "medium", "high"
    let pursuitName: String
    let pursuitProgressText: String
    let pursuitProgress: Double
    let pursuitTarget: Double
    let hasPursuit: Bool
    let streakDays: Int
    let locale: String

    static var placeholder: VantagWidgetEntry {
        VantagWidgetEntry(
            date: Date(),
            formattedTime: "0s 0dk",
            formattedAmount: "₺0",
            spendingLevel: "low",
            pursuitName: "",
            pursuitProgressText: "",
            pursuitProgress: 0,
            pursuitTarget: 0,
            hasPursuit: false,
            streakDays: 0,
            locale: "tr"
        )
    }
}

// MARK: - Timeline Provider

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
            formattedTime: userDefaults?.string(forKey: "formattedTime") ?? "0s 0dk",
            formattedAmount: userDefaults?.string(forKey: "formattedAmount") ?? "₺0",
            spendingLevel: userDefaults?.string(forKey: "spendingLevel") ?? "low",
            pursuitName: userDefaults?.string(forKey: "pursuitName") ?? "",
            pursuitProgressText: userDefaults?.string(forKey: "pursuitProgressText") ?? "",
            pursuitProgress: userDefaults?.double(forKey: "pursuitProgress") ?? 0,
            pursuitTarget: userDefaults?.double(forKey: "pursuitTarget") ?? 0,
            hasPursuit: userDefaults?.bool(forKey: "hasPursuit") ?? false,
            streakDays: userDefaults?.integer(forKey: "streakDays") ?? 0,
            locale: userDefaults?.string(forKey: "locale") ?? "tr"
        )
    }
}

// MARK: - Colors

extension Color {
    static let widgetBackground = Color(red: 0.102, green: 0.102, blue: 0.180) // #1A1A2E
    static let widgetSurface = Color(red: 0.145, green: 0.145, blue: 0.227) // #25253A
    static let widgetTextPrimary = Color.white
    static let widgetTextSecondary = Color(red: 0.690, green: 0.690, blue: 0.690) // #B0B0B0
    static let widgetTextTertiary = Color(red: 0.416, green: 0.416, blue: 0.478) // #6A6A7A
    static let widgetAccent = Color(red: 0.424, green: 0.388, blue: 1.0) // #6C63FF
    static let widgetPositive = Color(red: 0.063, green: 0.725, blue: 0.506) // #10B981 - green
    static let widgetWarning = Color(red: 0.961, green: 0.620, blue: 0.043) // #F59E0B - yellow/orange
    static let widgetNegative = Color(red: 0.937, green: 0.267, blue: 0.267) // #EF4444 - red
    static let widgetProgressBg = Color(red: 0.227, green: 0.227, blue: 0.306) // #3A3A4E
    static let widgetTeal = Color(red: 0.176, green: 0.831, blue: 0.749) // #2DD4BF
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
        entry.locale == "tr" ? "Bugun" : "Today"
    }

    var body: some View {
        ZStack {
            Color.widgetBackground

            HStack(spacing: 0) {
                // Spending Level Indicator
                Rectangle()
                    .fill(spendingColor)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 6) {
                    // Today Label with streak
                    HStack(spacing: 4) {
                        Text(todayLabel.uppercased())
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.widgetTextTertiary)
                            .tracking(1)

                        if entry.streakDays > 0 {
                            HStack(spacing: 2) {
                                Text("🔥")
                                    .font(.system(size: 10))
                                Text("\(entry.streakDays)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.widgetWarning)
                            }
                        }
                    }

                    // Time Value
                    Text(entry.formattedTime)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.widgetTextPrimary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    // Amount Value
                    Text(entry.formattedAmount)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.widgetTextSecondary)
                }
                .padding(.leading, 12)
                .padding(.vertical, 12)

                Spacer()
            }
        }
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
        entry.locale == "tr" ? "Bugun" : "Today"
    }

    var setGoalLabel: String {
        entry.locale == "tr" ? "Hedef belirle" : "Set a goal"
    }

    var progressPercent: Double {
        guard entry.pursuitTarget > 0 else { return 0 }
        return min(entry.pursuitProgress / entry.pursuitTarget, 1.0)
    }

    var body: some View {
        ZStack {
            Color.widgetBackground

            HStack(spacing: 0) {
                // Left Section: Today's Spending
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(spendingColor)
                        .frame(width: 4)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text(todayLabel.uppercased())
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.widgetTextTertiary)
                                .tracking(1)

                            if entry.streakDays > 0 {
                                HStack(spacing: 2) {
                                    Text("🔥")
                                        .font(.system(size: 10))
                                    Text("\(entry.streakDays)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.widgetWarning)
                                }
                            }
                        }

                        Text(entry.formattedTime)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.widgetTextPrimary)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)

                        Text(entry.formattedAmount)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.widgetTextSecondary)
                    }
                    .padding(.leading, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Rectangle()
                    .fill(Color.widgetTextTertiary.opacity(0.3))
                    .frame(width: 1)
                    .padding(.vertical, 12)

                // Right Section: Pursuit
                if entry.hasPursuit && !entry.pursuitName.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🎯")
                                .font(.system(size: 12))
                            Text(entry.pursuitName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.widgetTextPrimary)
                                .lineLimit(1)
                        }

                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.widgetProgressBg)
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.widgetAccent, .widgetTeal],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progressPercent, height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text(entry.pursuitProgressText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.widgetTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 6) {
                        Text("🎯")
                            .font(.system(size: 28))

                        Text(setGoalLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.widgetTextTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Widget Configurations

struct VantagSmallWidget: Widget {
    let kind: String = "VantagSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VantagWidgetProvider()) { entry in
            VantagSmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Gunluk Harcama")
        .description("Bugunun harcamasini calisma saati olarak gor.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct VantagMediumWidget: Widget {
    let kind: String = "VantagMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VantagWidgetProvider()) { entry in
            VantagMediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Harcama ve Hedefler")
        .description("Gunluk harcama ve tasarruf hedefi ilerlemesi.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Previews

#Preview("Small - Low", as: .systemSmall) {
    VantagSmallWidget()
} timeline: {
    VantagWidgetEntry(
        date: Date(),
        formattedTime: "2s 15dk",
        formattedAmount: "₺450",
        spendingLevel: "low",
        pursuitName: "",
        pursuitProgressText: "",
        pursuitProgress: 0,
        pursuitTarget: 0,
        hasPursuit: false,
        streakDays: 5,
        locale: "tr"
    )
}

#Preview("Medium - With Pursuit", as: .systemMedium) {
    VantagMediumWidget()
} timeline: {
    VantagWidgetEntry(
        date: Date(),
        formattedTime: "2s 15dk",
        formattedAmount: "₺450",
        spendingLevel: "medium",
        pursuitName: "iPhone 16",
        pursuitProgressText: "120/400 saat",
        pursuitProgress: 120,
        pursuitTarget: 400,
        hasPursuit: true,
        streakDays: 12,
        locale: "tr"
    )
}
