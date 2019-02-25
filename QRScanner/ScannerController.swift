//
//  ViewController.swift
//  QRScanner
//
//  Created by Dinesh Garg on 2/24/19.
//  Copyright © 2019 Dinesh Garg. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureDevice: AVCaptureDevice?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let systemSoundId: SystemSoundID = 1016

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Scanner"
        view.backgroundColor = .white

        captureQR()
        updateView()
    }

    let codeFrame:UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()

    let codeLabel:UILabel = {
        let codeLabel = UILabel()
        codeLabel.font = UIFont.systemFont(ofSize: 16)
        codeLabel.textColor = .white
        codeLabel.contentMode = .center
        return codeLabel
    }()

    func updateView() {
        view.addSubview(codeLabel)
        codeLabel.frame = CGRect(x: 50.0, y: 60.0, width: view.frame.width - 100.0, height: 20.0)
    }

    func captureQR() {
        captureDevice = AVCaptureDevice.default(for: .video)
        if let captureDevice = captureDevice {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)

                let captureSession = AVCaptureSession()
                captureSession.addInput(input)

                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)

                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                captureMetadataOutput.metadataObjectTypes = [.code128, .qr, .ean13,  .ean8, .code39]

                captureSession.startRunning()

                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer!)

            } catch {
                print("Error Device Input")
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            //print("No Input Detected")
            codeFrame.frame = CGRect.zero
            codeLabel.text = "No Data"
            return
        }

        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        guard let stringCodeValue = metadataObject.stringValue else { return }

        view.addSubview(codeFrame)

        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        codeFrame.frame = barcodeObject.bounds
        codeLabel.text = stringCodeValue

        if let customSoundUrl = Bundle.main.url(forResource: "beep-07", withExtension: "mp3") {
            var customSoundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(customSoundUrl as CFURL, &customSoundId)

            AudioServicesAddSystemSoundCompletion(customSoundId, nil, nil, { (customSoundId, _) -> Void in
                AudioServicesDisposeSystemSoundID(customSoundId)
            }, nil)

            AudioServicesPlaySystemSound(customSoundId)
        }
    }
}

