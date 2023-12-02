// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// The following structs are used to implement the lowest level
// of the FFI, and thus useful to multiple uniffied crates.
// We ensure they are declared exactly once, with a header guard, UNIFFI_SHARED_H.
#ifdef UNIFFI_SHARED_H
    // We also try to prevent mixing versions of shared uniffi header structs.
    // If you add anything to the #else block, you must increment the version suffix in UNIFFI_SHARED_HEADER_V4
    #ifndef UNIFFI_SHARED_HEADER_V4
        #error Combining helper code from multiple versions of uniffi is not supported
    #endif // ndef UNIFFI_SHARED_HEADER_V4
#else
#define UNIFFI_SHARED_H
#define UNIFFI_SHARED_HEADER_V4
// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️

typedef struct RustBuffer
{
    int32_t capacity;
    int32_t len;
    uint8_t *_Nullable data;
} RustBuffer;

typedef int32_t (*ForeignCallback)(uint64_t, int32_t, const uint8_t *_Nonnull, int32_t, RustBuffer *_Nonnull);

// Task defined in Rust that Swift executes
typedef void (*UniFfiRustTaskCallback)(const void * _Nullable, int8_t);

// Callback to execute Rust tasks using a Swift Task
//
// Args:
//   executor: ForeignExecutor lowered into a size_t value
//   delay: Delay in MS
//   task: UniFfiRustTaskCallback to call
//   task_data: data to pass the task callback
typedef int8_t (*UniFfiForeignExecutorCallback)(size_t, uint32_t, UniFfiRustTaskCallback _Nullable, const void * _Nullable);

typedef struct ForeignBytes
{
    int32_t len;
    const uint8_t *_Nullable data;
} ForeignBytes;

// Error definitions
typedef struct RustCallStatus {
    int8_t code;
    RustBuffer errorBuf;
} RustCallStatus;

// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️
#endif // def UNIFFI_SHARED_H

// Continuation callback for UniFFI Futures
typedef void (*UniFfiRustFutureContinuation)(void * _Nonnull, int8_t);

// Scaffolding functions
void uniffi_logins_fn_free_loginstore(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void*_Nonnull uniffi_logins_fn_constructor_loginstore_new(RustBuffer path, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_add(void*_Nonnull ptr, RustBuffer login, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_add_or_update(void*_Nonnull ptr, RustBuffer login, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
int8_t uniffi_logins_fn_method_loginstore_delete(void*_Nonnull ptr, RustBuffer id, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_find_login_to_update(void*_Nonnull ptr, RustBuffer look, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_get(void*_Nonnull ptr, RustBuffer id, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_get_by_base_domain(void*_Nonnull ptr, RustBuffer base_domain, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_list(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_logins_fn_method_loginstore_register_with_sync_manager(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_logins_fn_method_loginstore_reset(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_logins_fn_method_loginstore_touch(void*_Nonnull ptr, RustBuffer id, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_method_loginstore_update(void*_Nonnull ptr, RustBuffer id, RustBuffer login, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
void uniffi_logins_fn_method_loginstore_wipe(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
void uniffi_logins_fn_method_loginstore_wipe_local(void*_Nonnull ptr, RustCallStatus *_Nonnull out_status
);
int8_t uniffi_logins_fn_func_check_canary(RustBuffer canary, RustBuffer text, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_func_create_canary(RustBuffer text, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_func_create_key(RustCallStatus *_Nonnull out_status
    
);
RustBuffer uniffi_logins_fn_func_decrypt_fields(RustBuffer sec_fields, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_func_decrypt_login(RustBuffer login, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_func_encrypt_fields(RustBuffer sec_fields, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_logins_fn_func_encrypt_login(RustBuffer login, RustBuffer encryption_key, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_logins_rustbuffer_alloc(int32_t size, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_logins_rustbuffer_from_bytes(ForeignBytes bytes, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rustbuffer_free(RustBuffer buf, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_logins_rustbuffer_reserve(RustBuffer buf, int32_t additional, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_continuation_callback_set(UniFfiRustFutureContinuation _Nonnull callback
);
void ffi_logins_rust_future_poll_u8(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_u8(void* _Nonnull handle
);
void ffi_logins_rust_future_free_u8(void* _Nonnull handle
);
uint8_t ffi_logins_rust_future_complete_u8(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_i8(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_i8(void* _Nonnull handle
);
void ffi_logins_rust_future_free_i8(void* _Nonnull handle
);
int8_t ffi_logins_rust_future_complete_i8(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_u16(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_u16(void* _Nonnull handle
);
void ffi_logins_rust_future_free_u16(void* _Nonnull handle
);
uint16_t ffi_logins_rust_future_complete_u16(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_i16(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_i16(void* _Nonnull handle
);
void ffi_logins_rust_future_free_i16(void* _Nonnull handle
);
int16_t ffi_logins_rust_future_complete_i16(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_u32(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_u32(void* _Nonnull handle
);
void ffi_logins_rust_future_free_u32(void* _Nonnull handle
);
uint32_t ffi_logins_rust_future_complete_u32(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_i32(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_i32(void* _Nonnull handle
);
void ffi_logins_rust_future_free_i32(void* _Nonnull handle
);
int32_t ffi_logins_rust_future_complete_i32(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_u64(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_u64(void* _Nonnull handle
);
void ffi_logins_rust_future_free_u64(void* _Nonnull handle
);
uint64_t ffi_logins_rust_future_complete_u64(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_i64(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_i64(void* _Nonnull handle
);
void ffi_logins_rust_future_free_i64(void* _Nonnull handle
);
int64_t ffi_logins_rust_future_complete_i64(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_f32(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_f32(void* _Nonnull handle
);
void ffi_logins_rust_future_free_f32(void* _Nonnull handle
);
float ffi_logins_rust_future_complete_f32(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_f64(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_f64(void* _Nonnull handle
);
void ffi_logins_rust_future_free_f64(void* _Nonnull handle
);
double ffi_logins_rust_future_complete_f64(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_pointer(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_pointer(void* _Nonnull handle
);
void ffi_logins_rust_future_free_pointer(void* _Nonnull handle
);
void*_Nonnull ffi_logins_rust_future_complete_pointer(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_rust_buffer(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_rust_buffer(void* _Nonnull handle
);
void ffi_logins_rust_future_free_rust_buffer(void* _Nonnull handle
);
RustBuffer ffi_logins_rust_future_complete_rust_buffer(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_logins_rust_future_poll_void(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_logins_rust_future_cancel_void(void* _Nonnull handle
);
void ffi_logins_rust_future_free_void(void* _Nonnull handle
);
void ffi_logins_rust_future_complete_void(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
uint16_t uniffi_logins_checksum_func_check_canary(void
    
);
uint16_t uniffi_logins_checksum_func_create_canary(void
    
);
uint16_t uniffi_logins_checksum_func_create_key(void
    
);
uint16_t uniffi_logins_checksum_func_decrypt_fields(void
    
);
uint16_t uniffi_logins_checksum_func_decrypt_login(void
    
);
uint16_t uniffi_logins_checksum_func_encrypt_fields(void
    
);
uint16_t uniffi_logins_checksum_func_encrypt_login(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_add(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_add_or_update(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_delete(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_find_login_to_update(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_get(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_get_by_base_domain(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_list(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_register_with_sync_manager(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_reset(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_touch(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_update(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_wipe(void
    
);
uint16_t uniffi_logins_checksum_method_loginstore_wipe_local(void
    
);
uint16_t uniffi_logins_checksum_constructor_loginstore_new(void
    
);
uint32_t ffi_logins_uniffi_contract_version(void
    
);

