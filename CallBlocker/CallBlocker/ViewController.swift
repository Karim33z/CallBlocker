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
        let title = UILabel()
        title.text = "☎️ Anti-Démarchage"
        title.font = .systemFont(ofSize: 28, weight: .bold)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let subtitle = UILabel()
        subtitle.text = "Bloque les +33 9 48 XX XX XX\n(1000 numéros - phase test)"
        subtitle.font = .systemFont(ofSize: 15)
        subtitle.textColor = UIColor(white: 0.6, alpha: 1)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 2
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitle)

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

        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(white: 0.5, alpha: 1)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 5
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Label de debug : affiche le bundle ID de l'extension trouvée
        debugLabel.font = .monospacedSystemFont(ofSize: 9, size: 9)
        debugLabel.textColor = UIColor(white: 0.3, alpha: 1)
        debugLabel.textAlignment = .center
        debugLabel.numberOfLines = 3
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
            spinner.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 24),

            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10),
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            debugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            debugLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            debugLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ])
    }

    private func extensionBundleID() -> String {
        // Cherche le .appex dans PlugIns et lit son bundle ID directement
        var found = "NON TROUVÉE"
        if let pluginsURL = Bundle.main.builtInPlugInsURL,
           let contents = try? FileManager.default.contentsOfDirectory(
               at: pluginsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for url in contents where url.pathExtension == "appex" {
                if let bundle = Bundle(url: url),
                   let info = bundle.infoDictionary,
                   let ext = info["NSExtension"] as? [String: Any],
                   let point = ext["NSExtensionPointIdentifier"] as? String,
                   point == "com.apple.callkit.call-directory",
                   let bid = bundle.bundleIdentifier {
                    found = bid
                    break
                }
            }
        }
        // Affiche en debug
        DispatchQueue.main.async { self.debugLabel.text = "ExtID: \(found)" }
        return found
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
                        "⚠️ Active dans :\nRéglages → Téléphone\n→ Blocage d'appels et identification\n→ active CallBlocker",
                        color: .systemOrange
                    )
                default:
                    let code = (error as? NSError)?.code ?? -1
                    self.setStatus("❓ Statut inconnu (err code: \(code))", color: .gray)
                }
            }
        }
    }

    @objc private func blockTapped() {
        button.isEnabled = false
        spinner.startAnimating()
        setStatus("Rechargement en cours...", color: .systemYellow)

        let extID = extensionBundleID()
        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: extID
        ) { error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.button.isEnabled = true
                if let error = error {
                    let nsErr = error as NSError
                    // Codes CallKit : 1=noExtensionFound 2=loadingInterrupted 3=entriesOutOfOrder
                    // 4=duplicateEntries 5=maxExceeded 6=disabled 7=loading 8=unexpectedIncremental
                    self.setStatus(
                        "❌ Erreur code \(nsErr.code)\n\(nsErr.localizedDescription)\n→ Active d'abord dans Réglages",
                        color: .systemRed
                    )
                } else {
                    self.setStatus("✅ 1000 numéros bloqués !", color: .systemGreen)
                    self.button.setTitle("🔄 Recharger", for: .normal)
                }
            }
        }
    }

    private func setStatus(_ text: String, color: UIColor) {
        statusLabel.text = text
        statusLabel.textColor = color
    }
}

// Helper pour monospacedSystemFont en iOS 12
private extension UIFont {
    static func monospacedSystemFont(ofSize size: CGFloat, size _: CGFloat) -> UIFont {
        if #available(iOS 13.0, *) {
            return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
        }
        return UIFont(name: "Courier", size: size) ?? .systemFont(ofSize: size)
    }
}
