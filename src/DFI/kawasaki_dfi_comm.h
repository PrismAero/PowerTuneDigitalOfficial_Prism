#ifndef KAWASAKI_DFI_COMM_H
#define KAWASAKI_DFI_COMM_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

#define DFI_BAUD_RATE         15625
#define DFI_BIT_PERIOD_US     64
#define DFI_BYTE_TIME_US      640

#define DFI_INTERBYTE_GAP_US  9400
#define DFI_INTERGROUP_GAP_US 59440
#define DFI_GROUP_PERIOD_US   80000

#define DFI_INTERBYTE_MIN_US  5000
#define DFI_INTERGROUP_MIN_US 40000

#define DFI_MAX_SERVICE_CODES 32

typedef enum {
    DFI_GEAR_NEUTRAL = 0,
    DFI_GEAR_1       = 1,
    DFI_GEAR_2       = 2,
    DFI_GEAR_3       = 3,
    DFI_GEAR_4       = 4,
    DFI_GEAR_5       = 5,
    DFI_GEAR_6       = 6,
    DFI_GEAR_INVALID = 0xFF
} dfi_gear_t;

typedef enum {
    DFI_STATE_WAIT_GEAR,
    DFI_STATE_WAIT_DATA,
    DFI_STATE_WAIT_CHECK
} dfi_state_t;

typedef struct {
    uint8_t  gear_byte;
    uint8_t  data_byte;
    uint8_t  check_byte;
    bool     checksum_valid;
} dfi_group_t;

typedef struct {
    dfi_gear_t gear;
    uint8_t    code_count;
    uint8_t    codes[DFI_MAX_SERVICE_CODES];
    uint32_t   last_update_ms;
    uint32_t   groups_received;
    uint32_t   checksum_errors;
} dfi_status_t;

typedef void (*dfi_group_callback_t)(const dfi_group_t *group, void *user_data);
typedef void (*dfi_status_callback_t)(const dfi_status_t *status, void *user_data);

typedef struct {
    dfi_state_t  state;
    uint32_t     last_byte_time_us;
    uint8_t      gear_byte;
    uint8_t      data_byte;

    dfi_status_t status;

    uint8_t      cycle_codes[DFI_MAX_SERVICE_CODES];
    uint8_t      cycle_code_count;
    dfi_gear_t   cycle_gear;
    uint32_t     cycle_start_ms;
    bool         cycle_dirty;

    dfi_group_callback_t  on_group;
    dfi_status_callback_t on_status_change;
    void                  *user_data;
} dfi_decoder_t;

void dfi_init(dfi_decoder_t *dec);

void dfi_feed_byte(dfi_decoder_t *dec, uint8_t byte, uint32_t timestamp_us);

void dfi_set_group_callback(dfi_decoder_t *dec, dfi_group_callback_t cb, void *user_data);
void dfi_set_status_callback(dfi_decoder_t *dec, dfi_status_callback_t cb, void *user_data);

const dfi_status_t *dfi_get_status(const dfi_decoder_t *dec);

const char *dfi_gear_str(dfi_gear_t gear);
const char *dfi_code_description(uint8_t code);

#ifdef __cplusplus
}
#endif

#endif
