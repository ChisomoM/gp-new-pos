package com.geepay.geepay_pos

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Relaunches [MainActivity] after the device reboots, so a kiosk-locked
 * terminal comes back up in the app instead of sitting on the OEM launcher.
 * This receiver only starts the activity -- it does not decide whether the
 * kiosk lock should re-engage. That decision reads the persisted flag from
 * Dart (`AuthRepo.isKioskModeEnabled()`, checked in `SplashCubit`), so there
 * is a single source of truth for kiosk state instead of duplicating it into
 * native `SharedPreferences`.
 */
class BootReceiver : BroadcastReceiver() {
    companion object {
        // Not a public Android constant -- a long-standing OEM convention
        // some budget Chinese ROMs (this device's class included) broadcast
        // instead of/alongside the standard BOOT_COMPLETED on a soft restart.
        private const val ACTION_QUICKBOOT_POWERON = "android.intent.action.QUICKBOOT_POWERON"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != ACTION_QUICKBOOT_POWERON
        ) {
            return
        }

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(launchIntent)
    }
}
