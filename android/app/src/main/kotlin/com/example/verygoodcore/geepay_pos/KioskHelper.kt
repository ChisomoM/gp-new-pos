package com.example.verygoodcore.geepay_pos

import android.app.Activity
import android.util.Log
import com.topwise.cloudpos.service.DeviceServiceManager
import com.trendit.basesdk.POSDeviceManager

/**
 * Locks/unlocks this app as a single-purpose kiosk terminal, layering
 * vendor-specific hardening on top of plain Android screen pinning
 * (`Activity.startLockTask`/`stopLockTask`), which is the one mechanism that
 * works identically on every device regardless of vendor hardware.
 *
 * The Topwise and Trendit calls below are best-effort: each is wrapped in
 * its own `try/catch` so a failure (or a device that isn't that vendor's
 * hardware at all) never blocks the baseline lock or the other vendor's
 * path. Topwise's `AidlSystem.enableKioskMode`/`startKioskLockTaskMode`
 * parameters are not covered by the bundled vendor docs (those predate these
 * methods) -- the values passed here are a best guess pending on-device
 * verification; failures are logged individually so that can be diagnosed
 * from device logs rather than guessed at again.
 */
class KioskHelper {
    companion object {
        private const val TAG = "KioskHelper"

        // Trendit's `TerminalDevice.setStatusBarStatus` bitmask flags are
        // documented only as a comment in the SDK source (no accessible
        // constants class ships with the jar) -- see
        // com/trendit/basesdk/device/terminal/TerminalDevice.java.
        private const val STATUS_BAR_DISABLE_HOME = 0x00200000
        private const val STATUS_BAR_DISABLE_BACK = 0x00400000
        private const val STATUS_BAR_DISABLE_RECENT = 0x01000000
        private const val STATUS_BAR_DISABLE_EXPAND = 0x00010000
        private const val STATUS_BAR_DISABLE_NONE = 0x00000000
    }

    fun enterKiosk(activity: Activity) {
        try {
            activity.startLockTask()
        } catch (e: Throwable) {
            Log.e(TAG, "startLockTask failed", e)
        }

        enterTopwiseKiosk(activity)
        enterTrenditKiosk()
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

    private fun enterTopwiseKiosk(activity: Activity) {
        val system = try {
            DeviceServiceManager.getInstance()?.systemManager
        } catch (e: Throwable) {
            null
        } ?: return

        try {
            system.enableKioskMode(true, activity.packageName, activity.javaClass.name)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableKioskMode failed", e)
        }
        try {
            system.startKioskLockTaskMode(0)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise startKioskLockTaskMode failed", e)
        }
        try {
            system.enableHomeButton(false)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableHomeButton(false) failed", e)
        }
        try {
            system.enableBackButton(false)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableBackButton(false) failed", e)
        }
        try {
            system.enableRecentAppButton(false)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableRecentAppButton(false) failed", e)
        }
        try {
            system.enableDropDownMenu(false)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise enableDropDownMenu(false) failed", e)
        }
        try {
            system.hideLauncher3(true)
        } catch (e: Throwable) {
            Log.e(TAG, "Topwise hideLauncher3(true) failed", e)
        }
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

    private fun enterTrenditKiosk() {
        val terminal = try {
            POSDeviceManager.getInstance()?.terminalDevice
        } catch (e: Throwable) {
            null
        } ?: return

        try {
            terminal.setStatusBarStatus(
                STATUS_BAR_DISABLE_HOME or
                    STATUS_BAR_DISABLE_BACK or
                    STATUS_BAR_DISABLE_RECENT or
                    STATUS_BAR_DISABLE_EXPAND,
            )
            terminal.setStatusBarEnable(false)
        } catch (e: Throwable) {
            Log.e(TAG, "Trendit status bar lock failed", e)
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
