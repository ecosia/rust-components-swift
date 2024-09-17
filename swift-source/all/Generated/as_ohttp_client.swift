// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

// swiftlint:disable all
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(MozillaRustComponents)
    import MozillaRustComponents
#endif

private extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func empty() -> RustBuffer {
        RustBuffer(capacity: 0, len: 0, data: nil)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_as_ohttp_client_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_as_ohttp_client_rustbuffer_free(self, $0) }
    }
}

private extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a library of its own.

private extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// Define reader functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.
//
// With external types, one swift source file needs to be able to call the read
// method on another source file's FfiConverter, but then what visibility
// should Reader have?
// - If Reader is fileprivate, then this means the read() must also
//   be fileprivate, which doesn't work with external types.
// - If Reader is internal/public, we'll get compile errors since both source
//   files will try define the same type.
//
// Instead, the read() method and these helper functions input a tuple of data

private func createReader(data: Data) -> (data: Data, offset: Data.Index) {
    (data: data, offset: 0)
}

// Reads an integer at the current offset, in big-endian order, and advances
// the offset on success. Throws if reading the integer would move the
// offset past the end of the buffer.
private func readInt<T: FixedWidthInteger>(_ reader: inout (data: Data, offset: Data.Index)) throws -> T {
    let range = reader.offset ..< reader.offset + MemoryLayout<T>.size
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    if T.self == UInt8.self {
        let value = reader.data[reader.offset]
        reader.offset += 1
        return value as! T
    }
    var value: T = 0
    let _ = withUnsafeMutableBytes(of: &value) { reader.data.copyBytes(to: $0, from: range) }
    reader.offset = range.upperBound
    return value.bigEndian
}

// Reads an arbitrary number of bytes, to be used to read
// raw bytes, this is useful when lifting strings
private func readBytes(_ reader: inout (data: Data, offset: Data.Index), count: Int) throws -> [UInt8] {
    let range = reader.offset ..< (reader.offset + count)
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    var value = [UInt8](repeating: 0, count: count)
    value.withUnsafeMutableBufferPointer { buffer in
        reader.data.copyBytes(to: buffer, from: range)
    }
    reader.offset = range.upperBound
    return value
}

// Reads a float at the current offset.
private func readFloat(_ reader: inout (data: Data, offset: Data.Index)) throws -> Float {
    return try Float(bitPattern: readInt(&reader))
}

// Reads a float at the current offset.
private func readDouble(_ reader: inout (data: Data, offset: Data.Index)) throws -> Double {
    return try Double(bitPattern: readInt(&reader))
}

// Indicates if the offset has reached the end of the buffer.
private func hasRemaining(_ reader: (data: Data, offset: Data.Index)) -> Bool {
    return reader.offset < reader.data.count
}

// Define writer functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.  See the above discussion on Readers for details.

private func createWriter() -> [UInt8] {
    return []
}

private func writeBytes<S>(_ writer: inout [UInt8], _ byteArr: S) where S: Sequence, S.Element == UInt8 {
    writer.append(contentsOf: byteArr)
}

// Writes an integer in big-endian order.
//
// Warning: make sure what you are trying to write
// is in the correct type!
private func writeInt<T: FixedWidthInteger>(_ writer: inout [UInt8], _ value: T) {
    var value = value.bigEndian
    withUnsafeBytes(of: &value) { writer.append(contentsOf: $0) }
}

private func writeFloat(_ writer: inout [UInt8], _ value: Float) {
    writeInt(&writer, value.bitPattern)
}

private func writeDouble(_ writer: inout [UInt8], _ value: Double) {
    writeInt(&writer, value.bitPattern)
}

// Protocol for types that transfer other types across the FFI. This is
// analogous to the Rust trait of the same name.
private protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: inout [UInt8])
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
private protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType {}

