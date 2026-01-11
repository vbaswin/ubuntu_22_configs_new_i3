#include QMK_KEYBOARD_H
#include "qmk_settings.h" // <--- REQUIRED: Access to internal settings

// ---------------------------------------------------------
// FORCE "IGNORE MOD TAP INTERRUPT"
// ---------------------------------------------------------
// This function runs every time the keyboard starts.
// It overrides whatever is in the EEPROM/Settings to ensure
// your preferred typing rule is ALWAYS active.
void keyboard_post_init_user(void) {
  // QS.tapping Bit 1 (Value 2) controls "Ignore Mod Tap Interrupt"
  // (technically it disables 'Hold On Other Key Press')
  QS.tapping |= 2;
}

#ifdef LAYOUT_split_3x6_3_ex2
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT_split_3x6_3_ex2(
        //,--------------------------------------------------------------.		,--------------------------------------------------------------.
        XXXXXXX, KC_Q, KC_W, KC_E, KC_R, KC_T, XXXXXXX, XXXXXXX, KC_Y, KC_U, KC_I, KC_O, KC_P, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|		|--------+--------+--------+--------+--------+--------+--------|
        KC_CAPS, LALT_T(KC_A), LGUI_T(KC_S), LCTL_T(KC_D), LSFT_T(KC_F), KC_G, XXXXXXX, XXXXXXX, KC_H, RSFT_T(KC_J), RCTL_T(KC_K), RGUI_T(KC_L), RALT_T(KC_SCLN), XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------'		`--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, KC_Z, KC_X, KC_C, KC_V, KC_B, KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------.		,--------+--------+--------+--------+--------+--------+--------|
        LT(2, KC_TAB), KC_SPC, LT(1, KC_ESC), LT(3, KC_ENT), LT(4, KC_BSPC), LT(5, KC_DEL)
        //`--------------------------'		`--------------------------'

        ),

    [1] = LAYOUT_split_3x6_3_ex2(
        //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
        XXXXXXX, XXXXXXX, KC_ACL2, KC_ACL1, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_WH_L, KC_WH_D, KC_WH_U, KC_WH_R, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, XXXXXXX, KC_BTN3, KC_BTN2, KC_BTN1, XXXXXXX, XXXXXXX, XXXXXXX, KC_MS_L, KC_MS_D, KC_MS_U, KC_MS_R, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_WH_L, KC_WH_D, KC_WH_U, KC_WH_R, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
        KC_TAB, KC_SPC, KC_ESC, KC_ENT, KC_BSPC, KC_DEL
        //`--------------------------'		`--------------------------'
        ),

    [2] = LAYOUT_split_3x6_3_ex2(
        //,--------------------------------------------------------------.  ,---------------------)-----------------------------------------.
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, EE_CLR, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, KC_LALT, KC_LGUI, KC_LCTL, KC_LSFT, XXXXXXX, XXXXXXX, XXXXXXX, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_HOME, KC_PGDN, KC_PGUP, KC_END, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
        KC_TAB, KC_SPC, KC_ESC, KC_ENT, KC_BSPC, KC_DEL
        //`--------------------------'		`--------------------------'
        ),
    [3] = LAYOUT_split_3x6_3_ex2(
        //,--------------------------------------------------------------.			,--------------------------------------------------------------.
        XXXXXXX, LSFT(KC_1), LSFT(KC_2), LSFT(KC_3), LSFT(KC_4), XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, LSFT(KC_5), LSFT(KC_6), LSFT(KC_7), LSFT(KC_GRV), XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|			|--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, LSFT(KC_QUOT), KC_LBRC, LSFT(KC_LBRC), LSFT(KC_9), LSFT(KC_COMM), XXXXXXX, XXXXXXX, LSFT(KC_DOT), LSFT(KC_0), LSFT(KC_RBRC), KC_RBRC, KC_QUOT, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------'		`	--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, LSFT(KC_BSLS), KC_BSLS, LSFT(KC_MINS), KC_EQL, XXXXXXX, XXXXXXX, KC_MINS, LSFT(KC_EQL), LSFT(KC_8), LSFT(KC_SLSH), XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------.			,--------+--------+--------+--------+--------+--------+--------|
        KC_TAB, KC_SPC, KC_ESC, KC_ENT, KC_BSPC, KC_DEL
        //`--------------------------'			`--------------------------'
        ),
    [4] = LAYOUT_split_3x6_3_ex2(
        //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
        XXXXXXX, XXXXXXX, XXXXXXX, KC_0, KC_9, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, KC_4, KC_3, KC_2, KC_1, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_RSFT, KC_RCTL, KC_RGUI, KC_RALT, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, KC_8, KC_7, KC_6, KC_5, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
        KC_TAB, KC_SPC, KC_ESC, KC_ENT, KC_BSPC, KC_DEL
        //`--------------------------'			`--------------------------'
        ),

    [5] = LAYOUT_split_3x6_3_ex2(
        //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
        XXXXXXX, KC_F12, KC_F11, KC_F10, KC_F9, XXXXXXX, XXXXXXX, EE_CLR, XXXXXXX, KC_BRID, KC_BRIU, KC_VOLD, KC_VOLU, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, KC_F4, KC_F3, KC_F2, KC_F1, XXXXXXX, XXXXXXX, XXXXXXX, RGB_TOG, KC_WBAK, KC_WFWD, KC_PSCR, KC_MUTE, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
        XXXXXXX, KC_F8, KC_F7, KC_F6, KC_F5, XXXXXXX, RGB_MOD, RGB_VAD, RGB_VAI, RGB_HUD, RGB_HUI, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
        KC_TAB, KC_SPC, KC_ESC, KC_ENT, KC_BSPC, KC_DEL
        //`--------------------------'			`--------------------------'
        )};

