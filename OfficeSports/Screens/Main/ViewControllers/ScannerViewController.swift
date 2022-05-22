//
//  ScannerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    
    private lazy var activateCameraDescription: UILabel = {
        return UILabel.createLabel(.white, alignment: .left, text: "You need to activate the camera in order to register match scores.")
    }()
    
    private lazy var activateCameraButton: UIButton = {
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: "Activate camera")
        button.addTarget(self, action: #selector(activateCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: ScannerViewModel
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(viewModel: ScannerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func setupChildViews() {
        view.addSubview(activateCameraDescription)
        view.addSubview(activateCameraButton)
        
        NSLayoutConstraint.activate([
            activateCameraDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            activateCameraDescription.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            activateCameraDescription.bottomAnchor.constraint(equalTo: activateCameraButton.topAnchor, constant: -16),
            activateCameraButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            activateCameraButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            activateCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activateCameraButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func stopCaptureSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func startCaptureSession() {
        // exit early if camera has not been enabled by the user
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
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
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            // failed()
            return
        }
        
        // init the camera view in the UI
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // start the capture session (blocking)
        captureSession.startRunning()
    }
    
    private func createVideoInput() -> AVCaptureDeviceInput? {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return nil
        }
        
        do {
            return try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    @objc private func activateCameraButtonTapped(_ sender: UIButton) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            startCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startCaptureSession()
                }
            }
        case .denied:
            // user has previously denied access
            return
        case .restricted:
            // user can't grant access due to restriction
            return
        @unknown default:
            fatalError("Unknown camera status")
        }
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // if a barcode is detected, stop the capture session
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("Barcode found: \(stringValue)")
        }
    }
}

// MARK: - Scanner View Model Delegate

extension ScannerViewController: ScannerViewModelDelegate {
    
    func matchRegistrationSuccess() {
        
    }
    
    func matchRegistrationFailed(error: Error) {
        
    }
    
    func shouldToggleLoading(enabled: Bool) {
    }
}
