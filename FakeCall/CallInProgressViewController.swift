import UIKit

// MARK: - Écran "Appel en cours"
class CallInProgressViewController: UIViewController {

    private let callerName:   String
    private let callerNumber: String
    private let timerLabel = UILabel()
    private var elapsed    = 0
    private var callTimer: Timer?

    init(callerName: String, callerNumber: String) {
        self.callerName   = callerName
        self.callerNumber = callerNumber
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsed += 1
            self?.updateTimer()
        }
    }

    override var prefersStatusBarHidden: Bool { true }

    private func buildUI() {
        let grad = CAGradientLayer()
        grad.frame = view.bounds
        grad.colors = [
            UIColor(red: 0.05, green: 0.14, blue: 0.10, alpha: 1).cgColor,
            UIColor(red: 0.03, green: 0.08, blue: 0.06, alpha: 1).cgColor,
        ]
        view.layer.insertSublayer(grad, at: 0)

        let avatar = UIView()
        avatar.backgroundColor = UIColor(white: 0.2, alpha: 1)
        avatar.layer.cornerRadius = 55
        avatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)

        let avatarLbl = UILabel()
        avatarLbl.text = "📞"; avatarLbl.font = .systemFont(ofSize: 44)
        avatarLbl.textAlignment = .center
        avatarLbl.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(avatarLbl)

        let statusLbl = makeLabel("Appel en cours…", size: 15, color: UIColor(white: 0.6, alpha: 1))
        statusLbl.textAlignment = .center

        let nameLbl = makeLabel(callerName, size: 30, weight: .bold, color: .white)
        nameLbl.textAlignment = .center

        timerLabel.text = "0:00"; timerLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        timerLabel.textColor = UIColor(red: 0.2, green: 0.85, blue: 0.45, alpha: 1)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        // Bouton raccrocher
        let hangup = UIButton(type: .system)
        hangup.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)
        hangup.layer.cornerRadius = 38
        hangup.tintColor = .white
        if let img = UIImage(systemName: "phone.down.fill") {
            hangup.setImage(img.withConfiguration(UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)), for: .normal)
        }
        hangup.translatesAutoresizingMaskIntoConstraints = false
        hangup.addTarget(self, action: #selector(hangupTapped), for: .touchUpInside)

        let hangupLbl = makeLabel("Raccrocher", size: 12, color: UIColor(white: 0.6, alpha: 1))
        hangupLbl.textAlignment = .center

        view.addSubview(statusLbl); view.addSubview(nameLbl)
        view.addSubview(timerLabel); view.addSubview(hangup); view.addSubview(hangupLbl)

        NSLayoutConstraint.activate([
            avatar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 110),
            avatar.widthAnchor.constraint(equalToConstant: 110),
            avatar.heightAnchor.constraint(equalToConstant: 110),
            avatarLbl.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            avatarLbl.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),

            statusLbl.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 20),
            statusLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameLbl.topAnchor.constraint(equalTo: statusLbl.bottomAnchor, constant: 8),
            nameLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            timerLabel.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            hangup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangup.bottomAnchor.constraint(equalTo: hangupLbl.topAnchor, constant: -10),
            hangup.widthAnchor.constraint(equalToConstant: 76),
            hangup.heightAnchor.constraint(equalToConstant: 76),

            hangupLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangupLbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])
    }

    private func updateTimer() {
        let m = elapsed / 60; let s = elapsed % 60
        timerLabel.text = String(format: "%d:%02d", m, s)
    }

    @objc private func hangupTapped() {
        callTimer?.invalidate()
        // Retour à l'écran de setup (on dismiss les 2 VCs)
        presentingViewController?.dismiss(animated: false) {
            self.presentingViewController?.dismiss(animated: false)
        }
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor) -> UILabel {
        let l = UILabel(); l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
}
