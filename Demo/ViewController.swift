//
//  ViewController.swift
//  Demo
//
//  Created by Werner Huber on 04.07.17.
//  Copyright © 2017 Werner Huber. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    @IBOutlet var predictionLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRequest()
        startCapturing()
    }
    
    var request: VNCoreMLRequest?
    
    func setupRequest() {
        guard let model = try? VNCoreMLModel(for: names().model) else {
            fatalError("can't load ML model")
        }
        request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    return
            }
            DispatchQueue.main.async {
                self?.predictionLabel?.text = "\(topResult.identifier): \(topResult.confidence)"
            }
        }
    }
    
    func analyze(image: UIImage) {
        guard let request = request else { return }
        guard let ciImage = CIImage(image: image) else { return }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try? handler.perform([request])
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func startCapturing() {
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "imageProcessing"))
        session.addOutput(output)
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = view.frame
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        session.startRunning()
        
        guard let predictionLabel = predictionLabel else {
            return
        }
        view.bringSubview(toFront: predictionLabel)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = .portrait
        
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else  { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let image = UIImage(ciImageBuffer: ciImage).cropToBounds(width: 224, height: 224)
        analyze(image: image)
    }
    
    
}

