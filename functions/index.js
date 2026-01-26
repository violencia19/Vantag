/**
 * Vantag Exchange Rate Cloud Function
 *
 * Scheduled to run every hour to fetch and store exchange rates.
 * Data sources:
 * - Frankfurter API: EUR, GBP rates (USD base)
 * - TCMB: TRY rates
 * - Metals.live: Gold prices
 *
 * Firestore path: app_data/exchange_rates
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// API URLs
const FRANKFURTER_API = "https://api.frankfurter.app/latest?from=USD&to=EUR,GBP,SAR";
const EXCHANGERATE_API = "https://api.exchangerate-api.com/v4/latest/USD";
const TCMB_API = "https://www.tcmb.gov.tr/kurlar/today.xml";
const METALS_LIVE_API = "https://api.metals.live/v1/spot/gold";
const TRUNCGIL_GOLD_API = "https://finans.truncgil.com/v4/today.json";

// Firestore document path
const RATES_DOC_PATH = "app_data/exchange_rates";

/**
 * Fetch rates from Frankfurter API (EUR, GBP, SAR)
 * Returns rates relative to 1 USD
 */
async function fetchFrankfurterRates() {
  try {
    const response = await fetch(FRANKFURTER_API, {
      headers: {"Accept": "application/json"},
      timeout: 10000,
    });

    if (!response.ok) {
      throw new Error(`Frankfurter API error: ${response.status}`);
    }

    const data = await response.json();
    return {
      EUR: data.rates.EUR || null,
      GBP: data.rates.GBP || null,
      SAR: data.rates.SAR || 3.75, // SAR is pegged to USD
    };
  } catch (error) {
    console.error("Frankfurter API error:", error.message);
    return null;
  }
}

/**
 * Fetch all rates from ExchangeRate API (backup)
 */
async function fetchExchangeRateApi() {
  try {
    const response = await fetch(EXCHANGERATE_API, {
      headers: {"Accept": "application/json"},
      timeout: 10000,
    });

    if (!response.ok) {
      throw new Error(`ExchangeRate API error: ${response.status}`);
    }

    const data = await response.json();
    return data.rates || null;
  } catch (error) {
    console.error("ExchangeRate API error:", error.message);
    return null;
  }
}

/**
 * Fetch TRY rates from TCMB (Central Bank of Turkey)
 * Returns USD/TRY and EUR/TRY
 */
async function fetchTCMBRates() {
  try {
    const response = await fetch(TCMB_API, {
      headers: {
        "Accept": "application/xml",
        "User-Agent": "Mozilla/5.0",
      },
      timeout: 10000,
    });

    if (!response.ok) {
      throw new Error(`TCMB API error: ${response.status}`);
    }

    const xml = await response.text();

    // Parse USD rate
    const usdMatch = xml.match(/<Currency[^>]*CurrencyCode="USD"[^>]*>[\s\S]*?<ForexSelling>([0-9.]+)<\/ForexSelling>/);
    const usdTry = usdMatch ? parseFloat(usdMatch[1]) : null;

    // Parse EUR rate
    const eurMatch = xml.match(/<Currency[^>]*CurrencyCode="EUR"[^>]*>[\s\S]*?<ForexSelling>([0-9.]+)<\/ForexSelling>/);
    const eurTry = eurMatch ? parseFloat(eurMatch[1]) : null;

    // Parse GBP rate
    const gbpMatch = xml.match(/<Currency[^>]*CurrencyCode="GBP"[^>]*>[\s\S]*?<ForexSelling>([0-9.]+)<\/ForexSelling>/);
    const gbpTry = gbpMatch ? parseFloat(gbpMatch[1]) : null;

    return {
      USD_TRY: usdTry,
      EUR_TRY: eurTry,
      GBP_TRY: gbpTry,
    };
  } catch (error) {
    console.error("TCMB API error:", error.message);
    return null;
  }
}

/**
 * Fetch gold price from Metals.live API
 * Returns USD per troy ounce
 */
