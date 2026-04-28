import UIKit
import AudioToolbox

// MARK: - Écran "Appel entrant" style iOS
class IncomingCallViewController: UIViewController {

    private let callerName:   String
    private let callerNumber: String

    private var ringTimer:  Timer?
    private var ringCount = 0

    init(callerName: String, callerNumber: String) {
        self.callerName   = callerName
        self.callerNumber = callerNumber
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildCallScreen()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRinging()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - UI
    private func buildCallScreen() {
        // Fond dégradé style iOS
        let grad = CAGradientLayer()
        grad.frame = view.bounds
        grad.colors = [
            UIColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1).cgColor,
        ]
        view.layer.insertSublayer(grad, at: 0)

        // Avatar
        let avatar = UIView()
        avatar.backgroundColor = UIColor(white: 0.25, alpha: 1)
        avatar.layer.cornerRadius = 60
        avatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)

        let avatarEmoji = UILabel()
        avatarEmoji.text = "📞"
        avatarEmoji.font = .systemFont(ofSize: 50)
        avatarEmoji.textAlignment = .center
        avatarEmoji.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(avatarEmoji)

        // Étiquette "Appel entrant"
        let incomingLbl = makeLabel("Appel entrant", size: 15, weight: .regular, color: UIColor(white: 0.7, alpha: 1))
        incomingLbl.textAlignment = .center

        // Nom
        let nameLbl = makeLabel(callerName, size: 34, weight: .bold, color: .white)
        nameLbl.textAlignment = .center
        nameLbl.adjustsFontSizeToFitWidth = true

        // Numéro
        let numLbl = makeLabel(callerNumber, size: 16, weight: .regular, color: UIColor(white: 0.65, alpha: 1))
        numLbl.textAlignment = .center

        // Boutons Refuser / Accepter
        let declineBtn = makeCallButton(
            icon: "phone.down.fill",
            label: "Refuser",
            color: UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)
        )
        declineBtn.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)

        let acceptBtn = makeCallButton(
            icon: "phone.fill",
            label: "Accepter",
            color: UIColor(red: 0.2, green: 0.78, blue: 0.38, alpha: 1)
        )
        acceptBtn.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)

        let btnRow = UIStackView(arrangedSubviews: [declineBtn, UIView(), acceptBtn])
        btnRow.axis = .horizontal
        btnRow.distribution = .equalCentering
        btnRow.translatesAutoresizingMaskIntoConstraints = false

        // Boutons secondaires style iOS (muet, rappel)
        let remindBtn  = makeSmallButton(icon: "clock.arrow.circlepath", label: "Rappel")
        let muteBtn    = makeSmallButton(icon: "message.fill", label: "Message")
        let smallRow   = UIStackView(arrangedSubviews: [remindBtn, muteBtn])
        smallRow.axis = .horizontal
        smallRow.spacing = 60
        smallRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(incomingLbl)
        view.addSubview(nameLbl)
        view.addSubview(numLbl)
        view.addSubview(smallRow)
        view.addSubview(btnRow)

        NSLayoutConstraint.activate([
            avatar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            avatar.widthAnchor.constraint(equalToConstant: 120),
            avatar.heightAnchor.constraint(equalToConstant: 120),

            avatarEmoji.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            avatarEmoji.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),

            incomingLbl.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 20),
            incomingLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameLbl.topAnchor.constraint(equalTo: incomingLbl.bottomAnchor, constant: 8),
            nameLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            numLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 6),
            numLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            smallRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            smallRow.bottomAnchor.constraint(equalTo: btnRow.topAnchor, constant: -50),

            btnRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            btnRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            btnRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            btnRow.heightAnchor.constraint(equalToConstant: 100),
        ])

        // Animation de pulsation sur l'avatar
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0; pulse.toValue = 1.08
        pulse.duration = 0.7; pulse.autoreverses = true
        pulse.repeatCount = .infinity
        avatar.layer.add(pulse, forKey: "pulse")
    }

    // MARK: - Actions
    @objc private func declineTapped() {
        stopRinging()
        dismiss(animated: false)
    }

    @objc private func acceptTapped() {
        stopRinging()
        showCallInProgress()
    }

    private func showCallInProgress() {
        let vc = CallInProgressViewController(callerName: callerName, callerNumber: callerNumber)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }

    // MARK: - Sonnerie via Taptic + son système
    private func startRinging() {
        ringTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.ring()
        }
        ring()
    }

    private func ring() {
        // Son système de téléphone (kSystemSoundID_Vibrate = 4095)
        AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil)
        // Son d'appel entrant iOS (1000 = nouvelle alerte mail-like, 1005 = old phone)
        AudioServicesPlaySystemSound(1005)
    }

    private func stopRinging() {
        ringTimer?.invalidate()
        ringTimer = nil
        AudioServicesStopSystemSound(1005)
    }

    // MARK: - Helpers
    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text; l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeCallButton(icon: String, label: String, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalToConstant: 80).isActive = true

        let circle = UIButton(type: .system)
        circle.backgroundColor = color
        circle.layer.cornerRadius = 36
        circle.tintColor = .white
        if let img = UIImage(systemName: icon) {
            circle.setImage(img.withConfiguration(UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)), for: .normal)
        }
        circle.translatesAutoresizingMaskIntoConstraints = false
        // Transmet les touches au container (pour .addTarget)
        circle.isUserInteractionEnabled = false

        let lbl = UILabel()
        lbl.text = label; lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor(white: 0.8, alpha: 1); lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let tap = UITapGestureRecognizer()
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true

        container.addSubview(circle); container.addSubview(lbl)
        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: container.topAnchor),
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: 72),
            circle.heightAnchor.constraint(equalToConstant: 72),
            lbl.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 8),
            lbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        // On ajoute le vrai bouton par-dessus transparent
        let realBtn = UIButton(type: .system)
        realBtn.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(realBtn)
        NSLayoutConstraint.activate([
            realBtn.topAnchor.constraint(equalTo: container.topAnchor),
            realBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            realBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            realBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        realBtn.tag = (label == "Refuser") ? 0 : 1
        realBtn.addTarget(self, action: #selector(callButtonTapped(_:)), for: .touchUpInside)
        return container
    }

    @objc private func callButtonTapped(_ sender: UIButton) {
        if sender.tag == 0 { declineTapped() } else { acceptTapped() }
    }

    private func makeSmallButton(icon: String, label: String) -> UIView {
        let v = UIView(); v.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImageView()
        if let i = UIImage(systemName: icon) {
            img.image = i.withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        }
        img.tintColor = UIColor(white: 0.6, alpha: 1); img.contentMode = .center
        img.translatesAutoresizingMaskIntoConstraints = false
        let lbl = UILabel()
        lbl.text = label; lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = UIColor(white: 0.6, alpha: 1); lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(img); v.addSubview(lbl)
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: v.topAnchor),
            img.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            img.widthAnchor.constraint(equalToConstant: 50),
            img.heightAnchor.constraint(equalToConstant: 50),
            lbl.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 4),
            lbl.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            lbl.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
    }
}
