//
//  AboutViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import UIKit
import SafariServices

final class AboutViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, text: "About")
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.white, tintColor: UIColor.OS.General.main, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.applyCornerRadius(20)
        button.alpha = 0.7
        return button
    }()
    
    private lazy var oyvindView: DeveloperView = {
        return DeveloperView(image: UIImage(named: "oyvind-profile-picure.png"), role: "Design • iOS")
    }()
    
    private lazy var sindreView: DeveloperView = {
        return DeveloperView(image: UIImage(named: "sindre-profile-picture-2.png"), role: "Backend")
    }()
    
    private lazy var konstantinosView: DeveloperView = {
        return DeveloperView(image: UIImage(named: "konstantinos-profile-picture.png"), role: "Android")
    }()
    
    private lazy var versionLabel: UILabel = {
        let text = "Version \(Bundle.main.appVersionNumber ?? "") (\(Bundle.main.appBuildNumber ?? "")) ⚡️"
        let label = UILabel.createLabel(.white, alignment: .center, text: text)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha = 0.7
        return label
    }()
    
    private var animator: UIDynamicAnimator!
    private var gravity: UIGravityBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGravity()
        animator.addBehavior(gravity)
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(oyvindView)
        view.addSubview(sindreView)
        view.addSubview(konstantinosView)
        view.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            versionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            versionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupGravity() {
        let gravityViews = [oyvindView, sindreView, konstantinosView]
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: gravityViews)
        
        let collision = UICollisionBehavior(items: gravityViews)
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 100)
        collision.addBoundary(withIdentifier: "barrier" as NSCopying, for: UIBezierPath(rect: rect))
        
        animator.addBehavior(collision)
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

private final class DeveloperView: UIView {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView.createImageView(nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 7
        return imageView
    }()
    
    private lazy var rolelabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private var urlString: String?
    
    init(image: UIImage?, role: String, url: String? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 170))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        applyCornerRadius(8)
        applySmallDropShadow(.black)
        setupChildViews()
        if let image = image {
            profileImageView.image = image
        } else {
        }
        urlString = url
        rolelabel.text = role
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(profileImageView)
        addSubview(rolelabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            profileImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileImageView.bottomAnchor.constraint(equalTo: rolelabel.topAnchor, constant: -8),
            profileImageView.widthAnchor.constraint(equalToConstant: 130),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            rolelabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            rolelabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            rolelabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    @objc private func openGitHub(from parent: UIViewController) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        let viewController = SFSafariViewController(url: url)
        parent.present(viewController, animated: true)
    }
}
