//
//  ViewController.swift
//  QReader
//
//  Created by umar on 4/9/18.
//  Copyright © 2018 Umar Farooq. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var messageLabel: UILabel!
    
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var qrCodeFramView : UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and
            //set it as the output device to the capture session.
            let output = AVCaptureMetadataOutput()
            captureSession?.addOutput(output)
            
            // Set delegate and use the default dispatch queue to execute the call back
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //add all suported codes
            output.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            //Start video capture
            captureSession?.startRunning()
            
            // Move the message label to the top view
            view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFramView = UIView()
            
            if let qrCodeFramView = qrCodeFramView {
                qrCodeFramView.layer.borderColor = UIColor.green.cgColor
                qrCodeFramView.layer.borderWidth = 2
                view.addSubview(qrCodeFramView)
                view.bringSubview(toFront: qrCodeFramView)
            }
        }
        catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFramView?.frame = CGRect.zero
            messageLabel.text = "No barcode/QR code is detected"
            return
        }
        
        //Get object
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // If the found metadata is equal to the QR code metadata (or barcode) then update the status label
        if supportedCodeTypes.contains(metadataObject.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            qrCodeFramView?.frame = barCodeObject!.bounds
            if metadataObject.stringValue != nil {
                messageLabel.text = metadataObject.stringValue
            }
        }
    }
}

