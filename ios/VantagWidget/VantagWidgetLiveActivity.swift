//
//  VantagWidgetLiveActivity.swift
//  VantagWidget
//
//  Dynamic Island and Live Activity for Vantag
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes

struct VantagActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var streakDays: Int
        var todaySpent: Double
        var dailyBudget: Double
        var currencySymbol: String
        var formattedTime: String
        var spendingLevel: String // "low", "medium", "high"
    }

    // Fixed properties
    var activityId: String
}

// MARK: - Colors

extension Color {
    static let liveActivityBg = Color(red: 0.102, green: 0.102, blue: 0.180)
    static let liveActivityAccent = Color(red: 0.424, green: 0.388, blue: 1.0)
    static let liveActivityPositive = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let liveActivityWarning = Color(red: 0.961, green: 0.620, blue: 0.043)
    static let liveActivityNegative = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let liveActivityTeal = Color(red: 0.176, green: 0.831, blue: 0.749)
}

// MARK: - Live Activity Widget

struct VantagWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VantagActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Regions
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }
            } compactLeading: {
                // Compact Leading - Streak
                CompactLeadingView(context: context)
            } compactTrailing: {
                // Compact Trailing - Progress
                CompactTrailingView(context: context)
            } minimal: {
                // Minimal - Just streak emoji
                MinimalView(context: context)
            }
            .widgetURL(URL(string: "vantag://live-activity"))
            .keylineTint(Color.liveActivityAccent)
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var spendingColor: Color {
        switch context.state.spendingLevel {
        case "medium": return .liveActivityWarning
        case "high": return .liveActivityNegative
        default: return .liveActivityPositive
        }
    }

    var progressPercent: Double {
        guard context.state.dailyBudget > 0 else { return 0 }
        return min(context.state.todaySpent / context.state.dailyBudget, 1.0)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Streak Badge
            VStack(spacing: 2) {
                Text("🔥")
                    .font(.system(size: 24))
                Text("\(context.state.streakDays)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 50)

            // Spending Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Bugun")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Text(context.state.formattedTime)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(spendingColor)
                            .frame(width: geometry.size.width * progressPercent, height: 6)
                    }
                }
                .frame(height: 6)
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(context.state.currencySymbol)\(Int(context.state.todaySpent))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("/ \(context.state.currencySymbol)\(Int(context.state.dailyBudget))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .activityBackgroundTint(Color.liveActivityBg)
        .activitySystemActionForegroundColor(Color.white)
    }
}

// MARK: - Dynamic Island Views

struct CompactLeadingView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var body: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.system(size: 14))
            Text("\(context.state.streakDays)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.liveActivityWarning)
        }
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var spendingColor: Color {
        switch context.state.spendingLevel {
        case "medium": return .liveActivityWarning
        case "high": return .liveActivityNegative
        default: return .liveActivityPositive
        }
    }

    var progressPercent: Double {
        guard context.state.dailyBudget > 0 else { return 0 }
        return min(context.state.todaySpent / context.state.dailyBudget, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                .frame(width: 24, height: 24)

            Circle()
                .trim(from: 0, to: progressPercent)
                .stroke(spendingColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-90))
        }
    }
}

struct MinimalView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var body: some View {
        Text("🔥")
            .font(.system(size: 16))
    }
}

struct ExpandedLeadingView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 20))
                Text("\(context.state.streakDays) gun")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.liveActivityWarning)
            }
            Text("Seri")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }
}

struct ExpandedTrailingView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(context.state.currencySymbol)\(Int(context.state.todaySpent))")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("bugun")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }
}

struct ExpandedCenterView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var body: some View {
        Text(context.state.formattedTime)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
}

struct ExpandedBottomView: View {
    let context: ActivityViewContext<VantagActivityAttributes>

    var spendingColor: Color {
        switch context.state.spendingLevel {
        case "medium": return .liveActivityWarning
        case "high": return .liveActivityNegative
        default: return .liveActivityPositive
        }
    }

    var progressPercent: Double {
        guard context.state.dailyBudget > 0 else { return 0 }
        return min(context.state.todaySpent / context.state.dailyBudget, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [spendingColor, spendingColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercent, height: 8)
                }
            }
            .frame(height: 8)

            // Budget Info
            HStack {
                Text("Gunluk butce")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(context.state.currencySymbol)\(Int(context.state.dailyBudget))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Previews

extension VantagActivityAttributes {
    fileprivate static var preview: VantagActivityAttributes {
        VantagActivityAttributes(activityId: "preview")
    }
}

extension VantagActivityAttributes.ContentState {
    fileprivate static var lowSpending: VantagActivityAttributes.ContentState {
        VantagActivityAttributes.ContentState(
            streakDays: 5,
            todaySpent: 150,
            dailyBudget: 500,
            currencySymbol: "₺",
            formattedTime: "1s 30dk",
            spendingLevel: "low"
        )
    }

    fileprivate static var highSpending: VantagActivityAttributes.ContentState {
        VantagActivityAttributes.ContentState(
            streakDays: 12,
            todaySpent: 450,
            dailyBudget: 500,
            currencySymbol: "₺",
            formattedTime: "4s 15dk",
            spendingLevel: "high"
        )
    }
}

#Preview("Lock Screen - Low", as: .content, using: VantagActivityAttributes.preview) {
    VantagWidgetLiveActivity()
} contentStates: {
    VantagActivityAttributes.ContentState.lowSpending
}

#Preview("Lock Screen - High", as: .content, using: VantagActivityAttributes.preview) {
    VantagWidgetLiveActivity()
} contentStates: {
    VantagActivityAttributes.ContentState.highSpending
}