async function fetchGoldPrice() {
  try {
    const response = await fetch(METALS_LIVE_API, {
      headers: {"Accept": "application/json"},
      timeout: 5000,
    });

    if (!response.ok) {
      throw new Error(`Metals.live API error: ${response.status}`);
    }

    const data = await response.json();
    if (Array.isArray(data) && data.length > 0 && data[0].price) {
      return {
        usdPerOz: data[0].price,
        source: "metals.live",
      };
    }

    throw new Error("Invalid gold data format");
  } catch (error) {
    console.error("Metals.live API error:", error.message);
    return null;
  }
}

/**
 * Fetch gold price from Truncgil API (Turkish source, backup)
 * Returns TRY per gram
 */
async function fetchTruncgilGold() {
  try {
    const response = await fetch(TRUNCGIL_GOLD_API, {
      headers: {"Accept": "application/json"},
      timeout: 5000,
    });

    if (!response.ok) {
      throw new Error(`Truncgil API error: ${response.status}`);
    }

    const data = await response.json();
    const goldData = data.GRA; // Gram Altın

    if (goldData && goldData.Selling) {
      return {
        tryPerGram: parseFloat(goldData.Selling),
        source: "truncgil",
      };
    }

    throw new Error("Invalid Truncgil gold data");
  } catch (error) {
    console.error("Truncgil API error:", error.message);
    return null;
  }
}

/**
 * Main function to fetch all rates and compile them
 */
async function fetchAllRates() {
  console.log("Fetching exchange rates...");

  // Fetch from all sources in parallel
  const [frankfurter, exchangeRateApi, tcmb, goldMetals, goldTruncgil] = await Promise.all([
    fetchFrankfurterRates(),
    fetchExchangeRateApi(),
    fetchTCMBRates(),
    fetchGoldPrice(),
    fetchTruncgilGold(),
  ]);

  // Build rates object (all relative to 1 USD)
  const rates = {
    USD: 1.0,
  };

  // Use ExchangeRate API as primary, Frankfurter as backup
  if (exchangeRateApi) {
    rates.EUR = exchangeRateApi.EUR || null;
    rates.GBP = exchangeRateApi.GBP || null;
    rates.TRY = exchangeRateApi.TRY || null;
    rates.SAR = exchangeRateApi.SAR || 3.75;
  } else if (frankfurter) {
    rates.EUR = frankfurter.EUR;
    rates.GBP = frankfurter.GBP;
    rates.SAR = frankfurter.SAR;
  }

  // Override TRY with TCMB (more accurate for Turkey)
  if (tcmb && tcmb.USD_TRY) {
    rates.TRY = tcmb.USD_TRY;
  }

  // Build cross rates
  const crossRates = {};

  if (rates.EUR) {
    crossRates.EUR_USD = parseFloat((1 / rates.EUR).toFixed(4));
  }
  if (rates.GBP) {
    crossRates.GBP_USD = parseFloat((1 / rates.GBP).toFixed(4));
  }
  if (rates.TRY) {
    crossRates.USD_TRY = rates.TRY;
  }
  if (tcmb && tcmb.EUR_TRY) {
    crossRates.EUR_TRY = tcmb.EUR_TRY;
  } else if (rates.EUR && rates.TRY) {
    crossRates.EUR_TRY = parseFloat((rates.TRY / rates.EUR).toFixed(4));
  }
  if (tcmb && tcmb.GBP_TRY) {
    crossRates.GBP_TRY = tcmb.GBP_TRY;
  } else if (rates.GBP && rates.TRY) {
    crossRates.GBP_TRY = parseFloat((rates.TRY / rates.GBP).toFixed(4));
  }

  // Build gold object
  const gold = {};

  if (goldMetals && goldMetals.usdPerOz) {
    gold.usdPerOz = goldMetals.usdPerOz;
    gold.source = "metals.live";

    // Calculate TRY per gram (1 oz = 31.1035 grams)
    if (rates.TRY) {
      gold.tryPerGram = parseFloat(((goldMetals.usdPerOz * rates.TRY) / 31.1035).toFixed(2));
    }
  }

  // Use Truncgil for TRY gold price if available (more accurate for Turkey)
  if (goldTruncgil && goldTruncgil.tryPerGram) {
    gold.tryPerGram = goldTruncgil.tryPerGram;

    // Calculate USD per oz from TRY gold if we don't have it
    if (!gold.usdPerOz && rates.TRY) {
      gold.usdPerOz = parseFloat(((goldTruncgil.tryPerGram * 31.1035) / rates.TRY).toFixed(2));
      gold.source = "truncgil";
    }
  }

  return {
    rates,
    crossRates,
    gold,
    sources: {
      rates: exchangeRateApi ? "exchangerate-api" : (frankfurter ? "frankfurter" : "none"),
      try: tcmb ? "tcmb" : "exchangerate-api",
      gold: gold.source || "none",
    },
  };
}

