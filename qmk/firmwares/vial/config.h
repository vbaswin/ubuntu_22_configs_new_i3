#pragma once

#define VIAL_KEYBOARD_UID {0x89, 0x36, 0x2A, 0xC7, 0xFA, 0xD8, 0x89, 0x45}
#define VIAL_UNLOCK_COMBO_ROWS {0, 0}
#define VIAL_UNLOCK_COMBO_COLS {0, 1}

// ---------------------------------------------------------
// 1. SLEEP & WAKE FIXES
// ---------------------------------------------------------
// Forces the master to wait 1s for power to stabilize before searching for the
// slave
#undef USB_SUSPEND_WAKEUP_DELAY
#define USB_SUSPEND_WAKEUP_DELAY 1000

#define NO_USB_STARTUP_CHECK

#define SPLIT_USB_DETECT
#define SPLIT_USB_TIMEOUT 2500
#define SPLIT_USB_TIMEOUT_POLL 10

#define SPLIT_WATCHDOG_ENABLE
#define SPLIT_WATCHDOG_TIMEOUT 4000

// If the connection fails, try X times before giving up.
#define SPLIT_MAX_CONNECTION_ERRORS 200
#define SPLIT_CONNECTION_CHECK_TIMEOUT 200

// ---------------------------------------------------------
// 3. POWER MANAGEMENT
// ---------------------------------------------------------
// Essential for Linux: Prevents "deep sleep" which often kills the Slave connection.
#define NO_SUSPEND_POWER_DOWN
#define USB_DETACH_DEBOUNCE_MS 1000

// ---------------------------------------------------------
// 2. MOUSE TWEAKS (Trackpoint-like feel)
// ---------------------------------------------------------
#undef MOUSEKEY_INTERVAL
#define MOUSEKEY_INTERVAL 16
#undef MOUSEKEY_DELAY
#define MOUSEKEY_DELAY 0
#undef MOUSEKEY_TIME_TO_MAX
#define MOUSEKEY_TIME_TO_MAX 40
#undef MOUSEKEY_MAX_SPEED
#define MOUSEKEY_MAX_SPEED 6
#define MOUSEKEY_WHEEL_DELAY 0

// ---------------------------------------------------------
// 3. TYPING SPEED (Mod-Tap Tuning)
// ---------------------------------------------------------
// Helps prevent accidental modifier activation in Neovim
#define TAPPING_TERM 200

// Makes rolling keys output letters (sdf) instead of Modifiers (Ctrl+Shift)
// #define IGNORE_MOD_TAP_INTERRUPT
