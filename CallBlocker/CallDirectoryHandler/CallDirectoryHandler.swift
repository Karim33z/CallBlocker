import Foundation
import CallKit

// @objc(CallDirectoryHandler) donne à la classe le nom ObjC EXACT "CallDirectoryHandler"
// Le Info.plist dit NSExtensionPrincipalClass = "CallDirectoryHandler" (sans module, sans variable)
// → iOS fait NSClassFromString("CallDirectoryHandler") → trouve exactement cette classe
// → AUCUNE ambiguité, aucune dépendance à $(PRODUCT_MODULE_NAME)

@objc(CallDirectoryHandler)
class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        addBlockingPhoneNumbers(to: context)
        context.completeRequest()
    }

    private func addBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // +33 9 48 XX XX XX en format E.164 sans le '+', ordre strictement croissant
        // On commence avec 1000 numéros (test stable)
        let base: Int64 = 33_948_000_000
        let count: Int64 = 1_000
        for i in Int64(0)..<count {
            context.addBlockingEntry(withNextSequentialPhoneNumber: base + i)
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // iOS affiche "erreur d'activation" si on arrive ici
    }
}
