import Foundation
import CallKit

// ⚠️ PAS DE @objc(CallDirectoryHandler) ici !
// Le Info.plist pointe sur "$(PRODUCT_MODULE_NAME).CallDirectoryHandler"
// = "CallDirectoryHandler.CallDirectoryHandler" après build.
// Avec @objc(CallDirectoryHandler), iOS cherche CallDirectoryHandler.CallDirectoryHandler
// mais trouve seulement "CallDirectoryHandler" → erreur d'activation.
// Sans @objc override, Swift génère automatiquement le bon nom ObjC qui correspond.

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        addBlockingPhoneNumbers(to: context)
        context.completeRequest()
    }

    private func addBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Bloque tous les +33 9 48 XX XX XX (1 000 000 numéros)
        // Format E.164 sans '+' : 33948000000 → 33948999999
        let base: Int64 = 33_948_000_000
        let count: Int64 = 1_000_000
        for i in Int64(0)..<count {
            context.addBlockingEntry(withNextSequentialPhoneNumber: base + i)
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // iOS affichera "erreur d'activation" si on arrive ici
    }
}
