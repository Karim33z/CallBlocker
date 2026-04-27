import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    private static let lastLoadedAtKey = "CallDirectoryLastLoadedAt"

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // Important : ne traiter comme « incrémental » que si une baseline a déjà été
        // chargée dans ce sandbox d’extension. Sinon, un premier `isIncremental == true`
        // ferait `completeRequest()` sans aucune entrée → échec d’activation dans Réglages.
        let defaults = UserDefaults.standard
        let hasLoadedBefore = defaults.object(forKey: Self.lastLoadedAtKey) != nil

        if context.isIncremental, hasLoadedBefore {
            // Aucun delta pour l’instant : rechargement incrémental vide = OK.
            context.completeRequest()
            return
        }

        addAllBlockingPhoneNumbers(to: context)
        defaults.set(Date(), forKey: Self.lastLoadedAtKey)
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
