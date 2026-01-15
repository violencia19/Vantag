import 'dart:io';
import 'package:flutter/services.dart';

/// Service for iOS Siri Shortcuts integration
/// Handles shortcut donations and Spotlight indexing
class SiriService {
  static final SiriService _instance = SiriService._();
  factory SiriService() => _instance;
  SiriService._();

  /// Method channel for native iOS communication
  static const _channel = MethodChannel('com.vantag.app/siri');

  /// Check if Siri is available (iOS only)
  bool get isAvailable => Platform.isIOS;

  /// Setup Siri shortcuts on app launch
  Future<void> setupShortcuts() async {
    if (!isAvailable) return;

    try {
      await _channel.invokeMethod('setupShortcuts');
    } on PlatformException catch (e) {
      // Siri not available or not configured
      print('[Siri] Setup failed: ${e.message}');
    }
  }

  /// Donate an "Add Expense" shortcut to Siri
  /// This teaches Siri about user patterns
  Future<void> donateAddExpense({
    required double amount,
    required String category,
    required String description,
  }) async {
    if (!isAvailable) return;

    try {
      await _channel.invokeMethod('donateAddExpense', {
        'amount': amount,
        'category': category,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } on PlatformException catch (e) {
      print('[Siri] Donation failed: ${e.message}');
    }
  }

  /// Donate a "View Summary" shortcut
  Future<void> donateViewSummary() async {
    if (!isAvailable) return;

    try {
      await _channel.invokeMethod('donateViewSummary');
    } on PlatformException catch (e) {
      print('[Siri] Donation failed: ${e.message}');
    }
  }

  /// Index content for Spotlight search
  Future<void> indexForSpotlight({
    required String title,
    required String description,
    String? category,
  }) async {
    if (!isAvailable) return;

    try {
      await _channel.invokeMethod('indexSpotlight', {
        'title': title,
        'description': description,
        'category': category,
      });
    } on PlatformException catch (e) {
      print('[Siri] Spotlight indexing failed: ${e.message}');
    }
  }

  /// Remove all donated shortcuts
  Future<void> clearDonations() async {
    if (!isAvailable) return;

    try {
      await _channel.invokeMethod('clearDonations');
    } on PlatformException catch (e) {
      print('[Siri] Clear donations failed: ${e.message}');
    }
  }

  /// Present the "Add to Siri" button for a specific action
  Future<void> presentAddToSiri({
    required String actionType,
    required String title,
    required String suggestedPhrase,
  }) async {
    if (!isAvailable) return;

    try {
      await _channel.invokeMethod('presentAddToSiri', {
        'actionType': actionType,
        'title': title,
        'suggestedPhrase': suggestedPhrase,
      });
    } on PlatformException catch (e) {
      print('[Siri] Present Add to Siri failed: ${e.message}');
    }
  }
}

/// iOS Native Code Reference (Swift)
/// Add to ios/Runner/AppDelegate.swift:
///
/// ```swift
/// import UIKit
/// import Flutter
/// import Intents
/// import CoreSpotlight
///
/// @UIApplicationMain
/// @objc class AppDelegate: FlutterAppDelegate {
///   override func application(
///     _ application: UIApplication,
///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
///   ) -> Bool {
///     let controller = window?.rootViewController as! FlutterViewController
///     let siriChannel = FlutterMethodChannel(name: "com.vantag.app/siri",
///                                            binaryMessenger: controller.binaryMessenger)
///
///     siriChannel.setMethodCallHandler { [weak self] (call, result) in
///       switch call.method {
///       case "setupShortcuts":
///         self?.setupShortcuts()
///         result(nil)
///
///       case "donateAddExpense":
///         if let args = call.arguments as? [String: Any] {
///           self?.donateAddExpense(args: args)
///         }
///         result(nil)
///
///       case "donateViewSummary":
///         self?.donateViewSummary()
///         result(nil)
///
///       case "clearDonations":
///         INInteraction.deleteAll { _ in }
///         result(nil)
///
///       default:
///         result(FlutterMethodNotImplemented)
///       }
///     }
///
///     GeneratedPluginRegistrant.register(with: self)
///     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
///   }
///
///   func setupShortcuts() {
///     // Setup default shortcuts
///   }
///
///   func donateAddExpense(args: [String: Any]) {
///     let activity = NSUserActivity(activityType: "com.vantag.app.addExpense")
///     activity.title = "Vantag'a Harcama Ekle"
///     activity.isEligibleForSearch = true
///     activity.isEligibleForPrediction = true
///     activity.suggestedInvocationPhrase = "Vantag harcama ekle"
///     activity.userInfo = args
///
///     if let amount = args["amount"] as? Double,
///        let category = args["category"] as? String {
///       activity.title = "\(Int(amount))₺ \(category) ekle"
///     }
///
///     activity.becomeCurrent()
///   }
///
///   func donateViewSummary() {
///     let activity = NSUserActivity(activityType: "com.vantag.app.viewSummary")
///     activity.title = "Vantag Özetini Gör"
///     activity.isEligibleForSearch = true
///     activity.isEligibleForPrediction = true
///     activity.suggestedInvocationPhrase = "Vantag özeti"
///     activity.becomeCurrent()
///   }
/// }
/// ```