/**
 * Scheduled Cloud Function - Runs every hour
 * Fetches exchange rates and writes to Firestore
 */
exports.updateExchangeRates = functions
  .region("europe-west1") // Use region close to Turkey
  .pubsub
  .schedule("0 * * * *") // Every hour at minute 0
  .timeZone("Europe/Istanbul")
  .onRun(async (context) => {
    console.log("Starting scheduled exchange rate update...");

    try {
      const ratesData = await fetchAllRates();

      // Add metadata
      const document = {
        ...ratesData,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        scheduledAt: context.timestamp || new Date().toISOString(),
      };

      // Write to Firestore
      await db.doc(RATES_DOC_PATH).set(document, {merge: false});

      console.log("Exchange rates updated successfully:", {
        rates: ratesData.rates,
        gold: ratesData.gold,
        sources: ratesData.sources,
      });

      return null;
    } catch (error) {
      console.error("Failed to update exchange rates:", error);
      throw error;
    }
  });

/**
 * HTTP endpoint to manually trigger rate update (for testing)
 * URL: https://europe-west1-<project>.cloudfunctions.net/manualUpdateRates
 */
exports.manualUpdateRates = functions
  .region("europe-west1")
  .https
  .onRequest(async (req, res) => {
    // Only allow POST requests
    if (req.method !== "POST" && req.method !== "GET") {
      res.status(405).send("Method not allowed");
      return;
    }

    console.log("Manual exchange rate update triggered...");

    try {
      const ratesData = await fetchAllRates();

      const document = {
        ...ratesData,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        manualTrigger: true,
        triggeredAt: new Date().toISOString(),
      };

      await db.doc(RATES_DOC_PATH).set(document, {merge: false});

      res.status(200).json({
        success: true,
        message: "Exchange rates updated",
        data: ratesData,
      });
    } catch (error) {
      console.error("Manual update failed:", error);
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  });

/**
 * HTTP endpoint to get current rates from Firestore
 * URL: https://europe-west1-<project>.cloudfunctions.net/getRates
 */
exports.getRates = functions
  .region("europe-west1")
  .https
  .onRequest(async (req, res) => {
    // Enable CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "GET");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    try {
      const doc = await db.doc(RATES_DOC_PATH).get();

      if (!doc.exists) {
        res.status(404).json({
          success: false,
          error: "No rates available",
        });
        return;
      }

      const data = doc.data();
      res.status(200).json({
        success: true,
        data: {
          rates: data.rates,
          crossRates: data.crossRates,
          gold: data.gold,
          updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
        },
      });
    } catch (error) {
      console.error("Get rates failed:", error);
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  });

// ============================================================================
// AI CHAT CLOUD FUNCTION
// ============================================================================

const OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";
// AI Chat uses GPT-4o for high-quality responses
// Voice/Statement parsing uses gpt-4o-mini (handled client-side)
const OPENAI_MODEL = "gpt-4o";

// Rate limits
const LIMITS = {
  free: {daily: 5},
  pro: {monthly: 500},
  lifetime: {monthly: 100},
};

/**
 * Get OpenAI API key from environment
 */
function getOpenAIKey() {
  // Try Firebase functions config first, then environment variable
  const config = functions.config();
  return config.openai?.key || process.env.OPENAI_API_KEY || null;
}

/**
 * Get user's AI usage document reference and data
 */
async function getUserUsage(userId) {
  const now = new Date();
  const today = now.toISOString().split("T")[0]; // YYYY-MM-DD
  const month = today.substring(0, 7); // YYYY-MM

  const usageRef = db.collection("users").doc(userId).collection("ai_usage").doc("current");
  const usageDoc = await usageRef.get();

  let usage = {
    dailyCount: 0,
    dailyDate: today,
    monthlyCount: 0,
    monthlyDate: month,
    purchasedCredits: 0,
  };

  if (usageDoc.exists) {
    const data = usageDoc.data();
    usage = {
      dailyCount: data.dailyDate === today ? (data.dailyCount || 0) : 0,
      dailyDate: today,
      monthlyCount: data.monthlyDate === month ? (data.monthlyCount || 0) : 0,
      monthlyDate: month,
      purchasedCredits: data.purchasedCredits || 0,
    };
  }

  return {ref: usageRef, usage};
}

/**
 * Check if user has exceeded their limit
 * Returns: { allowed: boolean, remainingQuota: number, resetDate: string|null }
 */
function checkLimit(usage, subscriptionType) {
  const now = new Date();

  if (subscriptionType === "free") {
    const limit = LIMITS.free.daily;
    const remaining = Math.max(0, limit - usage.dailyCount);
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);

    return {
      allowed: usage.dailyCount < limit,
      remainingQuota: remaining,
      resetDate: tomorrow.toISOString(),
      limitType: "daily",
    };
  }

  if (subscriptionType === "pro") {
    const limit = LIMITS.pro.monthly;
    const remaining = Math.max(0, limit - usage.monthlyCount);
    const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    return {
      allowed: usage.monthlyCount < limit,
      remainingQuota: remaining,
      resetDate: nextMonth.toISOString(),
      limitType: "monthly",
    };
  }

  if (subscriptionType === "lifetime") {
    const baseLimit = LIMITS.lifetime.monthly;
    const totalLimit = baseLimit + usage.purchasedCredits;
    const remaining = Math.max(0, totalLimit - usage.monthlyCount);
    const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    return {
      allowed: usage.monthlyCount < totalLimit,
      remainingQuota: remaining,
      resetDate: nextMonth.toISOString(),
      limitType: "monthly",
      purchasedCredits: usage.purchasedCredits,
    };
  }

  // Unknown subscription type - treat as free
  return checkLimit(usage, "free");
}

