//
//  LoginViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/2/25.
//

import AuthenticationServices
import Supabase

protocol LoginViewControllerDelegate: AnyObject {
    func loginDidSucceed()
}

class LoginViewController: UIViewController {
    private let providers: [AuthProvider] = [.apple/*, .google*/]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tintColor
        setupUI()
    }
    
    weak var delegate: LoginViewControllerDelegate?
    
    private func handleLoginSuccess() {
        delegate?.loginDidSucceed()
    }
    
    private func setupUI() {
        let logoImageView = UIImageView(image: UIImage(named: "moon"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Career Log"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "로그인하여 계속하세요"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .white
        
        // 로그인 버튼
        let loginStackView = UIStackView()
        loginStackView.axis = .vertical
        loginStackView.spacing = 32
        loginStackView.distribution = .fillEqually
        
        for provider in providers {
            let button = makeLoginButton(for: provider)
            loginStackView.addArrangedSubview(button)
        }
        
        let containerStackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel, loginStackView])
        containerStackView.axis = .vertical
        containerStackView.spacing = 20
        containerStackView.alignment = .center
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func makeLoginButton(for provider: AuthProvider) -> UIView {
        switch provider {
        case .apple:
            let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
            appleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
            appleButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            appleButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
            return appleButton
        case .google:
            let googleButton = UIButton(type: .system)
            googleButton.setTitle("Google로 로그인", for: .normal)
            googleButton.backgroundColor = .white
            googleButton.setTitleColor(.black, for: .normal)
            googleButton.layer.cornerRadius = 8
            googleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
            googleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            googleButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
            return googleButton
        }
    }
    
    @objc private func handleAppleLogin() {
        AuthService.shared.signIn(with: .apple) { [weak self] result in
            self?.handleAuthResult(result)
        }
    }
    
    @objc private func handleGoogleLogin() {
        AuthService.shared.signIn(with: .google) { [weak self] result in
            self?.handleAuthResult(result)
        }
    }
    
    private func handleAuthResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            self.handleLoginSuccess()
        case .failure(let error):
            print("로그인 실패: \(error.localizedDescription)")
        }
    }
}
