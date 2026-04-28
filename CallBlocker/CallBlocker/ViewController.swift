import UIKit
import CallKit

class ViewController: UIViewController {

    private let button = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .gray)
    private let progressLabel = UILabel()

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
        subtitle.text = "Bloque tous les +33 9 48 XX XX XX\n(1 000 000 numéros)"
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
        statusLabel.numberOfLines = 4
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        progressLabel.font = .systemFont(ofSize: 11)
        progressLabel.textColor = UIColor(white: 0.35, alpha: 1)
        progressLabel.textAlignment = .center
        progressLabel.numberOfLines = 2
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

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

            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            progressLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }

    private func extensionBundleID() -> String {
        // Découverte dynamique de l'extension dans le .app
        // Sideloadly peut changer les bundle IDs — on lit directement dans PlugIns/
        if let pluginsURL = Bundle.main.builtInPlugInsURL,
           let contents = try? FileManager.default.contentsOfDirectory(
               at: pluginsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for url in contents where url.pathExtension == "appex" {
                if let bundle = Bundle(url: url),
                   let info = bundle.infoDictionary,
                   let ext = info["NSExtension"] as? [String: Any],
                   let point = ext["NSExtensionPointIdentifier"] as? String,
                   point == "com.apple.callkit.call-directory",
                   let bundleID = bundle.bundleIdentifier {
                    return bundleID
                }
            }
        }
        // Fallback
        let main = Bundle.main.bundleIdentifier ?? "com.bcs.incomingBlocker"
        return main + ".CallDirectoryHandler"
    }

    private func checkStatus() {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
            withIdentifier: extensionBundleID()
        ) { status, _ in
            DispatchQueue.main.async {
                switch status {
                case .enabled:
                    self.setStatus("✅ Bloqueur actif !", color: .systemGreen)
                    self.button.setTitle("🔄 Recharger le blocage", for: .normal)
                case .disabled:
                    self.setStatus(
                        "⚠️ Active d'abord le bloqueur :\nRéglages > Téléphone > Blocage d'appels et identification > CallBlocker",
                        color: .systemOrange
                    )
                default:
                    self.setStatus("Vérifie le statut...", color: .gray)
                }
            }
        }
    }

    @objc private func blockTapped() {
        button.isEnabled = false
        spinner.startAnimating()
        setStatus("Chargement de 1 000 000 numéros\n(peut prendre 10-30s)...", color: .systemYellow)
        progressLabel.text = ""

        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: extensionBundleID()
        ) { error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.button.isEnabled = true
                if let error = error {
                    let code = (error as NSError).code
                    self.setStatus(
                        "❌ Erreur (code \(code))\n→ Active d'abord le bloqueur dans\nRéglages > Téléphone > Blocage d'appels",
                        color: .systemRed
                    )
                    self.progressLabel.text = error.localizedDescription
                } else {
                    self.setStatus("✅ 1 000 000 numéros bloqués !", color: .systemGreen)
                    self.button.setTitle("🔄 Recharger le blocage", for: .normal)
                    self.progressLabel.text = ""
                }
            }
        }
    }

    private func setStatus(_ text: String, color: UIColor) {
        statusLabel.text = text
        statusLabel.textColor = color
    }
}
