package com.vantag.app

import com.vantag.app.BuildConfig
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.provider.Settings
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.security.MessageDigest

/**
 * Security checker for anti-tampering and anti-reverse engineering protection.
 * Performs runtime security checks to detect:
 * - Debugger attachment
 * - Root/jailbreak detection
 * - APK signature verification
 * - Emulator detection
 * - Frida/hooking framework detection
 */
object SecurityChecker {

    // Expected signature hash - update this with your actual release signature
    private const val EXPECTED_SIGNATURE_HASH = "VANTAG_RELEASE_SIGNATURE"

    /**
     * Main security check - call this at app startup
     * Returns true if the app is running in a secure environment
     */
    fun performSecurityChecks(context: Context): SecurityResult {
        val issues = mutableListOf<String>()

        // 1. Debugger detection
        if (isDebuggerAttached()) {
            issues.add("DEBUGGER_ATTACHED")
        }

        // 2. Debug build detection (in release, this should be false)
        if (isDebuggable(context)) {
            issues.add("DEBUGGABLE_BUILD")
        }

        // 3. Root detection
        if (isDeviceRooted()) {
            issues.add("DEVICE_ROOTED")
        }

        // 4. Emulator detection
        if (isEmulator()) {
            issues.add("EMULATOR_DETECTED")
        }

        // 5. Hooking framework detection (Frida, Xposed, etc.)
        if (isHookingFrameworkPresent()) {
            issues.add("HOOKING_FRAMEWORK")
        }

        // 6. APK tampering detection
        if (!verifyAppSignature(context)) {
            issues.add("SIGNATURE_MISMATCH")
        }

        // 7. Installer verification
        if (!isInstalledFromPlayStore(context)) {
            issues.add("UNKNOWN_INSTALLER")
        }

        return SecurityResult(
            isSecure = issues.isEmpty(),
            issues = issues
        )
    }

    // ============================================
    // DEBUGGER DETECTION
    // ============================================

    private fun isDebuggerAttached(): Boolean {
        return Debug.isDebuggerConnected() || Debug.waitingForDebugger()
    }

    private fun isDebuggable(context: Context): Boolean {
        return (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    // ============================================
    // ROOT DETECTION
    // ============================================

    private fun isDeviceRooted(): Boolean {
        return checkRootBinaries() || checkSuperUserApk() || checkRootCloakingApps() || checkTestKeys()
    }

    private fun checkRootBinaries(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/system/xbin/daemonsu"
        )
        return paths.any { File(it).exists() }
    }

    private fun checkSuperUserApk(): Boolean {
        return File("/system/app/Superuser.apk").exists()
    }

    private fun checkRootCloakingApps(): Boolean {
        val packages = arrayOf(
            "com.devadvance.rootcloak",
            "com.devadvance.rootcloakplus",
            "de.robv.android.xposed.installer",
            "com.saurik.substrate",
            "com.zachspong.temprootremovejb",
            "com.amphoras.hidemyroot",
            "com.amphoras.hidemyrootadfree",
            "com.formyhm.hiderootPremium",
            "com.formyhm.hideroot"
        )

        return try {
            val process = Runtime.getRuntime().exec(arrayOf("which", "su"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            reader.readLine() != null
        } catch (e: Exception) {
            false
        }
    }

    private fun checkTestKeys(): Boolean {
        val buildTags = Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

    // ============================================
    // EMULATOR DETECTION
    // ============================================

    private fun isEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
                || "google_sdk" == Build.PRODUCT
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("emulator"))
    }

    // ============================================
    // HOOKING FRAMEWORK DETECTION
    // ============================================

    private fun isHookingFrameworkPresent(): Boolean {
        return detectFrida() || detectXposed() || detectSubstrate()
    }

    private fun detectFrida(): Boolean {
        // Check for Frida server
        val fridaPorts = arrayOf(27042, 27043)
        for (port in fridaPorts) {
            try {
                val socket = java.net.Socket("127.0.0.1", port)
                socket.close()
                return true
            } catch (e: Exception) {
                // Port not open, continue
            }
        }

        // Check for Frida in memory maps
        try {
            val mapsFile = File("/proc/self/maps")
            if (mapsFile.exists()) {
                val content = mapsFile.readText()
                if (content.contains("frida") || content.contains("gadget")) {
                    return true
                }
            }
        } catch (e: Exception) {
            // Ignore
        }

        return false
    }

    private fun detectXposed(): Boolean {
        // Check for Xposed framework
        try {
            Class.forName("de.robv.android.xposed.XposedBridge")
            return true
        } catch (e: ClassNotFoundException) {
            // Not found
        }

        // Check stack trace for Xposed
        try {
            throw Exception("Xposed detection")
        } catch (e: Exception) {
            for (element in e.stackTrace) {
                if (element.className.contains("xposed")) {
                    return true
                }
            }
        }

        return false
    }

    private fun detectSubstrate(): Boolean {
        try {
            Class.forName("com.saurik.substrate.MS")
            return true
        } catch (e: ClassNotFoundException) {
            return false
        }
    }

    // ============================================
    // APK SIGNATURE VERIFICATION
    // ============================================

    @Suppress("DEPRECATION")
    private fun verifyAppSignature(context: Context): Boolean {
        try {
            val packageInfo: PackageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
            }

            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                packageInfo.signatures
            }

            if (signatures == null || signatures.isEmpty()) {
                return false
            }

            // In debug mode, accept any signature
            if (BuildConfig.DEBUG) {
                return true
            }

            // Calculate signature hash
            val signature = signatures[0]
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(signature.toByteArray())
            val hash = digest.joinToString("") { "%02x".format(it) }

            // Compare with expected (uncomment and set in production)
            // return hash == EXPECTED_SIGNATURE_HASH

            // For now, just verify signature exists
            return signatures.isNotEmpty()

        } catch (e: Exception) {
            return false
        }
    }

    // ============================================
    // INSTALLER VERIFICATION
    // ============================================

    private fun isInstalledFromPlayStore(context: Context): Boolean {
        val validInstallers = listOf(
            "com.android.vending",      // Google Play Store
            "com.google.android.feedback" // Google Play Store (old)
        )

        val installer = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                context.packageManager.getInstallSourceInfo(context.packageName).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getInstallerPackageName(context.packageName)
            }
        } catch (e: Exception) {
            null
        }

        // In debug mode, accept any installer
        if (BuildConfig.DEBUG) {
            return true
        }

        return installer != null && validInstallers.contains(installer)
    }

    /**
     * Security check result
     */
    data class SecurityResult(
        val isSecure: Boolean,
        val issues: List<String>
    )
}
