import Flutter
import UIKit
import Intents
import CoreSpotlight

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var siriChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Setup Siri Method Channel
        if let controller = window?.rootViewController as? FlutterViewController {
            siriChannel = FlutterMethodChannel(
                name: "com.vantag.app/siri",
                binaryMessenger: controller.binaryMessenger
            )

            siriChannel?.setMethodCallHandler { [weak self] (call, result) in
                switch call.method {
                case "setupShortcuts":
                    self?.setupShortcuts()
                    result(true)
                case "donateAddExpense":
                    if let args = call.arguments as? [String: Any] {
                        self?.donateAddExpense(args: args)
                    }
                    result(true)
                case "donateViewReport":
                    self?.donateViewReport()
                    result(true)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Siri Shortcuts Setup

    private func setupShortcuts() {
        // Add Expense Shortcut
        let addExpenseActivity = NSUserActivity(activityType: "com.vantag.app.addExpense")
        addExpenseActivity.title = "Harcama Ekle"
        addExpenseActivity.userInfo = ["action": "addExpense"]
        addExpenseActivity.isEligibleForSearch = true
        addExpenseActivity.isEligibleForPrediction = true
        addExpenseActivity.suggestedInvocationPhrase = "Vantag'a harcama ekle"
        addExpenseActivity.persistentIdentifier = "com.vantag.app.addExpense"

        let attributes = CSSearchableItemAttributeSet(itemContentType: "public.item")
        attributes.contentDescription = "Yeni bir harcama kaydet"
        addExpenseActivity.contentAttributeSet = attributes

        // View Report Shortcut
        let viewReportActivity = NSUserActivity(activityType: "com.vantag.app.viewReport")
        viewReportActivity.title = "Raporu Goster"
        viewReportActivity.userInfo = ["action": "viewReport"]
        viewReportActivity.isEligibleForSearch = true
        viewReportActivity.isEligibleForPrediction = true
        viewReportActivity.suggestedInvocationPhrase = "Vantag raporumu goster"
        viewReportActivity.persistentIdentifier = "com.vantag.app.viewReport"

        let reportAttributes = CSSearchableItemAttributeSet(itemContentType: "public.item")
        reportAttributes.contentDescription = "Harcama raporunu goruntule"
        viewReportActivity.contentAttributeSet = reportAttributes

        // Index for Spotlight
        indexForSpotlight()
    }

    private func donateAddExpense(args: [String: Any]) {
        let activity = NSUserActivity(activityType: "com.vantag.app.addExpense")
        activity.title = "Harcama Ekle"

        if let amount = args["amount"] as? Double,
           let category = args["category"] as? String {
            activity.userInfo = [
                "action": "addExpense",
                "amount": amount,
                "category": category
            ]
        }

        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.becomeCurrent()
    }

    private func donateViewReport() {
        let activity = NSUserActivity(activityType: "com.vantag.app.viewReport")
        activity.title = "Raporu Goster"
        activity.userInfo = ["action": "viewReport"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.becomeCurrent()
    }

    private func indexForSpotlight() {
        let addExpenseAttributes = CSSearchableItemAttributeSet(itemContentType: "public.item")
        addExpenseAttributes.title = "Harcama Ekle"
        addExpenseAttributes.contentDescription = "Vantag'a yeni harcama ekle"
        addExpenseAttributes.keywords = ["harcama", "ekle", "para", "butce", "vantag"]

        let addExpenseItem = CSSearchableItem(
            uniqueIdentifier: "com.vantag.app.addExpense",
            domainIdentifier: "com.vantag.app",
            attributeSet: addExpenseAttributes
        )

        let viewReportAttributes = CSSearchableItemAttributeSet(itemContentType: "public.item")
        viewReportAttributes.title = "Harcama Raporu"
        viewReportAttributes.contentDescription = "Vantag harcama raporunu gor"
        viewReportAttributes.keywords = ["rapor", "harcama", "analiz", "vantag"]

        let viewReportItem = CSSearchableItem(
            uniqueIdentifier: "com.vantag.app.viewReport",
            domainIdentifier: "com.vantag.app",
            attributeSet: viewReportAttributes
        )

        CSSearchableIndex.default().indexSearchableItems([addExpenseItem, viewReportItem]) { error in
            if let error = error {
                print("[Spotlight] Indexing error: \(error.localizedDescription)")
            } else {
                print("[Spotlight] Successfully indexed shortcuts")
            }
        }
    }

    // MARK: - Handle Siri/Spotlight Continuation

    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let action = userActivity.userInfo?["action"] as? String {
            siriChannel?.invokeMethod("handleShortcut", arguments: ["action": action])
            return true
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}
