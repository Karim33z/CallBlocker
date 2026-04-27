import UIKit
import CallKit

class ViewController: UIViewController {

    private let button = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .gray)
    private let debugLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1)
        setupUI()
        checkStatus()
    }

    private func setupUI() {
        // Titre
        let title = UILabel()
        title.text = "☎️ Anti-Démarchage"
        title.font = .systemFont(ofSize: 28, weight: .bold)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        // Sous-titre
        let subtitle = UILabel()
        subtitle.text = "Bloque tous les +33 9 48 XX XX XX\n(1 000 000 numéros)"
        subtitle.font = .systemFont(ofSize: 15)
        subtitle.textColor = UIColor(white: 0.6, alpha: 1)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 2
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitle)

        // Bouton
        button.setTitle("🔥 Bloquer tous ces\nfoutus +33 9 48...", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 0.6).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(blockTapped), for: .touchUpInside)
        view.addSubview(button)

        // Spinner
        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        // Status
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(white: 0.5, alpha: 1)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 4
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Debug (bundle ID de l'extension trouvée)
        debugLabel.font = .systemFont(ofSize: 10)
        debugLabel.textColor = UIColor(white: 0.3, alpha: 1)
        debugLabel.textAlignment = .center
        debugLabel.numberOfLines = 2
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugLabel)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.bottomAnchor.constraint(equalTo: subtitle.topAnchor, constant: -10),

            subtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitle.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -50),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 110),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 30),

            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            debugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            debugLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            debugLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }

    // ────────────────────────────────────────────────────────────────────────
    // Découverte DYNAMIQUE de l'extension installée dans le .app
    // C'est la fix critique : on ne calcule plus le bundle ID, on le lit.
    // Sideloadly peut changer les identifiants — on trouve le bon directement.
    // ────────────────────────────────────────────────────────────────────────
    private func findExtensionBundleID() -> String? {
        guard let pluginsURL = Bundle.main.builtInPlugInsURL else {
            debugLabel.text = "⚠️ Aucun dossier PlugIns trouvé"
            return nil
        }
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: pluginsURL,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else {
            debugLabel.text = "⚠️ Impossible de lire PlugIns"
            return nil
        }

        for url in contents where url.pathExtension == "appex" {
            if let bundle = Bundle(url: url),
               let info = bundle.infoDictionary,
               let ext = info["NSExtension"] as? [String: Any],
               let point = ext["NSExtensionPointIdentifier"] as? String,
               point == "com.apple.callkit.call-directory",
               let bundleID = bundle.bundleIdentifier {
                debugLabel.text = "Extension: \(bundleID)"
                return bundleID
            }
        }
        debugLabel.text = "⚠️ Extension CallKit non trouvée dans PlugIns"
        return nil
    }

    private func extensionBundleID() -> String {
        if let found = findExtensionBundleID() {
            return found
        }
        // Fallback si la découverte échoue
        let main = Bundle.main.bundleIdentifier ?? "com.bcs.incomingBlocker"
        return main + ".CallDirectoryHandler"
    }

    private func checkStatus() {
        let extID = extensionBundleID()
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
            withIdentifier: extID
        ) { status, error in
            DispatchQueue.main.async {
                switch status {
                case .enabled:
                    self.setStatus("✅ Bloqueur actif !", color: .systemGreen)
                    self.button.setTitle("🔄 Recharger le blocage", for: .normal)
                case .disabled:
                    self.setStatus(
                        "⚠️ Bloqueur désactivé\n→ Réglages > Téléphone > Blocage d'appels\n→ Active « CallBlocker »",
                        color: .systemOrange
                    )
                default:
                    if let err = error {
                        self.setStatus("❓ Statut inconnu\n(\(err.localizedDescription))", color: .gray)
                    } else {
                        self.setStatus("❓ Statut inconnu", color: .gray)
                    }
                }
            }
        }
    }

    @objc private func blockTapped() {
        button.isEnabled = false
        spinner.startAnimating()
        setStatus("Chargement de 1 000 000 numéros...", color: .systemYellow)

        let extID = extensionBundleID()
        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: extID
        ) { error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.button.isEnabled = true
                if let error = error {
                    let nsErr = error as NSError
                    self.setStatus(
                        "❌ Erreur (code \(nsErr.code))\n→ Active d'abord le bloqueur dans Réglages > Téléphone > Blocage d'appels",
                        color: .systemRed
                    )
                } else {
                    self.setStatus("✅ 1 000 000 numéros bloqués !", color: .systemGreen)
                    self.button.setTitle("🔄 Recharger le blocage", for: .normal)
                }
            }
        }
    }

    private func setStatus(_ text: String, color: UIColor) {
        statusLabel.text = text
        statusLabel.textColor = color
    }
}
