//
//  ScanPage.swift
//  TravelBros
//
//  Created by Edvard Hedlund on 2019-02-13.
//  Copyright © 2019 Edvard Hedlund. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class ScanPage: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var metaLabel: UILabel!
    
    var avSession = AVCaptureSession()
    var previousPixelBuffer:CVImageBuffer?
    var moved = false
    let newMotion = Motion()
    
    let mlModel = Fruit()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSession()
    }
    
    
    func setUpSession() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        //                let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        
        guard let captureDevice = discoverySession.devices.first else {
            print("Hittar inte kameran")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            avSession.addInput(input)
            
            avSession.sessionPreset = AVCaptureSession.Preset.high
            //            avSession.sessionPreset = AVCaptureSession.Preset.vga640x480
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            let videoQueue = DispatchQueue(label: "meta", attributes: .concurrent)
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            avSession.addOutput(videoOutput)
            
        } catch {
            print(error)
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: avSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.frame = cameraView.frame
        cameraView.layer.addSublayer(previewLayer)
        
        avSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
            func imageTranslation(request: VNRequest, error: Error?) {
                guard let result = request.results?.first as? VNImageTranslationAlignmentObservation else { return }
                let move = result.alignmentTransform
                let dist = sqrt(move.tx*move.tx + move.ty*move.ty)
                //                    print(dist)
                if dist < 10 {
                    if moved { detectCoreML(pixelBuffer: pixelBuffer) }
                    moved = false
                } else {
                    moved = true
                }
            }
            
            if let previousPixelBuffer = previousPixelBuffer {
                let transRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: previousPixelBuffer, completionHandler: imageTranslation)
                let vnImage = VNSequenceRequestHandler()
                try? vnImage.perform([transRequest], on: pixelBuffer)
            }
            
            previousPixelBuffer = pixelBuffer
            
            //        var previousPixelBuffer:CVImageBuffer?
            //         var moved = false
            
            //            detectCoreML(pixelBuffer: pixelBuffer)
            
            //            detectMotion(pixelBuffer: pixelBuffer)
            //            detectQR(pixelBuffer: pixelBuffer)
            //            detectFace(pixelBuffer: pixelBuffer)
        }
    }
    
    
    func detectCoreML(pixelBuffer:CVImageBuffer) {
        func completion(request: VNRequest, error: Error?) {
            guard let observe = request.results as? [VNClassificationObservation] else { return }
            
            for classification in observe {
                if classification.confidence > 0.01 { print(classification.identifier, classification.confidence) }
            }
            
            if let topResult = observe.first {
                DispatchQueue.main.async {
                    self.metaLabel.text = topResult.identifier + String(format: ", %.2f", topResult.confidence)
                }
            }
        }
        
        do {
            let model = try VNCoreMLModel(for: mlModel.model)
            let request = VNCoreMLRequest(model: model, completionHandler: completion)
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func detectMotion(pixelBuffer:CVImageBuffer) {
        let bc = newMotion.detect(pixelBuffer)
        //        print(bc)
        
        DispatchQueue.main.async {
            if bc < 0.8 { self.scanView.backgroundColor = UIColor.red }
            else { self.scanView.backgroundColor = UIColor.blue}
        }
    }
    
    
    func detectQR(pixelBuffer:CVImageBuffer) {
        func compHandler(request: VNRequest, error: Error?) {
            if let observe = request.results?.first as? VNBarcodeObservation {
                //                    print(observe.payloadStringValue)
                DispatchQueue.main.async {
                    self.metaLabel.text = observe.payloadStringValue
                }
            }
        }
        
        let detectReq = VNDetectBarcodesRequest(completionHandler: compHandler)
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        detectReq.symbologies = [VNBarcodeSymbology.QR, VNBarcodeSymbology.Code39, VNBarcodeSymbology.EAN13]
        //            detectReq.symbologies = [VNBarcodeSymbology.EAN13]
        try? requestHandler.perform([detectReq])
    }
    
    
    func detectFace(pixelBuffer:CVImageBuffer) {
        func compHandler(request: VNRequest, error: Error?) {
            if let observe = request.results?.first as? VNFaceObservation {
                //                        print(observe.boundingBox)
                
                DispatchQueue.main.async {
                    let vnRect = observe.boundingBox
                    let cW = self.cameraView.frame.size.width
                    let cH = self.cameraView.frame.size.height
                    let svX = cW*vnRect.origin.x
                    let svY = cH*(1-vnRect.origin.y-vnRect.size.height)
                    let svW = cW*vnRect.size.width
                    let svH = cH*vnRect.size.height
                    self.scanView.frame = CGRect(x: svX, y: svY, width: svW, height: svH)
                }
            }
        }
        
        let detectReq = VNDetectFaceRectanglesRequest(completionHandler: compHandler)
        //            let detectReq = VNDetectFaceLandmarksRequest(completionHandler: compHandler)
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        try? requestHandler.perform([detectReq])
    }
    
    //    func imageTranslation(request: VNRequest, error: Error?) {
    //        guard let result = request.results?.first as? VNImageTranslationAlignmentObservation else { return }
    //        //                for result in results {
    //        let move = result.alignmentTransform
    //        let dist = sqrt(move.tx*move.tx + move.ty*move.ty)
    //        //                    print(dist)
    //        if dist < 10 {
    //            if moved { detectCoreML(pixelBuffer: pixelBuffer) }
    //            moved = false
    //        } else {
    //            moved = true
    //        }
    //        //                }
    //    }
    //
    //    if let previousPixelBuffer = previousPixelBuffer {
    //        let transRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: previousPixelBuffer, completionHandler: imageTranslation)
    //        let vnImage = VNSequenceRequestHandler()
    //        try? vnImage.perform([transRequest], on: pixelBuffer)
    //    }
    //
    //    previousPixelBuffer = pixelBuffer
    
    
    @IBAction func openCode() {
        if let link = metaLabel.text, let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
