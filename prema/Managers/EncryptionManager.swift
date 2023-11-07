//
//  EncryptionManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import CryptoKit
import Foundation

class EncryptionUtility {
    static func encryptString(_ text: String, uid: String) -> String? {
        let key = getOrCreateEncryptionKey(uid: uid)
        guard let data = text.data(using: .utf8) else { return nil }
        if let sealedBox = try? AES.GCM.seal(data, using: key) {
            return sealedBox.combined?.base64EncodedString()
        }
        return nil
    }

    static func decryptString(_ encryptedString: String, uid: String) -> String? {
        let key = getOrCreateEncryptionKey(uid: uid)
        guard let data = Data(base64Encoded: encryptedString) else { return nil }
        if let sealedBox = try? AES.GCM.SealedBox(combined: data),
           let decryptedData = try? AES.GCM.open(sealedBox, using: key) {
            return String(data: decryptedData, encoding: .utf8)
        }
        return nil
    }

    private static func getOrCreateEncryptionKey(uid: String) -> SymmetricKey {
        let keyIdentifier = "encryptionKey_\(uid)"

        if let storedKey = UserDefaults.standard.getEncryptionKey(forKey: keyIdentifier) {
            return storedKey
        } else {
            let newKey = SymmetricKey(size: .bits256)
            UserDefaults.standard.setEncryptionKey(newKey, forKey: keyIdentifier)
            return newKey
        }
    }
}

extension UserDefaults {
    private static let encryptionKeyKey = "encryptionKey"

    func setEncryptionKey(_ key: SymmetricKey, forKey userDefaultsKey: String) {
        let keyData = key.withUnsafeBytes { Data($0) }
        set(keyData, forKey: userDefaultsKey)
    }

    func getEncryptionKey(forKey userDefaultsKey: String) -> SymmetricKey? {
        guard let keyData = data(forKey: userDefaultsKey) else { return nil }
        return SymmetricKey(data: keyData)
    }
}

