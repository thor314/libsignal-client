import SignalFfi
import Foundation

class IdentityKey {
    private let key : PublicKey;

    init(pk: PublicKey) {
        key = pk;
    }

    init(bytes: [UInt8]) throws {
        key = try PublicKey(bytes);
    }

    func serialize() throws -> [UInt8] {
        return try key.serialize();
    }

    func publicKey() -> PublicKey {
        return key;
    }
}

class IdentityKeyPair {
    private let pubkey : PublicKey;
    private let privkey : PrivateKey;

    init() throws {
        privkey = try PrivateKey(); // generates new key
        pubkey = try privkey.getPublicKey();
    }

    init(bytes: [UInt8]) throws {
        var pubkey_ptr : OpaquePointer?;
        var privkey_ptr : OpaquePointer?;
        try CheckError(signal_identitykeypair_deserialize(&pubkey_ptr, &privkey_ptr, bytes, bytes.count));

        pubkey = PublicKey(raw_ptr: pubkey_ptr);
        privkey = PrivateKey(raw_ptr: privkey_ptr);
    }

    func serialize() throws -> [UInt8] {
        return try invokeFnReturningArray(fn: { (b,bl) in signal_identitykeypair_serialize(b,bl,pubkey.nativeHandle(), privkey.nativeHandle()) });
    }

    func publicKey() -> PublicKey {
        return pubkey;
    }

    func privateKey() -> PrivateKey {
        return privkey;
    }

    func identityKey() -> IdentityKey {
        return IdentityKey(pk: publicKey());
    }
}
