import UIKit

class ViewController: UIViewController {

    // MARK: - UI
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let generateBtn   = UIButton(type: .system)
    private let progressBar   = UIProgressView(progressViewStyle: .bar)
    private let statusLabel   = UILabel()
    private let instructLabel = UILabel()

    // Plage : +33 9 48 00 00 00  →  +33 9 48 99 99 99  (1 000 000 numéros)
    private let base: Int64 = 33_948_000_000
    private let total: Int  = 1_000_000

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.09, alpha: 1)
        buildUI()
    }

    // MARK: - Build UI
    private func buildUI() {
        // --- Titre ---
        titleLabel.text = "🚫 Anti-Spam +33 9 48"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // --- Sous-titre ---
        subtitleLabel.text = "Génère 1 000 000 contacts « SPAM »\npour identifier leurs appels automatiquement."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // --- Bouton ---
        generateBtn.setTitle("🔥 Générer le fichier VCF", for: .normal)
        generateBtn.titleLabel?.font = .systemFont(ofSize: 19, weight: .heavy)
        generateBtn.setTitleColor(.white, for: .normal)
        generateBtn.backgroundColor = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
        generateBtn.layer.cornerRadius = 18
        generateBtn.layer.shadowColor  = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 0.55).cgColor
        generateBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
        generateBtn.layer.shadowRadius = 14
        generateBtn.layer.shadowOpacity = 1
        generateBtn.translatesAutoresizingMaskIntoConstraints = false
        generateBtn.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        view.addSubview(generateBtn)

        // --- Barre de progression ---
        progressBar.progressTintColor = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
        progressBar.trackTintColor    = UIColor(white: 0.2, alpha: 1)
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true
        progressBar.progress = 0
        progressBar.isHidden = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)

        // --- Statut ---
        statusLabel.text = ""
        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = UIColor(white: 0.55, alpha: 1)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // --- Instructions ---
        instructLabel.text = """
        📋 Comment ça marche :
        1. Appuie sur le bouton → le fichier VCF est généré
        2. Partage-le → ouvre-le dans l'app Contacts
        3. Importe les contacts
        4. Chaque appel de +33 9 48 XX XX XX affichera "SPAM Démarchage" 📵
        """
        instructLabel.font = .systemFont(ofSize: 13)
        instructLabel.textColor = UIColor(white: 0.4, alpha: 1)
        instructLabel.textAlignment = .left
        instructLabel.numberOfLines = 0
        instructLabel.backgroundColor = UIColor(white: 0.1, alpha: 1)
        instructLabel.layer.cornerRadius = 12
        instructLabel.clipsToBounds = true
        instructLabel.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        instructLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructLabel)

        // --- Contraintes ---
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            generateBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            generateBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateBtn.widthAnchor.constraint(equalToConstant: 280),
            generateBtn.heightAnchor.constraint(equalToConstant: 60),

            progressBar.topAnchor.constraint(equalTo: generateBtn.bottomAnchor, constant: 28),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            progressBar.heightAnchor.constraint(equalToConstant: 8),

            statusLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            instructLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            instructLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Action
    @objc private func generateTapped() {
        generateBtn.isEnabled = false
        progressBar.isHidden  = false
        progressBar.progress  = 0
        setStatus("Démarrage...", color: .systemYellow)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.generateVCF()
        }
    }

    // MARK: - Génération VCF
    private func generateVCF() {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AntiSpam_33948.vcf")

        FileManager.default.createFile(atPath: outputURL.path, contents: nil)
        guard let handle = try? FileHandle(forWritingTo: outputURL) else {
            DispatchQueue.main.async { self.setStatus("❌ Impossible de créer le fichier", color: .systemRed) }
            return
        }

        let updateFreq = 10_000  // on met à jour l'UI tous les 10 000
        for i in 0..<total {
            let number = base + Int64(i)
            let entry = """
            BEGIN:VCARD\r
            VERSION:3.0\r
            FN:SPAM Démarchage\r
            TEL;TYPE=CELL:+\(number)\r
            END:VCARD\r\n
            """
            if let data = entry.data(using: .utf8) {
                handle.write(data)
            }

            if i % updateFreq == 0 {
                let progress = Float(i) / Float(total)
                let count    = i
                DispatchQueue.main.async {
                    self.progressBar.setProgress(progress, animated: false)
                    self.setStatus("Génération... \(count / 1000)k / 1 000k", color: .systemYellow)
                }
            }
        }

        handle.closeFile()

        DispatchQueue.main.async {
            self.progressBar.setProgress(1.0, animated: true)
            self.setStatus("✅ Fichier prêt ! Partage-le maintenant.", color: .systemGreen)
            self.generateBtn.isEnabled = true
            self.generateBtn.setTitle("📤 Partager le fichier VCF", for: .normal)
            self.generateBtn.removeTarget(self, action: #selector(self.generateTapped), for: .touchUpInside)
            self.generateBtn.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
            self.shareTapped()  // ouvre le share sheet automatiquement
        }
    }

    // MARK: - Partage
    @objc private func shareTapped() {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AntiSpam_33948.vcf")
        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            setStatus("❌ Fichier introuvable, régénère", color: .systemRed)
            return
        }
        let ac = UIActivityViewController(activityItems: [outputURL], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = generateBtn
        present(ac, animated: true)
    }

    private func setStatus(_ text: String, color: UIColor) {
        statusLabel.text      = text
        statusLabel.textColor = color
    }
}
