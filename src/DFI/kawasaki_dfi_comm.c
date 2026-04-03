#include "kawasaki_dfi_comm.h"
#include <string.h>

void dfi_init(dfi_decoder_t *dec) {
    memset(dec, 0, sizeof(*dec));
    dec->state = DFI_STATE_WAIT_GEAR;
    dec->status.gear = DFI_GEAR_INVALID;
}

static bool is_valid_gear(uint8_t byte) {
    return byte <= 6;
}

static bool code_already_in_cycle(const dfi_decoder_t *dec, uint8_t code) {
    for (uint8_t i = 0; i < dec->cycle_code_count; i++) {
        if (dec->cycle_codes[i] == code) return true;
    }
    return false;
}

static bool status_changed(const dfi_decoder_t *dec) {
    if (dec->cycle_gear != dec->status.gear) return true;
    if (dec->cycle_code_count != dec->status.code_count) return true;
    for (uint8_t i = 0; i < dec->cycle_code_count; i++) {
        bool found = false;
        for (uint8_t j = 0; j < dec->status.code_count; j++) {
            if (dec->cycle_codes[i] == dec->status.codes[j]) {
                found = true;
                break;
            }
        }
        if (!found) return true;
    }
    return false;
}

static void commit_cycle(dfi_decoder_t *dec, uint32_t now_ms) {
    if (dec->cycle_code_count == 0) return;

    if (status_changed(dec)) {
        dec->status.gear = dec->cycle_gear;
        dec->status.code_count = dec->cycle_code_count;
        memcpy(dec->status.codes, dec->cycle_codes, dec->cycle_code_count);
        dec->status.last_update_ms = now_ms;

        if (dec->on_status_change) {
            dec->on_status_change(&dec->status, dec->user_data);
        }
    }
}

static void start_new_cycle(dfi_decoder_t *dec, dfi_gear_t gear) {
    dec->cycle_gear = gear;
    dec->cycle_code_count = 0;
    dec->cycle_dirty = false;
}

static void process_group(dfi_decoder_t *dec, uint8_t gear_byte, uint8_t data_byte,
                          uint8_t check_byte, uint32_t now_us) {
    dfi_group_t group;
    group.gear_byte = gear_byte;
    group.data_byte = data_byte;
    group.check_byte = check_byte;
    group.checksum_valid = (check_byte == (uint8_t)(data_byte + gear_byte));

    dec->status.groups_received++;

    if (!group.checksum_valid) {
        dec->status.checksum_errors++;
        if (dec->on_group) dec->on_group(&group, dec->user_data);
        return;
    }

    if (dec->on_group) dec->on_group(&group, dec->user_data);

    dfi_gear_t gear = (dfi_gear_t)gear_byte;
    uint32_t now_ms = now_us / 1000;

    bool cycle_wrap = code_already_in_cycle(dec, data_byte);
    bool gear_changed = (dec->cycle_code_count > 0) && (gear != dec->cycle_gear);

    if (cycle_wrap || gear_changed) {
        commit_cycle(dec, now_ms);
        start_new_cycle(dec, gear);
    }

    if (dec->cycle_code_count < DFI_MAX_SERVICE_CODES) {
        dec->cycle_codes[dec->cycle_code_count++] = data_byte;
    }
}

void dfi_feed_byte(dfi_decoder_t *dec, uint8_t byte, uint32_t timestamp_us) {
    uint32_t elapsed_us = timestamp_us - dec->last_byte_time_us;

    if (dec->last_byte_time_us != 0 && elapsed_us > DFI_INTERGROUP_MIN_US) {
        if (dec->state != DFI_STATE_WAIT_GEAR) {
            dec->state = DFI_STATE_WAIT_GEAR;
        }
    }

    switch (dec->state) {
    case DFI_STATE_WAIT_GEAR:
        if (is_valid_gear(byte)) {
            dec->gear_byte = byte;
            dec->state = DFI_STATE_WAIT_DATA;
        }
        break;

    case DFI_STATE_WAIT_DATA:
        if (elapsed_us > DFI_INTERBYTE_MIN_US && elapsed_us < DFI_INTERGROUP_MIN_US) {
            dec->data_byte = byte;
            dec->state = DFI_STATE_WAIT_CHECK;
        } else {
            if (is_valid_gear(byte)) {
                dec->gear_byte = byte;
                dec->state = DFI_STATE_WAIT_DATA;
            } else {
                dec->state = DFI_STATE_WAIT_GEAR;
            }
        }
        break;

    case DFI_STATE_WAIT_CHECK:
        if (elapsed_us > DFI_INTERBYTE_MIN_US && elapsed_us < DFI_INTERGROUP_MIN_US) {
            process_group(dec, dec->gear_byte, dec->data_byte, byte, timestamp_us);
        }
        dec->state = DFI_STATE_WAIT_GEAR;
        break;
    }

    dec->last_byte_time_us = timestamp_us;
}

void dfi_set_group_callback(dfi_decoder_t *dec, dfi_group_callback_t cb, void *user_data) {
    dec->on_group = cb;
    dec->user_data = user_data;
}

void dfi_set_status_callback(dfi_decoder_t *dec, dfi_status_callback_t cb, void *user_data) {
    dec->on_status_change = cb;
    dec->user_data = user_data;
}

const dfi_status_t *dfi_get_status(const dfi_decoder_t *dec) {
    return &dec->status;
}

const char *dfi_gear_str(dfi_gear_t gear) {
    switch (gear) {
    case DFI_GEAR_NEUTRAL: return "N";
    case DFI_GEAR_1:       return "1";
    case DFI_GEAR_2:       return "2";
    case DFI_GEAR_3:       return "3";
    case DFI_GEAR_4:       return "4";
    case DFI_GEAR_5:       return "5";
    case DFI_GEAR_6:       return "6";
    default:               return "?";
    }
}

const char *dfi_code_description(uint8_t code) {
    switch (code) {
    case 11: return "Main throttle sensor";
    case 12: return "Inlet air pressure sensor";
    case 13: return "Inlet air temperature sensor";
    case 14: return "Water temperature sensor";
    case 15: return "Atmospheric pressure sensor";
    case 21: return "Crankshaft sensor";
    case 23: return "Camshaft position sensor";
    case 24: return "Speed sensor";
    case 25: return "Gear position switch";
    case 31: return "Vehicle-down sensor";
    case 32: return "Subthrottle sensor";
    case 33: return "Oxygen sensor #1 inactivation";
    case 34: return "Exhaust butterfly valve actuator sensor";
    case 35: return "Immobilizer amplifier";
    case 36: return "Blank key detection";
    case 39: return "ECU communication error";
    case 46: return "Fuel pump relay stuck";
    case 51: return "Stick coil #1";
    case 52: return "Stick coil #2";
    case 53: return "Stick coil #3";
    case 54: return "Stick coil #4";
    case 56: return "Radiator fan relay";
    case 62: return "Subthrottle valve actuator";
    case 63: return "Exhaust butterfly valve actuator";
    case 64: return "Air switching valve";
    case 67: return "Oxygen sensor heater #1/#2";
    case 83: return "Oxygen sensor #2 inactivation";
    default: return "Unknown";
    }
}