#else
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT_split_3x6_3(
        //,-----------------------------------------------------.
        //,-----------------------------------------------------.
        KC_TAB, KC_Q, KC_W, KC_E, KC_R, KC_T, KC_Y, KC_U, KC_I, KC_O, KC_P, KC_BSPC,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        KC_LCTL, KC_A, KC_S, KC_D, KC_F, KC_G, KC_H, KC_J, KC_K, KC_L, KC_SCLN, KC_QUOT,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        KC_LSFT, KC_Z, KC_X, KC_C, KC_V, KC_B, KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH, KC_ESC,
        //|--------+--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------+--------|
        KC_LGUI, TL_LOWR, KC_SPC, KC_ENT, TL_UPPR, KC_RALT
        //`--------------------------'  `--------------------------'

        ),

    [1] = LAYOUT_split_3x6_3(
        //,-----------------------------------------------------.
        //,-----------------------------------------------------.
        KC_TAB, KC_1, KC_2, KC_3, KC_4, KC_5, KC_6, KC_7, KC_8, KC_9, KC_0, KC_BSPC,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        KC_LCTL, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_LEFT, KC_DOWN, KC_UP, KC_RIGHT, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        KC_LSFT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------+--------|
        KC_LGUI, _______, KC_SPC, KC_ENT, _______, KC_RALT
        //`--------------------------'  `--------------------------'
        ),

    [2] = LAYOUT_split_3x6_3(
        //,-----------------------------------------------------.
        //,-----------------------------------------------------.
        KC_TAB, KC_EXLM, KC_AT, KC_HASH, KC_DLR, KC_PERC, KC_CIRC, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN, KC_BSPC,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        KC_LCTL, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_MINS, KC_EQL, KC_LBRC, KC_RBRC, KC_BSLS, KC_GRV,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        KC_LSFT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_UNDS, KC_PLUS, KC_LCBR, KC_RCBR, KC_PIPE, KC_TILD,
        //|--------+--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------+--------|
        KC_LGUI, _______, KC_SPC, KC_ENT, _______, KC_RALT
        //`--------------------------'  `--------------------------'
        ),

    [3] = LAYOUT_split_3x6_3(
        //,-----------------------------------------------------.
        //,-----------------------------------------------------.
        QK_BOOT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        RGB_TOG, RGB_HUI, RGB_SAI, RGB_VAI, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------|
        RGB_MOD, RGB_HUD, RGB_SAD, RGB_VAD, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        //|--------+--------+--------+--------+--------+--------+--------|
        //|--------+--------+--------+--------+--------+--------+--------|
        KC_LGUI, _______, KC_SPC, KC_ENT, _______, KC_RALT
        //`--------------------------'  `--------------------------'
        )};
#endif

#ifdef ENCODER_MAP_ENABLE
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [0] =
        {
            ENCODER_CCW_CW(RGB_MOD, RGB_RMOD),
            ENCODER_CCW_CW(RGB_HUI, RGB_HUD),
            ENCODER_CCW_CW(RGB_VAI, RGB_VAD),
            ENCODER_CCW_CW(RGB_SAI, RGB_SAD),
        },
    [1] =
        {
            ENCODER_CCW_CW(RGB_MOD, RGB_RMOD),
            ENCODER_CCW_CW(RGB_HUI, RGB_HUD),
            ENCODER_CCW_CW(RGB_VAI, RGB_VAD),
            ENCODER_CCW_CW(RGB_SAI, RGB_SAD),
        },
    [2] =
        {
            ENCODER_CCW_CW(RGB_MOD, RGB_RMOD),
            ENCODER_CCW_CW(RGB_HUI, RGB_HUD),
            ENCODER_CCW_CW(RGB_VAI, RGB_VAD),
            ENCODER_CCW_CW(RGB_SAI, RGB_SAD),
        },
    [3] =
        {
            ENCODER_CCW_CW(RGB_MOD, RGB_RMOD),
            ENCODER_CCW_CW(RGB_HUI, RGB_HUD),
            ENCODER_CCW_CW(RGB_VAI, RGB_VAD),
            ENCODER_CCW_CW(RGB_SAI, RGB_SAD),
        },
    [4] =
        {
            ENCODER_CCW_CW(RGB_MOD, RGB_RMOD),
            ENCODER_CCW_CW(RGB_HUI, RGB_HUD),
            ENCODER_CCW_CW(RGB_VAI, RGB_VAD),
            ENCODER_CCW_CW(RGB_SAI, RGB_SAD),
        },
    [5] =
        {
            ENCODER_CCW_CW(RGB_MOD, RGB_RMOD),
            ENCODER_CCW_CW(RGB_HUI, RGB_HUD),
            ENCODER_CCW_CW(RGB_VAI, RGB_VAD),
            ENCODER_CCW_CW(RGB_SAI, RGB_SAD),
        },
};
#endif