extension FfiConverterPrimitive {
    public static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    public static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
private protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    public static func lift(_ buf: RustBuffer) throws -> SwiftType {
        var reader = createReader(data: Data(rustBuffer: buf))
        let value = try read(from: &reader)
        if hasRemaining(reader) {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    public static func lower(_ value: SwiftType) -> RustBuffer {
        var writer = createWriter()
        write(value, into: &writer)
        return RustBuffer(bytes: writer)
    }
}

// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
private enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

private extension NSLock {
    func withLock<T>(f: () throws -> T) rethrows -> T {
        lock()
        defer { self.unlock() }
        return try f()
    }
}

private let CALL_SUCCESS: Int8 = 0
private let CALL_ERROR: Int8 = 1
private let CALL_UNEXPECTED_ERROR: Int8 = 2
private let CALL_CANCELLED: Int8 = 3

private extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    let neverThrow: ((RustBuffer) throws -> Never)? = nil
    return try makeRustCall(callback, errorHandler: neverThrow)
}

private func rustCallWithError<T, E: Swift.Error>(
    _ errorHandler: @escaping (RustBuffer) throws -> E,
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T
) throws -> T {
    try makeRustCall(callback, errorHandler: errorHandler)
}

private func makeRustCall<T, E: Swift.Error>(
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T,
    errorHandler: ((RustBuffer) throws -> E)?
) throws -> T {
    uniffiEnsureInitialized()
    var callStatus = RustCallStatus()
    let returnedVal = callback(&callStatus)
    try uniffiCheckCallStatus(callStatus: callStatus, errorHandler: errorHandler)
    return returnedVal
}

private func uniffiCheckCallStatus<E: Swift.Error>(
    callStatus: RustCallStatus,
    errorHandler: ((RustBuffer) throws -> E)?
) throws {
    switch callStatus.code {
    case CALL_SUCCESS:
        return

    case CALL_ERROR:
        if let errorHandler = errorHandler {
            throw try errorHandler(callStatus.errorBuf)
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.unexpectedRustCallError
        }

    case CALL_UNEXPECTED_ERROR:
        // When the rust code sees a panic, it tries to construct a RustBuffer
        // with the message.  But if that code panics, then it just sends back
        // an empty buffer.
        if callStatus.errorBuf.len > 0 {
            throw try UniffiInternalError.rustPanic(FfiConverterString.lift(callStatus.errorBuf))
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.rustPanic("Rust panic")
        }

    case CALL_CANCELLED:
        fatalError("Cancellation not supported yet")

    default:
        throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

private func uniffiTraitInterfaceCall<T>(
    callStatus: UnsafeMutablePointer<RustCallStatus>,
    makeCall: () throws -> T,
    writeReturn: (T) -> Void
) {
    do {
        try writeReturn(makeCall())
    } catch {
        callStatus.pointee.code = CALL_UNEXPECTED_ERROR
        callStatus.pointee.errorBuf = FfiConverterString.lower(String(describing: error))
    }
}

private func uniffiTraitInterfaceCallWithError<T, E>(
    callStatus: UnsafeMutablePointer<RustCallStatus>,
    makeCall: () throws -> T,
    writeReturn: (T) -> Void,
    lowerError: (E) -> RustBuffer
) {
    do {
        try writeReturn(makeCall())
    } catch let error as E {
        callStatus.pointee.code = CALL_ERROR
        callStatus.pointee.errorBuf = lowerError(error)
    } catch {
        callStatus.pointee.code = CALL_UNEXPECTED_ERROR
        callStatus.pointee.errorBuf = FfiConverterString.lower(String(describing: error))
    }
}

private class UniffiHandleMap<T> {
    private var map: [UInt64: T] = [:]
    private let lock = NSLock()
    private var currentHandle: UInt64 = 1

    func insert(obj: T) -> UInt64 {
        lock.withLock {
            let handle = currentHandle
            currentHandle += 1
            map[handle] = obj
            return handle
        }
    }

    func get(handle: UInt64) throws -> T {
        try lock.withLock {
            guard let obj = map[handle] else {
                throw UniffiInternalError.unexpectedStaleHandle
            }
            return obj
        }
    }

    @discardableResult
    func remove(handle: UInt64) throws -> T {
        try lock.withLock {
            guard let obj = map.removeValue(forKey: handle) else {
                throw UniffiInternalError.unexpectedStaleHandle
            }
            return obj
        }
    }

    var count: Int {
        map.count
    }
}

// Public interface members begin here.

private struct FfiConverterUInt8: FfiConverterPrimitive {
    typealias FfiType = UInt8
    typealias SwiftType = UInt8

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> UInt8 {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: UInt8, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

private struct FfiConverterUInt16: FfiConverterPrimitive {
    typealias FfiType = UInt16
    typealias SwiftType = UInt16

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> UInt16 {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

private struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    public static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    public static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> String {
        let len: Int32 = try readInt(&buf)
        return try String(bytes: readBytes(&buf, count: Int(len)), encoding: String.Encoding.utf8)!
    }

    public static func write(_ value: String, into buf: inout [UInt8]) {
        let len = Int32(value.utf8.count)
        writeInt(&buf, len)
        writeBytes(&buf, value.utf8)
    }
}

/**
 * Each OHTTP request-reply exchange needs to create an OhttpSession
 * object to manage encryption state.
 */
public protocol OhttpSessionProtocol: AnyObject {
    /**
     * Decypt and unpack the response from the Relay for the previously
     * encapsulated request. You must use the same OhttpSession that
     * generated the request message.
     */
    func decapsulate(encoded: [UInt8]) throws -> OhttpResponse

    /**
     * Encapsulate an HTTP request as Binary HTTP and then encrypt that
     * payload using HPKE. The caller is responsible for sending the
     * resulting message to the Relay.
     */
    func encapsulate(method: String, scheme: String, server: String, endpoint: String, headers: [String: String], payload: [UInt8]) throws -> [UInt8]
}

/**
 * Each OHTTP request-reply exchange needs to create an OhttpSession
 * object to manage encryption state.
 */
open class OhttpSession:
    OhttpSessionProtocol
{
    fileprivate let pointer: UnsafeMutableRawPointer!

    /// Used to instantiate a [FFIObject] without an actual pointer, for fakes in tests, mostly.
    public struct NoPointer {
        public init() {}
    }

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    public required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    /// This constructor can be used to instantiate a fake object.
    /// - Parameter noPointer: Placeholder value so we can have a constructor separate from the default empty one that may be implemented for classes extending [FFIObject].
    ///
    /// - Warning:
    ///     Any object instantiated with this constructor cannot be passed to an actual Rust-backed object. Since there isn't a backing [Pointer] the FFI lower functions will crash.
    public init(noPointer _: NoPointer) {
        pointer = nil
    }

    public func uniffiClonePointer() -> UnsafeMutableRawPointer {
        return try! rustCall { uniffi_as_ohttp_client_fn_clone_ohttpsession(self.pointer, $0) }
    }

    /**
     * Initialize encryption state based on specific Gateway key config
     */
    public convenience init(config: [UInt8]) throws {
        let pointer =
            try rustCallWithError(FfiConverterTypeOhttpError.lift) {
                uniffi_as_ohttp_client_fn_constructor_ohttpsession_new(
                    FfiConverterSequenceUInt8.lower(config), $0
                )
            }
        self.init(unsafeFromRawPointer: pointer)
    }

    deinit {
        guard let pointer = pointer else {
            return
        }

        try! rustCall { uniffi_as_ohttp_client_fn_free_ohttpsession(pointer, $0) }
    }

    /**
     * Decypt and unpack the response from the Relay for the previously
     * encapsulated request. You must use the same OhttpSession that
     * generated the request message.
     */
    open func decapsulate(encoded: [UInt8]) throws -> OhttpResponse {
        return try FfiConverterTypeOhttpResponse.lift(rustCallWithError(FfiConverterTypeOhttpError.lift) {
            uniffi_as_ohttp_client_fn_method_ohttpsession_decapsulate(self.uniffiClonePointer(),
                                                                      FfiConverterSequenceUInt8.lower(encoded), $0)
        })
    }

    /**
     * Encapsulate an HTTP request as Binary HTTP and then encrypt that
     * payload using HPKE. The caller is responsible for sending the
     * resulting message to the Relay.
     */
    open func encapsulate(method: String, scheme: String, server: String, endpoint: String, headers: [String: String], payload: [UInt8]) throws -> [UInt8] {
        return try FfiConverterSequenceUInt8.lift(rustCallWithError(FfiConverterTypeOhttpError.lift) {
            uniffi_as_ohttp_client_fn_method_ohttpsession_encapsulate(self.uniffiClonePointer(),
                                                                      FfiConverterString.lower(method),
                                                                      FfiConverterString.lower(scheme),
                                                                      FfiConverterString.lower(server),
                                                                      FfiConverterString.lower(endpoint),
                                                                      FfiConverterDictionaryStringString.lower(headers),
                                                                      FfiConverterSequenceUInt8.lower(payload), $0)
        })
    }
}

public struct FfiConverterTypeOhttpSession: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = OhttpSession

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> OhttpSession {
        return OhttpSession(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: OhttpSession) -> UnsafeMutableRawPointer {
        return value.uniffiClonePointer()
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> OhttpSession {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: OhttpSession, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }
}

public func FfiConverterTypeOhttpSession_lift(_ pointer: UnsafeMutableRawPointer) throws -> OhttpSession {
    return try FfiConverterTypeOhttpSession.lift(pointer)
}

public func FfiConverterTypeOhttpSession_lower(_ value: OhttpSession) -> UnsafeMutableRawPointer {
    return FfiConverterTypeOhttpSession.lower(value)
}

/**
 * A testing interface for decrypting and responding to OHTTP messages. This
 * should only be used for testing.
 */
public protocol OhttpTestServerProtocol: AnyObject {
    /**
     * Return the unique encryption key config for this instance of test server.
     */
    func getConfig() -> [UInt8]

    func receive(message: [UInt8]) throws -> TestServerRequest

    func respond(response: OhttpResponse) throws -> [UInt8]
}

/**
 * A testing interface for decrypting and responding to OHTTP messages. This
 * should only be used for testing.
 */
open class OhttpTestServer:
    OhttpTestServerProtocol
{
    fileprivate let pointer: UnsafeMutableRawPointer!

    /// Used to instantiate a [FFIObject] without an actual pointer, for fakes in tests, mostly.
    public struct NoPointer {
        public init() {}
    }

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    public required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    /// This constructor can be used to instantiate a fake object.
    /// - Parameter noPointer: Placeholder value so we can have a constructor separate from the default empty one that may be implemented for classes extending [FFIObject].
    ///
    /// - Warning:
    ///     Any object instantiated with this constructor cannot be passed to an actual Rust-backed object. Since there isn't a backing [Pointer] the FFI lower functions will crash.
    public init(noPointer _: NoPointer) {
        pointer = nil
    }

    public func uniffiClonePointer() -> UnsafeMutableRawPointer {
        return try! rustCall { uniffi_as_ohttp_client_fn_clone_ohttptestserver(self.pointer, $0) }
    }

    public convenience init() {
        let pointer =
            try! rustCall {
                uniffi_as_ohttp_client_fn_constructor_ohttptestserver_new($0
                )
            }
        self.init(unsafeFromRawPointer: pointer)
    }

    deinit {
        guard let pointer = pointer else {
            return
        }

        try! rustCall { uniffi_as_ohttp_client_fn_free_ohttptestserver(pointer, $0) }
    }

    /**
     * Return the unique encryption key config for this instance of test server.
     */
    open func getConfig() -> [UInt8] {
        return try! FfiConverterSequenceUInt8.lift(try! rustCall {
            uniffi_as_ohttp_client_fn_method_ohttptestserver_get_config(self.uniffiClonePointer(), $0)
        })
    }

    open func receive(message: [UInt8]) throws -> TestServerRequest {
        return try FfiConverterTypeTestServerRequest.lift(rustCallWithError(FfiConverterTypeOhttpError.lift) {
            uniffi_as_ohttp_client_fn_method_ohttptestserver_receive(self.uniffiClonePointer(),
                                                                     FfiConverterSequenceUInt8.lower(message), $0)
        })
    }

    open func respond(response: OhttpResponse) throws -> [UInt8] {
        return try FfiConverterSequenceUInt8.lift(rustCallWithError(FfiConverterTypeOhttpError.lift) {
            uniffi_as_ohttp_client_fn_method_ohttptestserver_respond(self.uniffiClonePointer(),
                                                                     FfiConverterTypeOhttpResponse.lower(response), $0)
        })
    }
}

public struct FfiConverterTypeOhttpTestServer: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = OhttpTestServer

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> OhttpTestServer {
        return OhttpTestServer(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: OhttpTestServer) -> UnsafeMutableRawPointer {
        return value.uniffiClonePointer()
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> OhttpTestServer {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: OhttpTestServer, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }
}

public func FfiConverterTypeOhttpTestServer_lift(_ pointer: UnsafeMutableRawPointer) throws -> OhttpTestServer {
    return try FfiConverterTypeOhttpTestServer.lift(pointer)
}

public func FfiConverterTypeOhttpTestServer_lower(_ value: OhttpTestServer) -> UnsafeMutableRawPointer {
    return FfiConverterTypeOhttpTestServer.lower(value)
}

/**
 * The decrypted response from the Gateway/Target
 */
public struct OhttpResponse {
    public var statusCode: UInt16
    public var headers: [String: String]
    public var payload: [UInt8]

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(statusCode: UInt16, headers: [String: String], payload: [UInt8]) {
        self.statusCode = statusCode
        self.headers = headers
        self.payload = payload
    }
}

extension OhttpResponse: Equatable, Hashable {
    public static func == (lhs: OhttpResponse, rhs: OhttpResponse) -> Bool {
        if lhs.statusCode != rhs.statusCode {
            return false
        }
        if lhs.headers != rhs.headers {
            return false
        }
        if lhs.payload != rhs.payload {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(statusCode)
        hasher.combine(headers)
        hasher.combine(payload)
    }
}

public struct FfiConverterTypeOhttpResponse: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> OhttpResponse {
        return
            try OhttpResponse(
                statusCode: FfiConverterUInt16.read(from: &buf),
                headers: FfiConverterDictionaryStringString.read(from: &buf),
                payload: FfiConverterSequenceUInt8.read(from: &buf)
            )
    }

    public static func write(_ value: OhttpResponse, into buf: inout [UInt8]) {
        FfiConverterUInt16.write(value.statusCode, into: &buf)
        FfiConverterDictionaryStringString.write(value.headers, into: &buf)
        FfiConverterSequenceUInt8.write(value.payload, into: &buf)
    }
}

public func FfiConverterTypeOhttpResponse_lift(_ buf: RustBuffer) throws -> OhttpResponse {
    return try FfiConverterTypeOhttpResponse.lift(buf)
}

public func FfiConverterTypeOhttpResponse_lower(_ value: OhttpResponse) -> RustBuffer {
    return FfiConverterTypeOhttpResponse.lower(value)
}

public struct TestServerRequest {
    public var method: String
    public var scheme: String
    public var server: String
    public var endpoint: String
    public var headers: [String: String]
    public var payload: [UInt8]

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(method: String, scheme: String, server: String, endpoint: String, headers: [String: String], payload: [UInt8]) {
        self.method = method
        self.scheme = scheme
        self.server = server
        self.endpoint = endpoint
        self.headers = headers
        self.payload = payload
    }
}

extension TestServerRequest: Equatable, Hashable {
    public static func == (lhs: TestServerRequest, rhs: TestServerRequest) -> Bool {
        if lhs.method != rhs.method {
            return false
        }
        if lhs.scheme != rhs.scheme {
            return false
        }
        if lhs.server != rhs.server {
            return false
        }
        if lhs.endpoint != rhs.endpoint {
            return false
        }
        if lhs.headers != rhs.headers {
            return false
        }
        if lhs.payload != rhs.payload {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(method)
        hasher.combine(scheme)
        hasher.combine(server)
        hasher.combine(endpoint)
        hasher.combine(headers)
        hasher.combine(payload)
    }
}

public struct FfiConverterTypeTestServerRequest: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> TestServerRequest {
        return
            try TestServerRequest(
                method: FfiConverterString.read(from: &buf),
                scheme: FfiConverterString.read(from: &buf),
                server: FfiConverterString.read(from: &buf),
                endpoint: FfiConverterString.read(from: &buf),
                headers: FfiConverterDictionaryStringString.read(from: &buf),
                payload: FfiConverterSequenceUInt8.read(from: &buf)
            )
    }

    public static func write(_ value: TestServerRequest, into buf: inout [UInt8]) {
        FfiConverterString.write(value.method, into: &buf)
        FfiConverterString.write(value.scheme, into: &buf)
        FfiConverterString.write(value.server, into: &buf)
        FfiConverterString.write(value.endpoint, into: &buf)
        FfiConverterDictionaryStringString.write(value.headers, into: &buf)
        FfiConverterSequenceUInt8.write(value.payload, into: &buf)
    }
}

public func FfiConverterTypeTestServerRequest_lift(_ buf: RustBuffer) throws -> TestServerRequest {
    return try FfiConverterTypeTestServerRequest.lift(buf)
}

public func FfiConverterTypeTestServerRequest_lower(_ value: TestServerRequest) -> RustBuffer {
    return FfiConverterTypeTestServerRequest.lower(value)
}

public enum OhttpError {
    case KeyFetchFailed(message: String)

    case MalformedKeyConfig(message: String)

    case UnsupportedKeyConfig(message: String)

    case InvalidSession(message: String)

    case RelayFailed(message: String)

    case CannotEncodeMessage(message: String)

    case MalformedMessage(message: String)

    case DuplicateHeaders(message: String)
}

public struct FfiConverterTypeOhttpError: FfiConverterRustBuffer {
    typealias SwiftType = OhttpError

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> OhttpError {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        case 1: return try .KeyFetchFailed(
                message: FfiConverterString.read(from: &buf)
            )

        case 2: return try .MalformedKeyConfig(
                message: FfiConverterString.read(from: &buf)
            )

        case 3: return try .UnsupportedKeyConfig(
                message: FfiConverterString.read(from: &buf)
            )

        case 4: return try .InvalidSession(
                message: FfiConverterString.read(from: &buf)
            )

        case 5: return try .RelayFailed(
                message: FfiConverterString.read(from: &buf)
            )

        case 6: return try .CannotEncodeMessage(
                message: FfiConverterString.read(from: &buf)
            )

        case 7: return try .MalformedMessage(
                message: FfiConverterString.read(from: &buf)
            )

        case 8: return try .DuplicateHeaders(
                message: FfiConverterString.read(from: &buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: OhttpError, into buf: inout [UInt8]) {
        switch value {
        case .KeyFetchFailed(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(1))
        case .MalformedKeyConfig(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(2))
        case .UnsupportedKeyConfig(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(3))
        case .InvalidSession(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(4))
        case .RelayFailed(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(5))
        case .CannotEncodeMessage(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(6))
        case .MalformedMessage(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(7))
        case .DuplicateHeaders(_ /* message is ignored*/ ):
            writeInt(&buf, Int32(8))
        }
    }
}

extension OhttpError: Equatable, Hashable {}

extension OhttpError: Foundation.LocalizedError {
    public var errorDescription: String? {
        String(reflecting: self)
    }
}

private struct FfiConverterSequenceUInt8: FfiConverterRustBuffer {
    typealias SwiftType = [UInt8]

    public static func write(_ value: [UInt8], into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        for item in value {
            FfiConverterUInt8.write(item, into: &buf)
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> [UInt8] {
        let len: Int32 = try readInt(&buf)
        var seq = [UInt8]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            try seq.append(FfiConverterUInt8.read(from: &buf))
        }
        return seq
    }
}

private struct FfiConverterDictionaryStringString: FfiConverterRustBuffer {
    public static func write(_ value: [String: String], into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        for (key, value) in value {
            FfiConverterString.write(key, into: &buf)
            FfiConverterString.write(value, into: &buf)
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> [String: String] {
        let len: Int32 = try readInt(&buf)
        var dict = [String: String]()
        dict.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            let key = try FfiConverterString.read(from: &buf)
            let value = try FfiConverterString.read(from: &buf)
            dict[key] = value
        }
        return dict
    }
}

private enum InitializationResult {
    case ok
    case contractVersionMismatch
    case apiChecksumMismatch
}

// Use a global variable to perform the versioning checks. Swift ensures that
// the code inside is only computed once.
private var initializationResult: InitializationResult = {
    // Get the bindings contract version from our ComponentInterface
    let bindings_contract_version = 26
    // Get the scaffolding contract version by calling the into the dylib
    let scaffolding_contract_version = ffi_as_ohttp_client_uniffi_contract_version()
    if bindings_contract_version != scaffolding_contract_version {
        return InitializationResult.contractVersionMismatch
    }
    if uniffi_as_ohttp_client_checksum_method_ohttpsession_decapsulate() != 16642 {
        return InitializationResult.apiChecksumMismatch
    }
    if uniffi_as_ohttp_client_checksum_method_ohttpsession_encapsulate() != 33112 {
        return InitializationResult.apiChecksumMismatch
    }
    if uniffi_as_ohttp_client_checksum_method_ohttptestserver_get_config() != 41388 {
        return InitializationResult.apiChecksumMismatch
    }
    if uniffi_as_ohttp_client_checksum_method_ohttptestserver_receive() != 56163 {
        return InitializationResult.apiChecksumMismatch
    }
    if uniffi_as_ohttp_client_checksum_method_ohttptestserver_respond() != 21845 {
        return InitializationResult.apiChecksumMismatch
    }
    if uniffi_as_ohttp_client_checksum_constructor_ohttpsession_new() != 63666 {
        return InitializationResult.apiChecksumMismatch
    }
    if uniffi_as_ohttp_client_checksum_constructor_ohttptestserver_new() != 42944 {
        return InitializationResult.apiChecksumMismatch
    }

    return InitializationResult.ok
}()

private func uniffiEnsureInitialized() {
    switch initializationResult {
    case .ok:
        break
    case .contractVersionMismatch:
        fatalError("UniFFI contract version mismatch: try cleaning and rebuilding your project")
    case .apiChecksumMismatch:
        fatalError("UniFFI API checksum mismatch: try cleaning and rebuilding your project")
    }
}

// swiftlint:enable all
