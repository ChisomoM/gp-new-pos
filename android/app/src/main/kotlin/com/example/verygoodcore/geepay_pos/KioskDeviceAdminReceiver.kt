package com.geepay.geepay_pos

import android.app.admin.DeviceAdminReceiver

/**
 * Required to provision this app as the device's device owner (see the
 * kiosk-lock implementation plan's "Device-Owner Lock Task" section) --
 * `dpm set-device-owner` needs a `DeviceAdminReceiver` component to point
 * at. No overrides are needed: the capabilities this unlocks come from
 * `DevicePolicyManager` API access once device-owner status is granted
 * (checked via `isDeviceOwnerApp` in [KioskHelper]), not from anything this
 * receiver itself does.
 */
class KioskDeviceAdminReceiver : DeviceAdminReceiver()
