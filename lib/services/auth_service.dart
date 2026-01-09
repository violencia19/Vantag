import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase kullanıcı profil modeli (Auth bilgileri için)
/// NOT: Bu sınıf models/user_profile.dart'taki UserProfile'dan farklıdır.
/// O model gelir/çalışma saatleri için, bu model Firebase Auth bilgileri için.
class FirebaseUserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const FirebaseUserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.isAnonymous,
    required this.createdAt,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'isAnonymous': isAnonymous,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
      };

  factory FirebaseUserProfile.fromJson(Map<String, dynamic> json) =>
      FirebaseUserProfile(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String?,
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
        isAnonymous: json['isAnonymous'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      );

  factory FirebaseUserProfile.fromFirebaseUser(User user) => FirebaseUserProfile(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
      );
}

/// Auth sonuç wrapper'ı
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;
  final bool wasLinked;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.wasLinked = false,
  });

  factory AuthResult.success(User user, {bool wasLinked = false}) => AuthResult(
        success: true,
        user: user,
        wasLinked: wasLinked,
      );

  factory AuthResult.failure(String message) => AuthResult(
        success: false,
        errorMessage: message,
      );
}

/// Authentication Service
/// Anonim giriş, Google Sign-In ve hesap birleştirme işlemlerini yönetir
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GoogleSignIn instance - scopes ile birlikte
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı oturum açmış mı?
  bool get isSignedIn => currentUser != null;

  /// Kullanıcı anonim mi?
  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  /// Kullanıcı Google ile bağlı mı?
  bool get isLinkedWithGoogle {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ═══════════════════════════════════════════════════════════════════════════
  // ANONİM GİRİŞ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Anonim giriş yap (ilk açılışta)
  Future<AuthResult> signInAnonymously() async {
    print("🔐 [Auth] Anonim giriş başlıyor...");

    try {
      // Zaten giriş yapılmışsa mevcut kullanıcıyı döndür
      if (currentUser != null) {
        print("ℹ️ [Auth] Zaten giriş yapılmış - UID: ${currentUser!.uid}");
        return AuthResult.success(currentUser!);
      }

      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        print("✅ [Auth] Anonim giriş başarılı - UID: ${user.uid}");
        await _saveUserProfile(user);
        return AuthResult.success(user);
      } else {
        print("❌ [Auth] Anonim giriş başarısız - user null");
        return AuthResult.failure("Anonim giriş başarısız");
      }
    } on FirebaseAuthException catch (e) {
      print("❌ [Auth] Firebase Auth Hatası: ${e.code} - ${e.message}");
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      print("❌ [Auth] Beklenmeyen Hata: $e");
      return AuthResult.failure("Giriş sırasında bir hata oluştu");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Google ile giriş yap
  /// Eğer anonim kullanıcı varsa, hesapları birleştirir (linkWithCredential)
  Future<AuthResult> signInWithGoogle() async {
    print("🔐 [Auth] Google Sign-In başlıyor...");

    try {
      // 1. Önce mevcut Google oturumunu kapat (temiz başlangıç için)
      await _googleSignIn.signOut();

      // 2. Google Sign-In dialog'unu göster
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("ℹ️ [Auth] Kullanıcı Google Sign-In'i iptal etti");
        return AuthResult.failure("Giriş iptal edildi");
      }

      print("📧 [Auth] Google hesabı seçildi: ${googleUser.email}");

      // 3. Google Auth credential al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Mevcut anonim kullanıcı var mı kontrol et
      final existingUser = currentUser;
      final wasAnonymous = existingUser?.isAnonymous ?? false;

      User? user;
      bool wasLinked = false;

      if (wasAnonymous && existingUser != null) {
        // Anonim hesabı Google ile birleştir
        print("🔗 [Auth] Anonim hesap Google ile birleştiriliyor...");
        try {
          final linkedCredential =
              await existingUser.linkWithCredential(credential);
          user = linkedCredential.user;
          wasLinked = true;
          print("✅ [Auth] Hesaplar birleştirildi! UID korundu: ${user?.uid}");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            // Bu Google hesabı başka bir hesaba bağlı
            print("⚠️ [Auth] Google hesabı zaten kullanımda, yeni hesapla giriş yapılıyor...");
            await existingUser.delete();
            final signInResult = await _auth.signInWithCredential(credential);
            user = signInResult.user;
            wasLinked = false;
          } else {
            rethrow;
          }
        }
      } else {
        // Direkt Google ile giriş yap
        print("🔐 [Auth] Google ile direkt giriş yapılıyor...");
        final signInResult = await _auth.signInWithCredential(credential);
        user = signInResult.user;
      }

      if (user != null) {
        print("✅ [Auth] Google Sign-In başarılı!");
        print("   UID: ${user.uid}");
        print("   Email: ${user.email}");
        print("   İsim: ${user.displayName}");
        print("   Birleştirildi mi: $wasLinked");

        await _saveUserProfile(user);
        return AuthResult.success(user, wasLinked: wasLinked);
      } else {
        return AuthResult.failure("Google ile giriş başarısız");
      }
    } on FirebaseAuthException catch (e) {
      print("❌ [Auth] Firebase Auth Hatası: ${e.code} - ${e.message}");
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      print("❌ [Auth] Beklenmeyen Hata: $e");
      return AuthResult.failure("Google ile giriş sırasında bir hata oluştu: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ÇIKIŞ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Çıkış yap
  Future<void> signOut() async {
    print("🚪 [Auth] Çıkış yapılıyor...");

    try {
      // Google Sign-Out
      try {
        await _googleSignIn.signOut();
        print("✅ [Auth] Google Sign-Out başarılı");
      } catch (e) {
        print("⚠️ [Auth] Google Sign-Out hatası: $e");
      }

      // Firebase Sign-Out
      await _auth.signOut();
      print("✅ [Auth] Firebase Sign-Out başarılı");
    } catch (e) {
      print("❌ [Auth] Çıkış hatası: $e");
    }
  }

  /// Hesabı sil (dikkatli kullan!)
  Future<AuthResult> deleteAccount() async {
    print("🗑️ [Auth] Hesap siliniyor...");

    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure("Silinecek hesap yok");
      }

      // Firestore verilerini sil
      await _deleteUserData(user.uid);

      // Hesabı sil
      await user.delete();

      print("✅ [Auth] Hesap silindi");
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return AuthResult.failure(
            "Bu işlem için yeniden giriş yapmanız gerekiyor");
      }
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure("Hesap silinirken hata oluştu");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIRESTORE PROFİL İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Kullanıcı profilini Firestore'a kaydet
  Future<void> _saveUserProfile(User user) async {
    print("💾 [Auth] Profil Firestore'a kaydediliyor...");

    try {
      final profileDoc = _firestore.collection('users').doc(user.uid);

      // Ana profil dökümanı
      await profileDoc.set({
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'isAnonymous': user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'providers': user.providerData.map((p) => p.providerId).toList(),
      }, SetOptions(merge: true));

      print("✅ [Auth] Profil kaydedildi!");
      print("   Path: users/${user.uid}");
      print("   Email: ${user.email ?? 'Anonim'}");
      print("   İsim: ${user.displayName ?? 'Anonim Kullanıcı'}");
    } on FirebaseException catch (e) {
      print("❌ [Auth] Profil kaydetme hatası: ${e.code} - ${e.message}");
    } catch (e) {
      print("❌ [Auth] Beklenmeyen profil hatası: $e");
    }
  }

  /// Kullanıcı profilini Firestore'dan getir
  Future<FirebaseUserProfile?> getFirebaseUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return FirebaseUserProfile.fromJson(doc.data()!);
      }

      // Firestore'da yoksa Firebase User'dan oluştur
      return FirebaseUserProfile.fromFirebaseUser(user);
    } catch (e) {
      print("❌ [Auth] Profil getirme hatası: $e");
      return null;
    }
  }

  /// Kullanıcı verilerini sil
  Future<void> _deleteUserData(String uid) async {
    try {
      print("🗑️ [Auth] Kullanıcı verileri siliniyor...");

      // Expenses subcollection
      final expenses = await _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .get();

      final batch = _firestore.batch();

      for (final doc in expenses.docs) {
        batch.delete(doc.reference);
      }

      // Ana profil dökümanı
      batch.delete(_firestore.collection('users').doc(uid));

      await batch.commit();
      print("✅ [Auth] Kullanıcı verileri silindi");
    } catch (e) {
      print("❌ [Auth] Veri silme hatası: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // YARDIMCI METODLAR
  // ═══════════════════════════════════════════════════════════════════════════

  /// Firebase Auth hata mesajlarını Türkçe'ye çevir
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanımda';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi etkin değil';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta farklı bir giriş yöntemiyle kayıtlı';
      case 'credential-already-in-use':
        return 'Bu hesap başka bir kullanıcıya bağlı';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapın';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen bekleyin';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      default:
        return 'Bir hata oluştu ($code)';
    }
  }

  /// Debug: Auth durumunu yazdır
  void debugAuthStatus() {
    final user = currentUser;
    print("═══════════════════════════════════════════════════════════");
    print("🔍 [DEBUG] Auth Durumu:");
    print("   Giriş yapılmış: ${isSignedIn ? 'Evet' : 'Hayır'}");
    print("   UID: ${user?.uid ?? 'null'}");
    print("   Anonim: ${isAnonymous ? 'Evet' : 'Hayır'}");
    print("   Google bağlı: ${isLinkedWithGoogle ? 'Evet' : 'Hayır'}");
    print("   Email: ${user?.email ?? 'Yok'}");
    print("   İsim: ${user?.displayName ?? 'Yok'}");
    print("   Providers: ${user?.providerData.map((p) => p.providerId).join(', ') ?? 'Yok'}");
    print("═══════════════════════════════════════════════════════════");
  }
}
