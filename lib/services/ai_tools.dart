/// Vantag AI'nın kullanabileceği tüm tool tanımları (OpenAI Function Calling formatı)
class AITools {
  /// Tüm tool'ları OpenAI formatında döndür
  static List<Map<String, dynamic>> getAllTools() {
    return [
      // OKUMA TOOL'LARI
      _getExpensesSummary,
      _getCategoryBreakdown,
      _getSubscriptions,
      _getBudgetStatus,
      _getThinkingItems,
      _getSavedItems,

      // YAZMA TOOL'LARI
      _addExpense,
      _updateExpenseDecision,

      // HESAPLAMA TOOL'LARI
      _calculateSavingsPlan,
      _calculateHourlyEquivalent,
      _compareWithAlternative,
    ];
  }

  // ==========================================
  // OKUMA TOOL'LARI
  // ==========================================

  static final Map<String, dynamic> _getExpensesSummary = {
    'type': 'function',
    'function': {
      'name': 'get_expenses_summary',
      'description':
          'Bu ayki harcamaların özetini getirir: toplam harcama, kategori dağılımı, geçen ayla karşılaştırma',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  };

  static final Map<String, dynamic> _getCategoryBreakdown = {
    'type': 'function',
    'function': {
      'name': 'get_category_breakdown',
      'description': 'Belirli bir kategorideki harcamaların detayını getirir',
      'parameters': {
        'type': 'object',
        'properties': {
          'category': {
            'type': 'string',
            'description':
                'Kategori adı: Yiyecek, Ulaşım, Giyim, Elektronik, Eğlence, Sağlık, Eğitim, Faturalar, Abonelik, Diğer',
          },
        },
        'required': ['category'],
      },
    },
  };

  static final Map<String, dynamic> _getSubscriptions = {
    'type': 'function',
    'function': {
      'name': 'get_subscriptions',
      'description':
          'Tüm aktif abonelikleri listeler: isim, tutar, yenileme günü',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  };

  static final Map<String, dynamic> _getBudgetStatus = {
    'type': 'function',
    'function': {
      'name': 'get_budget_status',
      'description': 'Bütçe durumunu getirir: gelir, harcama, kalan, yüzde',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  };

  static final Map<String, dynamic> _getThinkingItems = {
    'type': 'function',
    'function': {
      'name': 'get_thinking_items',
      'description': 'Düşünüyorum listesindeki bekleyen harcamaları getirir',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  };

  static final Map<String, dynamic> _getSavedItems = {
    'type': 'function',
    'function': {
      'name': 'get_saved_items',
      'description':
          'Vazgeçilen harcamaları (irade zaferleri) ve Smart Choice tasarruflarını getirir',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  };

  // ==========================================
  // YAZMA TOOL'LARI
  // ==========================================

  static final Map<String, dynamic> _addExpense = {
    'type': 'function',
    'function': {
      'name': 'add_expense',
      'description':
          'Yeni harcama kaydı ekler. Kullanıcı bir harcama yaptığını söylediğinde bu tool kullanılır. Eğer duplicate_found: true dönerse, kullanıcıya sor ve onaylarsa force: true ile tekrar çağır.',
      'parameters': {
        'type': 'object',
        'properties': {
          'amount': {'type': 'number', 'description': 'Harcama tutarı'},
          'category': {
            'type': 'string',
            'description':
                'Kategori: Yiyecek, Ulaşım, Giyim, Elektronik, Eğlence, Sağlık, Eğitim, Faturalar, Abonelik, Diğer',
          },
          'description': {
            'type': 'string',
            'description': 'Harcama açıklaması (opsiyonel)',
          },
          'decision': {
            'type': 'string',
            'description':
                'Karar: yes (aldım), thinking (düşünüyorum), no (vazgeçtim)',
          },
          'currency': {
            'type': 'string',
            'description':
                'Para birimi kodu: TRY, USD, EUR, GBP. Belirtilmezse varsayılan kullanıcı para birimi kullanılır.',
          },
          'force': {
            'type': 'boolean',
            'description':
                'Duplicate uyarısını görmezden gel ve ekle (kullanıcı onayladıysa true yap)',
          },
        },
        'required': ['amount', 'category', 'decision'],
      },
    },
  };

  static final Map<String, dynamic> _updateExpenseDecision = {
    'type': 'function',
    'function': {
      'name': 'update_expense_decision',
      'description':
          'Düşünüyorum listesindeki bir harcamanın kararını günceller',
      'parameters': {
        'type': 'object',
        'properties': {
          'expense_description': {
            'type': 'string',
            'description': 'Harcamanın açıklaması veya kategorisi',
          },
          'new_decision': {
            'type': 'string',
            'description': 'Yeni karar: yes (aldım) veya no (vazgeçtim)',
          },
        },
        'required': ['expense_description', 'new_decision'],
      },
    },
  };

  // ==========================================
  // HESAPLAMA TOOL'LARI
  // ==========================================

  static final Map<String, dynamic> _calculateSavingsPlan = {
    'type': 'function',
    'function': {
      'name': 'calculate_savings_plan',
      'description': 'Belirli bir hedefe ulaşmak için tasarruf planı hesaplar',
      'parameters': {
        'type': 'object',
        'properties': {
          'target_amount': {
            'type': 'number',
            'description': 'Hedef tutar (TL)',
          },
          'target_months': {
            'type': 'integer',
            'description': 'Hedef süre (ay)',
          },
          'purpose': {
            'type': 'string',
            'description': 'Tasarruf amacı (opsiyonel)',
          },
        },
        'required': ['target_amount', 'target_months'],
      },
    },
  };

  static final Map<String, dynamic> _calculateHourlyEquivalent = {
    'type': 'function',
    'function': {
      'name': 'calculate_hourly_equivalent',
      'description':
          'Bir tutarın kaç saatlik çalışmaya denk geldiğini hesaplar',
      'parameters': {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'number',
            'description': 'Hesaplanacak tutar (TL)',
          },
        },
        'required': ['amount'],
      },
    },
  };

  static final Map<String, dynamic> _compareWithAlternative = {
    'type': 'function',
    'function': {
      'name': 'compare_with_alternative',
      'description':
          'Bir harcamayı alternatif yatırım seçenekleriyle karşılaştırır (altın, faiz, vb.)',
      'parameters': {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'number',
            'description': 'Karşılaştırılacak tutar (TL)',
          },
          'alternative': {
            'type': 'string',
            'description':
                'Alternatif: gold (altın), interest (faiz), savings (birikim)',
          },
          'period_months': {
            'type': 'integer',
            'description': 'Karşılaştırma süresi (ay)',
          },
        },
        'required': ['amount', 'alternative', 'period_months'],
      },
    },
  };
}
