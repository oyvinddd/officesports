//
//  ScannerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    /*
    private lazy var viewModel: ScannerViewModel = {
        return ScannerViewModel(delegate: self)
    }()
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //UITextField.createView(backgroundColor: .red)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAndStartCaptureSession()
    }
    
    private func setupAndStartCaptureSession() {
        //DispatchQueue.global(qos: .userInitiated).async {
            
            // init capture session
            self.captureSession = AVCaptureSession()
            
            // configuration
            self.captureSession.beginConfiguration()
            self.captureSession.commitConfiguration()
            
            let videoInput = self.createVideoInput()
            
            if self.captureSession.canAddInput(videoInput!) {
                self.captureSession.addInput(videoInput!)
            } else {
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()

            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .aztec]
            } else {
                //failed()
                return
            }
            
            // init the camera view in the UI
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            
            // start the capture session (blocking)
            self.captureSession.startRunning()
        //}
    }
    
    private func createVideoInput() -> AVCaptureDeviceInput? {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return nil
        }
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return nil
        }
        return videoInput
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
/*
extension ScannerViewController: ScannerViewModelDelegate {
    
    func validationSucceeded(ticket: TPTicket) {
        
    }
    
    func validationFailed(error: Error) {
        
    }
}
*/
