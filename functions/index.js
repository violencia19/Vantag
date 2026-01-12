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
