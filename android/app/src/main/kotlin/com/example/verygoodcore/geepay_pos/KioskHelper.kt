package com.geepay.geepay_pos

import android.app.Activity
import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.util.Log
import com.topwise.cloudpos.service.DeviceServiceManager
import com.trendit.basesdk.POSDeviceManager

/**
 * Locks/unlocks this app as a single-purpose kiosk terminal, layering
 * vendor-specific hardening on top of plain Android screen pinning
 * (`Activity.startLockTask`/`stopLockTask`), which is the one mechanism that
 * works identically on every device regardless of vendor hardware.
 *
 * The Topwise and Trendit calls below are best-effort: each is run through
 * [runCall], which wraps it in its own `try/catch` (so a failure, or a
 * device that isn't that vendor's hardware at all, never blocks the
 * baseline lock or the other vendor's path) and records the outcome.
 * [enterKiosk]'s report of those outcomes is what the Dart side surfaces as
 * a snackbar and the "locked since" status line in the kiosk-exit dialog --
 * this is also how the unverified Topwise `enableKioskMode`/
 * `startKioskLockTaskMode` parameter guesses (not covered by the bundled
 * vendor docs, which predate these methods) get diagnosed on a real device
 * instead of guessed at again.
 */
class KioskHelper {
    companion object {
        private const val TAG = "KioskHelper"

        // Trendit's `TerminalDevice.setStatusBarStatus` bitmask flags are
        // documented only as a comment in the SDK source (no accessible
        // constants class ships with the jar) -- see
        // com/trendit/basesdk/device/terminal/TerminalDevice.java.
        private const val STATUS_BAR_DISABLE_HOME = 0x00200000
        private const val STATUS_BAR_DISABLE_RECENT = 0x01000000
        private const val STATUS_BAR_DISABLE_NONE = 0x00000000
    }

    /**
     * Runs [block], records whether it succeeded into [results] as a
     * `{vendor, name, success, error}` map (the shape the Dart side
     * expects), and never lets [block]'s failure propagate.
     */
    private fun runCall(
        results: MutableList<Map<String, Any?>>,
        vendor: String,
        name: String,
        block: () -> Unit,
    ) {
        try {
            block()
            results.add(mapOf("vendor" to vendor, "name" to name, "success" to true, "error" to null))
        } catch (e: Throwable) {
            Log.e(TAG, "$vendor $name failed", e)
            results.add(
                mapOf("vendor" to vendor, "name" to name, "success" to false, "error" to e.message),
            )
        }
    }

    /**
     * Engages the kiosk lock and returns a report of what was attempted:
     * `{"calls": [{"vendor", "name", "success", "error"}, ...]}`, one entry
     * per call (`vendor` is `"baseline"`, `"topwise"` or `"trendit"`) --
     * exactly what actually ran, so the Dart side can tell "baseline-only
     * emulator" apart from "Topwise, 2 of 7 calls failed".
     */
    fun enterKiosk(activity: Activity): Map<String, Any?> {
        val results = mutableListOf<Map<String, Any?>>()
        configureDeviceOwnerLockTask(activity, results)
        runCall(results, "baseline", "startLockTask") { activity.startLockTask() }
        enterTopwiseKiosk(activity, results)
        enterTrenditKiosk(results)
        return mapOf("calls" to results)
    }

    /**
     * Whether the kiosk lock is currently engaged, per the OS itself (not a
     * cached flag) -- used by the Settings screen's tap gesture to decide
     * whether to show the PIN-exit dialog or just re-lock immediately.
     */
    fun isKioskActive(activity: Activity): Boolean = try {
        val am = activity.getSystemService(ActivityManager::class.java)
        am?.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
    } catch (e: Throwable) {
        true
    }

