import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // En mode incrémental, on ne fait rien (on a déjà tout chargé)
        if context.isIncremental {
            context.completeRequest()
            return
        }

        addAllBlockingPhoneNumbers(to: context)
        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Test : les 10 premiers +33 9 48… (33948000000 → 33948000009)
        let base: Int64 = 33_948_000_000
        let count: Int64 = 10
        for i in Int64(0)..<count {
            context.addBlockingEntry(withNextSequentialPhoneNumber: base + i)
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // L'extension a échoué — iOS affichera "erreur d'activation"
    }
}
