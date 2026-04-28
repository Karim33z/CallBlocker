import UIKit
import AudioToolbox

// MARK: - Écran de configuration
class SetupViewController: UIViewController {

    private let callerField   = UITextField()
    private let numberField   = UITextField()
    private let delayLabel    = UILabel()
    private let delaySlider   = UISlider()
    private let delayValueLbl = UILabel()
    private let callBtn       = UIButton(type: .system)
    private let countdownLbl  = UILabel()
    private var timer: Timer?
    private var remaining: Int = 0

    // Presets rapides
    private let presets: [(name: String, number: String)] = [
        ("Maman 👩", "06 12 34 56 78"),
        ("Boss 💼", "01 45 67 89 00"),
        ("Docteur 🏥", "04 72 11 22 33"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1)
        buildUI()
    }

    private func buildUI() {
        // --- Titre ---
        let title = makeLabel("📞 Faux Appel", size: 26, weight: .bold, color: .white)
        title.textAlignment = .center

        let sub = makeLabel("Simule un appel entrant pour s'échapper\nd'une situation gênante.", size: 13, weight: .regular, color: UIColor(white: 0.5, alpha: 1))
        sub.textAlignment = .center
        sub.numberOfLines = 2

        // --- Champ nom ---
        let nameLbl = makeLabel("Nom de l'appelant", size: 12, weight: .medium, color: UIColor(white: 0.45, alpha: 1))
        styleField(callerField, placeholder: "ex : Maman 👩")

        // --- Champ numéro ---
        let numLbl = makeLabel("Numéro affiché", size: 12, weight: .medium, color: UIColor(white: 0.45, alpha: 1))
        styleField(numberField, placeholder: "ex : 06 12 34 56 78")
        numberField.keyboardType = .phonePad

        // --- Presets ---
        let presetLbl = makeLabel("Presets rapides :", size: 12, weight: .medium, color: UIColor(white: 0.45, alpha: 1))
        let presetStack = UIStackView()
        presetStack.axis = .horizontal
        presetStack.spacing = 10
        presetStack.distribution = .fillEqually
        presetStack.translatesAutoresizingMaskIntoConstraints = false

        for (i, p) in presets.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(p.name, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
            btn.layer.cornerRadius = 10
            btn.tag = i
            btn.addTarget(self, action: #selector(presetTapped(_:)), for: .touchUpInside)
            presetStack.addArrangedSubview(btn)
        }

        // --- Slider délai ---
        let sliderLbl = makeLabel("Délai avant l'appel", size: 12, weight: .medium, color: UIColor(white: 0.45, alpha: 1))
        delaySlider.minimumValue = 5
        delaySlider.maximumValue = 300
        delaySlider.value = 30
        delaySlider.minimumTrackTintColor = UIColor(red: 0.2, green: 0.7, blue: 0.4, alpha: 1)
        delaySlider.thumbTintColor = .white
        delaySlider.translatesAutoresizingMaskIntoConstraints = false
        delaySlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        updateDelayLabel()

        delayValueLbl.textAlignment = .right
        delayValueLbl.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        delayValueLbl.textColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
        delayValueLbl.translatesAutoresizingMaskIntoConstraints = false

        let sliderRow = UIStackView(arrangedSubviews: [delaySlider, delayValueLbl])
        sliderRow.axis = .horizontal
        sliderRow.spacing = 12
        sliderRow.translatesAutoresizingMaskIntoConstraints = false

        // --- Bouton LANCER ---
        callBtn.setTitle("⏱  Lancer le faux appel", for: .normal)
        callBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .heavy)
        callBtn.setTitleColor(.white, for: .normal)
        callBtn.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.35, alpha: 1)
        callBtn.layer.cornerRadius = 16
        callBtn.layer.shadowColor   = UIColor(red: 0.2, green: 0.7, blue: 0.35, alpha: 0.5).cgColor
        callBtn.layer.shadowOffset  = CGSize(width: 0, height: 5)
        callBtn.layer.shadowRadius  = 14
        callBtn.layer.shadowOpacity = 1
        callBtn.translatesAutoresizingMaskIntoConstraints = false
        callBtn.addTarget(self, action: #selector(launchTapped), for: .touchUpInside)

        // --- Countdown ---
        countdownLbl.text = ""
        countdownLbl.font = .monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        countdownLbl.textColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
        countdownLbl.textAlignment = .center
        countdownLbl.isHidden = true
        countdownLbl.translatesAutoresizingMaskIntoConstraints = false

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Annuler", for: .normal)
        cancelBtn.setTitleColor(UIColor(white: 0.5, alpha: 1), for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 14)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false

        // --- Stack principal ---
        let stack = UIStackView(arrangedSubviews: [
            title, sub,
            nameLbl, callerField,
            numLbl, numberField,
            presetLbl, presetStack,
            sliderLbl, sliderRow,
        ])
        stack.axis = .vertical
        stack.spacing = 10
        stack.setCustomSpacing(20, after: sub)
        stack.setCustomSpacing(6, after: nameLbl)
        stack.setCustomSpacing(16, after: callerField)
        stack.setCustomSpacing(6, after: numLbl)
        stack.setCustomSpacing(16, after: numberField)
        stack.setCustomSpacing(6, after: presetLbl)
        stack.setCustomSpacing(20, after: presetStack)
        stack.setCustomSpacing(6, after: sliderLbl)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)
        scroll.addSubview(stack)
        view.addSubview(callBtn)
        view.addSubview(countdownLbl)
        view.addSubview(cancelBtn)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: callBtn.topAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -48),

            presetStack.heightAnchor.constraint(equalToConstant: 40),
            delayValueLbl.widthAnchor.constraint(equalToConstant: 70),

            callBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            callBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            callBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            callBtn.heightAnchor.constraint(equalToConstant: 58),

            countdownLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            cancelBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelBtn.topAnchor.constraint(equalTo: countdownLbl.bottomAnchor, constant: 16),
        ])
    }

    // MARK: - Helpers UI
    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text; l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func styleField(_ f: UITextField, placeholder: String) {
        f.placeholder = placeholder
        f.font = .systemFont(ofSize: 16)
        f.textColor = .white
        f.backgroundColor = UIColor(white: 0.13, alpha: 1)
        f.layer.cornerRadius = 12
        f.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        f.leftViewMode = .always
        f.heightAnchor.constraint(equalToConstant: 48).isActive = true
        f.translatesAutoresizingMaskIntoConstraints = false
        f.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.3, alpha: 1)]
        )
    }

    // MARK: - Actions
    @objc private func presetTapped(_ sender: UIButton) {
        let p = presets[sender.tag]
        callerField.text  = p.name
        numberField.text  = p.number
        view.endEditing(true)
    }

    @objc private func sliderChanged() { updateDelayLabel() }

    private func updateDelayLabel() {
        let v = Int(delaySlider.value)
        delayValueLbl.text = v < 60 ? "\(v) sec" : "\(v/60) min \(v%60) sec"
    }

    @objc private func launchTapped() {
        view.endEditing(true)
        let name   = callerField.text?.isEmpty == false ? callerField.text! : "Numéro inconnu"
        let number = numberField.text?.isEmpty == false ? numberField.text! : "06 00 00 00 00"
        remaining  = Int(delaySlider.value)

        // UI countdown
        callBtn.isHidden      = true
        countdownLbl.isHidden = false
        countdownLbl.text     = "\(remaining)"

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.remaining -= 1
            self.countdownLbl.text = "\(self.remaining)"
            if self.remaining <= 0 {
                t.invalidate()
                self.showIncomingCall(name: name, number: number)
            }
        }
    }

    @objc private func cancelTapped() {
        timer?.invalidate()
        timer = nil
        countdownLbl.isHidden = true
        callBtn.isHidden      = false
    }

    private func showIncomingCall(name: String, number: String) {
        countdownLbl.isHidden = true
        callBtn.isHidden      = false
        let vc = IncomingCallViewController(callerName: name, callerNumber: number)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
}
