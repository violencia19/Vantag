# API Documentation

This document describes the external APIs used by Vantag.

## Table of Contents
- [OpenAI API](#openai-api)
- [Google Gemini API](#google-gemini-api)
- [TCMB Currency API](#tcmb-currency-api)
- [Gold Price API](#gold-price-api)
- [RevenueCat API](#revenuecat-api)
- [Firebase Services](#firebase-services)

---

## OpenAI API

Used for the AI Financial Assistant chat feature.

### Endpoint
```
POST https://api.openai.com/v1/chat/completions
```

### Headers
```http
Authorization: Bearer $OPENAI_API_KEY
Content-Type: application/json
```

### Request Body
```json
{
  "model": "gpt-4.1",
  "messages": [
    {
      "role": "system",
      "content": "You are a Turkish financial advisor..."
    },
    {
      "role": "user",
      "content": "Bu ay nereye harcadim?"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_expenses_summary",
        "description": "Get monthly spending summary by category",
        "parameters": {
          "type": "object",
          "properties": {
            "month": { "type": "integer" },
            "year": { "type": "integer" }
          }
        }
      }
    }
  ],
  "temperature": 0.7,
  "max_tokens": 500
}
```

### Response
```json
{
  "id": "chatcmpl-xxx",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "Bu ay toplam 5.000 TL harcadiniz..."
      }
    }
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 100
  }
}
```

### Available Tools
| Tool | Description |
|------|-------------|
| `get_expenses_summary` | Monthly spending by category |
| `get_recent_expenses` | Last N expenses |
| `add_expense` | Add new expense via chat |
| `get_pursuit_progress` | Savings goal progress |

### Rate Limits
- Free tier: 5 requests/day
- Pro tier: 500 requests/month

### Service File
`lib/services/ai_service.dart`

---

## Google Gemini API

Alternative AI provider for chat and analysis.

### Endpoint
```
POST https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent
```

### Headers
```http
x-goog-api-key: $GEMINI_API_KEY
Content-Type: application/json
```

### Request Body
```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        { "text": "Analyze my spending habits" }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 500
  }
}
```

### Service File
`lib/services/ai_service.dart`

---

## TCMB Currency API

Turkish Central Bank exchange rates (official source).

### Endpoint
```
GET https://www.tcmb.gov.tr/kurlar/today.xml
```

### Response (XML)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Tarih_Date>
  <Currency Kod="USD">
    <Unit>1</Unit>
    <Isim>ABD DOLARI</Isim>
    <CurrencyName>US DOLLAR</CurrencyName>
    <ForexBuying>32.5432</ForexBuying>
    <ForexSelling>32.6123</ForexSelling>
    <BanknoteBuying>32.5100</BanknoteBuying>
    <BanknoteSelling>32.6500</BanknoteSelling>
  </Currency>
  <Currency Kod="EUR">
    <ForexBuying>35.1234</ForexBuying>
    <ForexSelling>35.2345</ForexSelling>
  </Currency>
  <!-- More currencies... -->
</Tarih_Date>
```

### Supported Currencies
| Code | Name |
|------|------|
| USD | US Dollar |
| EUR | Euro |
| GBP | British Pound |
| SAR | Saudi Riyal |

### Caching
- Rates cached for 1 hour
- Offline fallback to last known rates

### Service File
`lib/services/currency_service.dart`

---

## Gold Price API

Real-time gold prices in TRY.

### Endpoint
```
GET https://finans.truncgil.com/v4/today.json
```

### Response
```json
{
  "Update_Date": "2026-01-26 12:00:00",
  "gram-altin": {
    "Alis": "2850.50",
    "Satis": "2855.00",
    "Degisim": "0.75%"
  },
  "ceyrek-altin": {
    "Alis": "4650.00",
    "Satis": "4700.00"
  },
  "yarim-altin": {
    "Alis": "9300.00",
    "Satis": "9400.00"
  }
}
```

### Gold Types
| Key | Description |
|-----|-------------|
| `gram-altin` | 1 gram gold |
| `ceyrek-altin` | Quarter gold coin |
| `yarim-altin` | Half gold coin |
| `tam-altin` | Full gold coin |
| `cumhuriyet-altini` | Republic gold coin |

### Service File
`lib/services/currency_service.dart`

---

## RevenueCat API

In-app purchases and subscription management.

### SDK Integration
```dart
import 'package:purchases_flutter/purchases_flutter.dart';

// Initialize
await Purchases.configure(
  PurchasesConfiguration('goog_xxxxx')
    ..appUserID = userId
);

// Get offerings
final offerings = await Purchases.getOfferings();

// Purchase
final customerInfo = await Purchases.purchasePackage(package);

// Check entitlements
final isPro = customerInfo.entitlements.all['pro']?.isActive ?? false;
```

### Products
| Product ID | Type | Price |
|------------|------|-------|
| `vantag_pro_monthly` | Subscription | 49.99 TRY/month |
| `vantag_pro_yearly` | Subscription | 399.99 TRY/year |
| `vantag_lifetime` | One-time | 999.99 TRY |
| `vantag_credits_100` | Consumable | 29.99 TRY |
| `vantag_credits_500` | Consumable | 99.99 TRY |

### Entitlements
| Entitlement | Benefits |
|-------------|----------|
| `pro` | Full AI access, unlimited pursuits |
| `lifetime` | All pro features + lifetime updates |

### Webhooks
RevenueCat webhooks configured for:
- Purchase events
- Renewal events
- Cancellation events

### Service File
`lib/services/purchase_service.dart`

---

## Firebase Services

### Authentication

```dart
// Google Sign-In
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

### Firestore Paths

```
users/{uid}/
├── profile                    # UserProfile document
├── expenses/{expenseId}       # Expense documents
├── subscriptions/{id}         # Subscription documents
├── pursuits/{pursuitId}       # Pursuit documents
└── pursuit_transactions/{id}  # Transaction documents
```

### Remote Config

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `min_app_version` | String | "1.0.0" | Minimum required version |
| `recommended_app_version` | String | "1.0.3" | Recommended version |
| `paywall_variant` | String | "default" | A/B test variant |
| `onboarding_short` | Boolean | false | Short onboarding flag |

### Analytics Events

| Event | Parameters |
|-------|------------|
| `expense_added` | category, amount, decision |
| `pursuit_created` | category, target_amount |
| `ai_chat_used` | is_premium |
| `subscription_added` | name, cycle, amount |

### Crashlytics

```dart
// Log error
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'API call failed',
  fatal: false,
);

// Set user context
FirebaseCrashlytics.instance.setUserIdentifier(userId);
```

---

## Error Handling

All API calls should:
1. Use try-catch blocks
2. Log errors to Crashlytics
3. Show localized error messages
4. Provide offline fallbacks where possible

```dart
try {
  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw ApiException('Status: ${response.statusCode}');
  }
  return parseResponse(response.body);
} catch (e, stack) {
  await errorLogger.logApiError(
    endpoint: uri.toString(),
    statusCode: null,
    error: e,
    stackTrace: stack,
  );
  rethrow;
}
```

---

## Environment Variables

Required in `.env`:
```env
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=AI...
```

Firebase configuration is handled via:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
