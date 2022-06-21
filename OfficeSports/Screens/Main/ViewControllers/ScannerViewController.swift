//
//  ScannerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    
    private lazy var frameLinesView: ScannerFrameLinesView = {
        return ScannerFrameLinesView()
    }()
    
    private lazy var cameraView: UIView = {
        return UIView.createView(.black)
    }()
    
    private lazy var shadowView: UIView = {
        return UIView.createView(.black)
    }()
    
    private lazy var activateCameraDescription: UILabel = {
        return UILabel.createLabel(.white, alignment: .left, text: "You need to activate the camera in order to register match scores.")
    }()
    
    private lazy var activateCameraButton: OSButton = {
        let button = OSButton("Enable camera", type: .primary)
        button.addTarget(self, action: #selector(activateCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoMessageView: UIView = {
        let label = UILabel.createLabel(.white)
        label.text = "If you're the winner of a match, scan the loser's QR code to register the match result."
        label.font = UIFont.boldSystemFont(ofSize: 16)
        let view = UIView.createView(UIColor.OS.Status.info)
        NSLayoutConstraint.pinToView(view, label, padding: 16)
        view.applyCornerRadius(6)
        view.alpha = 0.7
        return view
    }()
    
    private var cameraIsActive: Bool {
        captureSession != nil && captureSession.isRunning
    }
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var isShowingMatchRegistration: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineCameraStatus()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        view.addSubview(activateCameraDescription)
        view.addSubview(activateCameraButton)
        
        NSLayoutConstraint.pinToView(view, cameraView)
        NSLayoutConstraint.pinToView(view, shadowView)
        
        view.addSubview(frameLinesView)
        view.addSubview(infoMessageView)
        
        NSLayoutConstraint.activate([
            activateCameraDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            activateCameraDescription.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            activateCameraDescription.bottomAnchor.constraint(equalTo: activateCameraButton.topAnchor, constant: -16),
            activateCameraButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            activateCameraButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            activateCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activateCameraButton.heightAnchor.constraint(equalToConstant: 50),
            frameLinesView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            frameLinesView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            frameLinesView.heightAnchor.constraint(equalTo: frameLinesView.widthAnchor),
            frameLinesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameLinesView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            infoMessageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            infoMessageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            infoMessageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func determineCameraStatus() {
        let cameraIsActive = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        cameraView.isHidden = !cameraIsActive
        frameLinesView.isHidden = !cameraIsActive
        infoMessageView.isHidden = !cameraIsActive
    }
    
    private func stopCaptureSession() {
        if captureSession != nil && captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async { [weak self] in
                self?.determineCameraStatus()
                if granted {
                    self?.startCaptureSession()
                }
            }
        }
    }
    
    private func startCaptureSession() {
        // exit early if camera has not been enabled by the user or if it is already active
        let hasAuthorizedCamera = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        guard hasAuthorizedCamera && !cameraIsActive else {
            return
        }
        // initialize and configure capture session
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        captureSession.commitConfiguration()
        
        guard let videoInput = createVideoInput(), captureSession.canAddInput(videoInput) else {
            return
        }
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else {
            return
        }
        
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        metadataOutput.metadataObjectTypes = [.qr]
        
        // init the camera view in the UI
        previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.frame = self.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(self.previewLayer)
        
        // start the capture session
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.captureSession.startRunning()
        }
    }
    
    func handleTouch(point: CGPoint) {
        guard !cameraIsActive else { return }
        // since the button is covered by a scroll view, we need
        // to indirectly check if the user tapped within the frame
        // of the button and then send the touch action
        if activateCameraButton.frame.contains(point) {
            activateCameraButton.sendActions(for: .touchUpInside)
        }
    }
    
    func handleShadowViewOpacity(_ contentOffset: CGPoint) {
        let width = view.frame.width
        // set opacity of shadow view based on how much of the camera is showing
        shadowView.alpha = contentOffset.x / view.frame.width
        if contentOffset.x == width && cameraIsActive {
            stopCaptureSession()
        } else if contentOffset.x < width && !cameraIsActive {
            startCaptureSession()
        }
    }
    
    private func createVideoInput() -> AVCaptureDeviceInput? {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return nil
        }
        
        do {
            return try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    @objc private func activateCameraButtonTapped(_ sender: UIButton) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            startCaptureSession()
        case .denied, .notDetermined:
            requestCameraAccess()
        case .restricted:
            // user can't grant access due to restriction on the OS level
            print("Camera usage is restricted for this device")
        @unknown default:
            fatalError("Unknown camera status")
        }
    }
}

// MARK: - Metadata Output Objects Delegate

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !isShowingMatchRegistration, let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            var payload: OSCodePayload?
            do {
                let data = stringValue.data(using: .utf8)!
                payload = try JSONDecoder().decode(OSCodePayload.self, from: data)
            } catch let error {
                print(error)
                return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("Barcode found: \(stringValue)")
            
            guard let payload = payload else {
                return
            }
            isShowingMatchRegistration = true
            DispatchQueue.main.async {
                Coordinator.global.presentRegisterMatch(payload: payload, delegate: self)
            }
        }
    }
}

extension ScannerViewController: RegisterMatchDelegate {
    
    func dismissedMatchRegistration(match: OSMatch?) {
        isShowingMatchRegistration = false
        if match != nil {
            Coordinator.global.resetUIAfterMatchRegistration()
        }
    }
}
