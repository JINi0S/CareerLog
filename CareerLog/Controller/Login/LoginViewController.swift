//
//  LoginViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/2/25.
//

import AuthenticationServices
import Supabase
import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func loginDidSucceed()
}

class LoginViewController: UIViewController {
    
    /// 외부에서 전달 가능한 메시지
    var reasonMessage: String?
    weak var delegate: LoginViewControllerDelegate?
    
    private let providers: [AuthProvider] = [.apple/*, .google*/]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tintColor
        setupUI()
    }
    
    private func setupUI() {
        let logoImageView = UIImageView(image: UIImage(named: "moon"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Career Log"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = reasonMessage ?? "로그인하여 계속하세요"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        
        let guestButton = UIButton(type: .system)
        guestButton.setTitle("로그인 없이 체험하기", for: .normal)
        guestButton.setTitleColor(.white, for: .normal)
        guestButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        guestButton.translatesAutoresizingMaskIntoConstraints = false
        guestButton.backgroundColor = .clear
        guestButton.layer.borderWidth = 0.5
        guestButton.layer.borderColor = UIColor.white.cgColor
        guestButton.layer.cornerRadius = 8
        guestButton.widthAnchor.constraint(equalToConstant: 240).isActive = true
        guestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        guestButton.addTarget(self, action: #selector(handleContinueAsGuest), for: .touchUpInside)
        
        let loginStackView = UIStackView()
        loginStackView.axis = .vertical
        loginStackView.spacing = 16
        loginStackView.distribution = .fillEqually
        
        for provider in providers {
            let button = makeLoginButton(for: provider)
            loginStackView.addArrangedSubview(button)
        }
        loginStackView.addArrangedSubview(guestButton)
        
        let containerStackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel, loginStackView])
        containerStackView.axis = .vertical
        containerStackView.spacing = 32
        containerStackView.alignment = .center
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.tintColor = .white
        closeButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func makeLoginButton(for provider: AuthProvider) -> UIView {
        switch provider {
        case .apple:
            let button = ASAuthorizationAppleIDButton()
            button.cornerRadius = 8
            button.widthAnchor.constraint(equalToConstant: 240).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
            return button
        case .google:
            let googleButton = UIButton(type: .system)
            googleButton.setTitle("Google로 로그인", for: .normal)
            googleButton.backgroundColor = .white
            googleButton.setTitleColor(.black, for: .normal)
            googleButton.layer.cornerRadius = 8
            googleButton.widthAnchor.constraint(equalToConstant: 240).isActive = true
            googleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            googleButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
            return googleButton
        }
    }
    
    @objc private func handleAppleLogin() {
        DispatchQueue.main.async {
            AuthService.shared.signIn(with: .apple, from: self) { result in
                self.handleAuthResult(result)
            }
        }
    }
    
    @objc private func handleGoogleLogin() {
        AuthService.shared.signIn(with: .google, from: self) { result in
            self.handleAuthResult(result)
        }
    }
    
    private func handleAuthResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            handleLoginSuccess()
        case .failure(let error):
            print("로그인 실패: \(error.localizedDescription)")
        }
    }
    
    private func handleLoginSuccess() {
        delegate?.loginDidSucceed()
        dismiss(animated: true)
    }
    
    @objc private func handleContinueAsGuest() {
        dismiss(animated: true)
    }
    
    @objc private func handleClose() {
        dismiss(animated: true)
    }
}