/**
 * Increment usage counter
 */
async function incrementUsage(usageRef, usage, subscriptionType) {
  const updateData = {
    dailyCount: usage.dailyCount + 1,
    dailyDate: usage.dailyDate,
    monthlyCount: usage.monthlyCount + 1,
    monthlyDate: usage.monthlyDate,
    purchasedCredits: usage.purchasedCredits,
    lastUsedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await usageRef.set(updateData, {merge: true});

  return updateData;
}

/**
 * Build system prompt for AI
 * @param {boolean} isPremium - Whether user is premium
 * @param {string} language - User's language code ('tr' or 'en')
 */
function buildSystemPrompt(isPremium, language = 'tr') {
  const isEnglish = language === 'en';

  const premiumInstructions = isPremium
    ? (isEnglish ? `
PREMIUM USER - FULL ACCESS:
- Provide detailed analysis and personal savings plans.
- Specific advice: "Buy from this store instead of that one"
- Suggest long-term goals and strategies.
` : `
PREMIUM KULLANICI - TAM ERİŞİM:
- Detaylı analiz ve kişisel tasarruf planı ver.
- Spesifik tavsiyeler: "Şu market yerine şuradan alışveriş yap"
- Uzun vadeli hedefler ve stratejiler öner.
`)
    : (isEnglish ? `
FREE USER - LIMITED ACCESS:
- Keep responses SHORT, only give general numbers.
- Do NOT give specific advice (e.g., "Buy from this store instead").
- Do NOT provide detailed analysis, only summaries.
- Do NOT provide personal savings plans.
- Max 2-3 sentences.
- Do NOT write upsell messages (will be shown in UI).
` : `
FREE KULLANICI - KISITLI ERİŞİM:
- Cevabı KISA tut, sadece genel rakamları ver.
- Spesifik tavsiye VERME (örn: "Şu market yerine şuradan al").
- Detaylı analiz YAPMA, sadece özet ver.
- Kişisel tasarruf planı VERME.
- Max 2-3 cümle.
- Cevap sonunda upsell mesajı YAZMA (UI'da gösterilecek).
`);

  return isEnglish ? `
YOU ARE A FINANCIAL ASSISTANT - VANTAG.

⚠️ CRITICAL LANGUAGE REQUIREMENT:
You MUST respond ONLY in English. No matter what language the user writes in, you MUST answer in English.
Do NOT use Turkish words or phrases. All responses must be 100% English.

${premiumInstructions}

⚠️ MANDATORY TOOL USAGE (MOST IMPORTANT RULE):
For each question, FIRST call the relevant tool, THEN respond:
- Budget/spending/savings questions → get_expenses_summary OR get_recent_expenses
- If user mentions spending → add_expense
- NEVER say "I don't know you", "no data" → call tool, get data, then talk!
- NEVER give financial advice without calling a tool!

IDENTITY:
- Friendly, casual tone. Be honest and direct but constructive.

ADDING EXPENSES (add_expense):
- If user says "I spent X", "I bought Y", "I ate Z", use add_expense tool.
- Category: Food, Transport, Entertainment, Shopping, Bills, Health, Education, Other
- CURRENCY DETECTION: If user specifies different currency, fill the currency parameter.

RESPONSE RULES:
1. Convert numbers to LIFE COST: "X = Y hours of work"
2. Don't comment on things you don't know
3. PRAISE willpower victories, motivate.
4. Give concrete actions: "Cut this", "Delay that"
5. Max 3-4 sentences, no filler.

PROHIBITIONS:
- Giving financial advice without calling a tool
- "Maybe", "you could consider", "you might" - vague phrases
- Emoji spam (max 1)
- Evasive answers like "I don't know you", "no data"
` : `
SEN BİR FİNANSAL ASİSTANSIN - VANTAG.

⚠️ KRİTİK DİL GEREKSİNİMİ:
MUTLAKA Türkçe cevap ver. Kullanıcı hangi dilde yazarsa yazsın, sen MUTLAKA Türkçe cevap ver.
İngilizce kelime veya ifade KULLANMA. Tüm cevaplar %100 Türkçe olmalı.

${premiumInstructions}

⚠️ ZORUNLU TOOL KULLANIMI (EN ÖNEMLİ KURAL):
Her soruda ÖNCE ilgili tool'u çağır, SONRA cevap ver:
- Harcama/bütçe/tasarruf soruları → get_expenses_summary VEYA get_recent_expenses
- Kullanıcı harcama söylüyorsa → add_expense
- ASLA "seni tanımıyorum", "verin yok" DEME → tool çağır, veri al, sonra konuş!
- Tool çağırmadan ASLA finansal tavsiye verme!

KİMLİK:
- Samimi, "sen/kanka" de. Dürüst ve sert ol ama yapıcı.

HARCAMA EKLEME (add_expense):
- Kullanıcı "X TL harcadım", "Y aldım", "Z yedim" gibi şeyler söylerse add_expense tool'unu kullan.
- Kategori: Yiyecek, Ulaşım, Eğlence, Alışveriş, Fatura, Sağlık, Eğitim, Diğer
- PARA BİRİMİ ALGILAMA: Kullanıcı farklı para birimi belirtirse currency parametresini doldur.

CEVAP KURALLARI:
1. Rakamları HAYAT MALİYETİNE çevir: "X TL = Y saat çalışman"
2. Bilmediğin şey hakkında YORUM YAPMA
3. İrade zaferlerini ÖV, motive et.
4. Somut aksiyon ver: "Şunu kes", "Bunu ertele"
5. Max 3-4 cümle, boş laf yapma.

YASAKLAR:
- Tool çağırmadan finansal tavsiye vermek
- "Belki", "düşünebilirsin", "değerlendirebilirsin" - belirsiz laflar
- Emoji spam (max 1)
- "Seni tanımıyorum", "verin yok" gibi kaçamak cevaplar
`;
}

/**
 * AI Tools definitions for OpenAI function calling
 * @param {string} language - User's language code ('tr' or 'en')
 */
function getAITools(language = 'tr') {
  const isEnglish = language === 'en';

  return [
    {
      type: "function",
      function: {
        name: "get_expenses_summary",
        description: isEnglish
          ? "Gets this month's expense summary: total spending, category breakdown"
          : "Bu ayki harcamaların özetini getirir: toplam harcama, kategori dağılımı",
        parameters: {type: "object", properties: {}, required: []},
      },
    },
    {
      type: "function",
      function: {
        name: "get_category_breakdown",
        description: isEnglish
          ? "Gets detailed expenses for a specific category"
          : "Belirli bir kategorideki harcamaların detayını getirir",
        parameters: {
          type: "object",
          properties: {
            category: {type: "string", description: isEnglish ? "Category name" : "Kategori adı"},
          },
          required: ["category"],
        },
      },
    },
    {
      type: "function",
      function: {
        name: "add_expense",
        description: isEnglish
          ? "Adds a new expense record"
          : "Yeni harcama kaydı ekler",
        parameters: {
          type: "object",
          properties: {
            amount: {type: "number", description: isEnglish ? "Expense amount" : "Harcama tutarı"},
            category: {type: "string", description: isEnglish ? "Category" : "Kategori"},
            description: {type: "string", description: isEnglish ? "Description" : "Açıklama"},
            decision: {type: "string", description: "yes/thinking/no"},
            currency: {type: "string", description: isEnglish ? "Currency: TRY, USD, EUR, GBP" : "Para birimi: TRY, USD, EUR, GBP"},
          },
          required: ["amount", "category", "decision"],
        },
      },
    },
    {
      type: "function",
      function: {
        name: "get_budget_status",
        description: isEnglish
          ? "Gets the current budget status"
          : "Bütçe durumunu getirir",
        parameters: {type: "object", properties: {}, required: []},
      },
    },
    {
      type: "function",
      function: {
        name: "calculate_hourly_equivalent",
        description: isEnglish
          ? "Calculates how many hours of work an amount equals"
          : "Bir tutarın kaç saatlik çalışmaya denk geldiğini hesaplar",
        parameters: {
          type: "object",
          properties: {
            amount: {type: "number", description: isEnglish ? "Amount" : "Tutar"},
          },
          required: ["amount"],
        },
      },
    },
  ];
}

/**
 * Call OpenAI API
 * @param {Array} messages - Chat messages
 * @param {string} apiKey - OpenAI API key
 * @param {string} language - User's language code ('tr' or 'en')
 */
async function callOpenAI(messages, apiKey, language = 'tr') {
  const response = await fetch(OPENAI_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: OPENAI_MODEL,
      messages: messages,
      tools: getAITools(language),
      tool_choice: "auto",
      max_tokens: 500,
      temperature: 0.7,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`OpenAI API error: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return data.choices[0].message;
}

/**
 * AI Chat Cloud Function
 * URL: https://europe-west1-<project>.cloudfunctions.net/aiChat
 *
 * Request body:
 * {
 *   message: string,
 *   userId: string,
 *   isPremium: boolean,
 *   subscriptionType: "free" | "pro" | "lifetime",
 *   tools?: array (optional - tool definitions from client),
 *   toolResults?: array (optional - tool results for follow-up)
 * }
 *
 * Response:
 * {
 *   response: string,
 *   remainingQuota: number,
 *   toolCalls?: array (if AI wants to call tools)
 * }
 *
 * Error response:
 * {
 *   error: "LIMIT_EXCEEDED" | "INVALID_REQUEST" | "API_ERROR",
 *   resetDate?: string,
 *   remainingQuota?: number
 * }
 */
exports.aiChat = functions
  .region("europe-west1")
  .runWith({
    timeoutSeconds: 60,
    memory: "256MB",
  })
  .https
  .onRequest(async (req, res) => {
    // Enable CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({error: "METHOD_NOT_ALLOWED"});
      return;
    }

    // Validate request
    const {message, userId, isPremium, subscriptionType, toolResults, language} = req.body;

    if (!message || !userId) {
      res.status(400).json({error: "INVALID_REQUEST", message: "message and userId required"});
      return;
    }

    // Default language to Turkish
    const userLanguage = language || 'tr';

    // Get API key
    const apiKey = getOpenAIKey();
    if (!apiKey) {
      console.error("OpenAI API key not configured");
      res.status(500).json({error: "API_ERROR", message: "API key not configured"});
      return;
    }

    try {
      // Get user usage
      const {ref: usageRef, usage} = await getUserUsage(userId);
      const subType = subscriptionType || (isPremium ? "pro" : "free");

      // Check limits
      const limitCheck = checkLimit(usage, subType);

      if (!limitCheck.allowed) {
        console.log(`User ${userId} exceeded ${limitCheck.limitType} limit`);
        res.status(429).json({
          error: "LIMIT_EXCEEDED",
          resetDate: limitCheck.resetDate,
          remainingQuota: 0,
          limitType: limitCheck.limitType,
        });
        return;
      }

      // Build messages
      const systemPrompt = buildSystemPrompt(isPremium || subType !== "free", userLanguage);
      const messages = [
        {role: "system", content: systemPrompt},
      ];

      // Add tool results if this is a follow-up
      if (toolResults && Array.isArray(toolResults)) {
        for (const result of toolResults) {
          if (result.role === "assistant" && result.tool_calls) {
            messages.push(result);
          } else if (result.role === "tool") {
            messages.push(result);
          }
        }
      }

      // Add user message
      messages.push({role: "user", content: message});

      // Call OpenAI
      console.log(`Calling OpenAI for user ${userId} (lang: ${userLanguage})...`);
      const aiResponse = await callOpenAI(messages, apiKey, userLanguage);

      // Check if AI wants to call tools
      if (aiResponse.tool_calls && aiResponse.tool_calls.length > 0) {
        // Return tool calls to client for execution
        res.status(200).json({
          response: aiResponse.content || "",
          toolCalls: aiResponse.tool_calls,
          remainingQuota: limitCheck.remainingQuota,
          requiresToolExecution: true,
        });
        return;
      }

      // Increment usage (only count when we return a final response)
      await incrementUsage(usageRef, usage, subType);

      // Return response
      const responseText = (aiResponse.content || "").trim();
      const newRemaining = Math.max(0, limitCheck.remainingQuota - 1);

      console.log(`AI response for user ${userId}: ${responseText.substring(0, 50)}...`);

      res.status(200).json({
        response: responseText || "Analiz yapamadım, tekrar sorar mısın?",
        remainingQuota: newRemaining,
      });
    } catch (error) {
      console.error("AI Chat error:", error);

      if (error.message?.includes("429")) {
        res.status(429).json({error: "RATE_LIMITED", message: "OpenAI rate limit"});
        return;
      }

      res.status(500).json({
        error: "API_ERROR",
        message: error.message || "Unknown error",
      });
    }
  });

/**
 * Add a user to promo_users collection (admin endpoint)
 * URL: https://europe-west1-<project>.cloudfunctions.net/addPromoUser
 *
 * Request body:
 * {
 *   uid: string,
 *   email: string,
 *   type: "tester" | "gift" | "influencer"
 * }
 */
exports.addPromoUser = functions
  .region("europe-west1")
  .https
  .onRequest(async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({error: "METHOD_NOT_ALLOWED"});
      return;
    }

    const {uid, email, type} = req.body;

    if (!uid) {
      res.status(400).json({error: "INVALID_REQUEST", message: "uid required"});
      return;
    }

    const promoType = type || "tester";

    try {
      await db.collection("promo_users").doc(uid).set({
        email: email || null,
        type: promoType,
        grantedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Added ${uid} to promo_users as ${promoType}`);

      res.status(200).json({
        success: true,
        uid: uid,
        type: promoType,
      });
    } catch (error) {
      console.error("Add promo user error:", error);
      res.status(500).json({error: "SERVER_ERROR", message: error.message});
    }
  });

/**
 * Add purchased credits to user's account
 * Called after successful credit purchase via RevenueCat webhook
 */
exports.addAICredits = functions
  .region("europe-west1")
  .https
  .onRequest(async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({error: "METHOD_NOT_ALLOWED"});
      return;
    }

    const {userId, credits} = req.body;

    if (!userId || !credits || credits <= 0) {
      res.status(400).json({error: "INVALID_REQUEST"});
      return;
    }

    try {
      const usageRef = db.collection("users").doc(userId).collection("ai_usage").doc("current");

      await usageRef.set({
        purchasedCredits: admin.firestore.FieldValue.increment(credits),
        lastCreditPurchase: admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});

      console.log(`Added ${credits} AI credits for user ${userId}`);

      res.status(200).json({
        success: true,
        creditsAdded: credits,
      });
    } catch (error) {
      console.error("Add credits error:", error);
      res.status(500).json({error: "SERVER_ERROR"});
    }
  });