    /**
     * If this app has been provisioned as the device's device owner (a
     * manual, one-time `adb shell dpm set-device-owner` step per device --
     * see the implementation plan), whitelist it for lock task and disable
     * every system-UI escape feature. This makes the *existing*
     * `activity.startLockTask()` call below automatically become true
     * (non-escapable) lock task instead of mere screen pinning -- no
     * separate "start" call is needed here. On a non-provisioned device
     * `isDeviceOwnerApp` is false and this is a silent no-op, so nothing
     * else about kiosk mode changes.
     */
    private fun configureDeviceOwnerLockTask(activity: Activity, results: MutableList<Map<String, Any?>>) {
        val dpm = activity.getSystemService(DevicePolicyManager::class.java) ?: return
        if (!dpm.isDeviceOwnerApp(activity.packageName)) return

        val admin = ComponentName(activity, KioskDeviceAdminReceiver::class.java)
        runCall(results, "deviceOwner", "setLockTaskPackages") {
            dpm.setLockTaskPackages(admin, arrayOf(activity.packageName))
        }
        runCall(results, "deviceOwner", "setLockTaskFeatures") {
            // SYSTEM_INFO alone: shows the status bar's clock/battery/
            // network icons. NOTIFICATIONS (the pullable shade/quick
            // settings) is deliberately NOT requested -- Android's
            // DevicePolicyManagerService rejects NOTIFICATIONS unless HOME
            // is also set (confirmed via logcat: setLockTaskFeatures threw
            // a RemoteException from Preconditions.checkArgument when we
            // tried SYSTEM_INFO|NOTIFICATIONS without HOME), and keeping
            // Home blocked was the explicit choice here. See the kiosk-lock
            // implementation plan's "Follow-up 2" section.
            dpm.setLockTaskFeatures(admin, DevicePolicyManager.LOCK_TASK_FEATURE_SYSTEM_INFO)
        }
    }

    fun exitKiosk(activity: Activity) {
        exitTopwiseKiosk()
        exitTrenditKiosk()

        try {
            activity.stopLockTask()
        } catch (e: Throwable) {
            Log.e(TAG, "stopLockTask failed", e)
        }
    }

    private fun enterTopwiseKiosk(activity: Activity, results: MutableList<Map<String, Any?>>) {
        val system = try {
            DeviceServiceManager.getInstance()?.systemManager
        } catch (e: Throwable) {
            null
        } ?: return

        runCall(results, "topwise", "enableKioskMode") {
            system.enableKioskMode(true, activity.packageName, activity.javaClass.name)
        }
        runCall(results, "topwise", "startKioskLockTaskMode") {
            system.startKioskLockTaskMode(0)
        }
        runCall(results, "topwise", "enableHomeButton") { system.enableHomeButton(false) }
        runCall(results, "topwise", "enableBackButton") { system.enableBackButton(false) }
        runCall(results, "topwise", "enableRecentAppButton") {
            system.enableRecentAppButton(false)
        }
        runCall(results, "topwise", "enableDropDownMenu") { system.enableDropDownMenu(false) }
        runCall(results, "topwise", "hideLauncher3") { system.hideLauncher3(true) }
    }

    private fun exitTopwiseKiosk() {
        val system = try {
            DeviceServiceManager.getInstance()?.systemManager
        } catch (e: Throwable) {
            null
        } ?: return

        try {
            system.stopSystemLockTaskMode()
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise stopSystemLockTaskMode failed", e)
        }
        try {
            system.enableKioskMode(false, "", "")
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableKioskMode(false) failed", e)
        }
        try {
            system.enableHomeButton(true)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableHomeButton(true) failed", e)
        }
        try {
            system.enableBackButton(true)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableBackButton(true) failed", e)
        }
        try {
            system.enableRecentAppButton(true)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableRecentAppButton(true) failed", e)
        }
        try {
            system.enableDropDownMenu(true)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableDropDownMenu(true) failed", e)
        }
        try {
            system.hideLauncher3(false)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise hideLauncher3(false) failed", e)
        }
    }

    private fun enterTrenditKiosk(results: MutableList<Map<String, Any?>>) {
        val terminal = try {
            POSDeviceManager.getInstance()?.terminalDevice
        } catch (e: Throwable) {
            null
        } ?: return

        // Only Home/Recent are blocked here -- the status bar/notification
        // shade and Back stay available on Trendit for now (see the
        // kiosk-lock implementation plan's "Follow-up 2" section).
        runCall(results, "trendit", "setStatusBarStatus") {
            terminal.setStatusBarStatus(STATUS_BAR_DISABLE_HOME or STATUS_BAR_DISABLE_RECENT)
        }
    }

    private fun exitTrenditKiosk() {
        val terminal = try {
            POSDeviceManager.getInstance()?.terminalDevice
        } catch (e: Throwable) {
            null
        } ?: return

        try {
            terminal.setStatusBarEnable(true)
            terminal.setStatusBarStatus(STATUS_BAR_DISABLE_NONE)
        } catch (e: Throwable) {
            Log.e(TAG, "Trendit status bar unlock failed", e)
        }
    }
}
