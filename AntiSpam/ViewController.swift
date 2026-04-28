import UIKit

class ViewController: UIViewController {

    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let generateBtn   = UIButton(type: .system)
    private let progressBg    = UIView()
    private let progressFill  = UIView()
    private let progressLabel = UILabel()
    private let statusLabel   = UILabel()
    private let instructBox   = UIView()
    private let instructLabel = UILabel()

    private let base: Int64 = 33_948_000_000
    private let total       = 1_000_000
    private var vcfURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.09, alpha: 1)
        buildUI()
    }

    // MARK: - UI
    private func buildUI() {
        // Titre
        titleLabel.text = "🚫 Anti-Spam +33 9 48"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Sous-titre
        subtitleLabel.text = "Génère 1 000 000 contacts « SPAM »\npour identifier leurs appels."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Bouton
        generateBtn.setTitle("🔥 Générer le fichier VCF", for: .normal)
        generateBtn.titleLabel?.font = .systemFont(ofSize: 19, weight: .heavy)
        generateBtn.setTitleColor(.white, for: .normal)
        generateBtn.backgroundColor = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
        generateBtn.layer.cornerRadius = 18
        generateBtn.layer.shadowColor   = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 0.5).cgColor
        generateBtn.layer.shadowOffset  = CGSize(width: 0, height: 5)
        generateBtn.layer.shadowRadius  = 14
        generateBtn.layer.shadowOpacity = 1
        generateBtn.translatesAutoresizingMaskIntoConstraints = false
        generateBtn.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        view.addSubview(generateBtn)

        // Barre de progression (custom, pas UIProgressView)
        progressBg.backgroundColor = UIColor(white: 0.18, alpha: 1)
        progressBg.layer.cornerRadius = 5
        progressBg.clipsToBounds = true
        progressBg.isHidden = true
        progressBg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBg)

        progressFill.backgroundColor = UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBg.addSubview(progressFill)

        // Contraintes internes de progressFill (on ajuste la width en runtime)
        progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor).isActive = true
        progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor).isActive = true
        progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor).isActive = true
        progressFillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidth?.isActive = true

        // Label progression
        progressLabel.text = ""
        progressLabel.font = .systemFont(ofSize: 13, weight: .medium)
        progressLabel.textColor = UIColor(white: 0.6, alpha: 1)
        progressLabel.textAlignment = .center
        progressLabel.isHidden = true
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        // Statut
        statusLabel.text = ""
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = UIColor(white: 0.55, alpha: 1)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 3
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Boîte d'instructions
        instructBox.backgroundColor = UIColor(white: 0.1, alpha: 1)
        instructBox.layer.cornerRadius = 14
        instructBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructBox)

        instructLabel.text = """
📋 Comment ça marche :

1. Appuie sur le bouton → le VCF est généré
2. Le partage s'ouvre → "Ouvrir dans Contacts"
3. Importe les contacts
4. Chaque appel +33 9 48 XX XX XX affiche
   "SPAM Démarchage" 📵
"""
        instructLabel.font = .systemFont(ofSize: 13)
        instructLabel.textColor = UIColor(white: 0.5, alpha: 1)
        instructLabel.numberOfLines = 0
        instructLabel.translatesAutoresizingMaskIntoConstraints = false
        instructBox.addSubview(instructLabel)

        // Contraintes
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            generateBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 44),
            generateBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateBtn.widthAnchor.constraint(equalToConstant: 280),
            generateBtn.heightAnchor.constraint(equalToConstant: 60),

            progressBg.topAnchor.constraint(equalTo: generateBtn.bottomAnchor, constant: 30),
            progressBg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            progressBg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            progressBg.heightAnchor.constraint(equalToConstant: 10),

            progressLabel.topAnchor.constraint(equalTo: progressBg.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            instructBox.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 36),
            instructBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            instructLabel.topAnchor.constraint(equalTo: instructBox.topAnchor, constant: 16),
            instructLabel.bottomAnchor.constraint(equalTo: instructBox.bottomAnchor, constant: -16),
            instructLabel.leadingAnchor.constraint(equalTo: instructBox.leadingAnchor, constant: 16),
            instructLabel.trailingAnchor.constraint(equalTo: instructBox.trailingAnchor, constant: -16),
        ])
    }

    private var progressFillWidth: NSLayoutConstraint?

    private func setProgress(_ ratio: Float) {
        let maxW = view.bounds.width - 72
        progressFillWidth?.constant = CGFloat(ratio) * maxW
    }

    // MARK: - Actions
    @objc private func generateTapped() {
        generateBtn.isEnabled = false
        progressBg.isHidden   = false
        progressLabel.isHidden = false
        setProgress(0)
        setStatus("Démarrage...", color: .systemYellow)

        DispatchQueue.global(qos: .userInitiated).async { self.generateVCF() }
    }

    @objc private func shareTapped() {
        guard let url = vcfURL else { return }
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = generateBtn
        present(ac, animated: true)
    }

    // MARK: - Génération
    private func generateVCF() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AntiSpam_33948.vcf")
        FileManager.default.createFile(atPath: url.path, contents: nil)
        guard let handle = try? FileHandle(forWritingTo: url) else {
            DispatchQueue.main.async {
                self.setStatus("❌ Impossible de créer le fichier", color: .systemRed)
                self.generateBtn.isEnabled = true
            }
            return
        }

        let freq = 20_000
        for i in 0..<total {
            let num   = base + Int64(i)
            let entry = "BEGIN:VCARD\r\nVERSION:3.0\r\nFN:SPAM Démarchage\r\nTEL;TYPE=CELL:+\(num)\r\nEND:VCARD\r\n"
            if let d = entry.data(using: .utf8) { handle.write(d) }

            if i % freq == 0 {
                let ratio = Float(i) / Float(total)
                let count = i / 1000
                DispatchQueue.main.async {
                    self.setProgress(ratio)
                    self.progressLabel.text = "\(count) 000 / 1 000 000"
                    self.setStatus("Génération en cours...", color: .systemYellow)
                }
            }
        }
        handle.closeFile()
        vcfURL = url

        DispatchQueue.main.async {
            self.setProgress(1)
            self.progressLabel.text = "1 000 000 / 1 000 000"
            self.setStatus("✅ Fichier prêt !", color: .systemGreen)
            self.generateBtn.isEnabled = true
            self.generateBtn.setTitle("📤 Partager le fichier VCF", for: .normal)
            self.generateBtn.removeTarget(self, action: #selector(self.generateTapped), for: .touchUpInside)
            self.generateBtn.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
            self.shareTapped()
        }
    }

    private func setStatus(_ text: String, color: UIColor) {
        statusLabel.text      = text
        statusLabel.textColor = color
    }
}
