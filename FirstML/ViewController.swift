//
//  ViewController.swift
//  FirstML
//
//  Created by Prem Nalluri on 07/03/20.
//  Copyright © 2020 AgathsyaTechnologies. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var classificationLable: UILabel!
    var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            //let model = try VNCoreMLModel(for: MobileNet().model)
            let model = try VNCoreMLModel(for: CATGIFBEAR3().model)
            let request = VNCoreMLRequest(model: model, completionHandler: {  request, error in
                //self?.processClassifications(for: request, error: error)
            })
            print(request.results)
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classificationLable.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        // Do any additional setup after loading the view.
        let captureSession = AVCaptureSession()
        guard let caputreDevice = AVCaptureDevice.default(for: .video) else{return}
        guard let input = try? AVCaptureDeviceInput(device: caputreDevice) else{return}
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        
        
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for:CATGIFBEAR1().model) else {return}
        let request = VNCoreMLRequest(model: model) {  request, error in
            //self?.processClassifications(for: request, error: error)
            print(request.results)
            guard let results = request.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
        //print(firstObservation.identifier,firstObservation.confidence)
            //print(firstObservation.value(forKey: ))
            if firstObservation.confidence > 0.75{
                print(firstObservation.identifier,firstObservation.confidence,"identifier and confidence")
                DispatchQueue.main.async {
                    self.classificationLable.text = "\(firstObservation.identifier),\(firstObservation.confidence)"
                }
             
            }else{
                print("conf less than 0.75")
            }
            
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    //    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
    //        let curDeviceOrientation = UIDevice.current.orientation
    //        let exifOrientation: CGImagePropertyOrientation
    //
    //        switch curDeviceOrientation {
    //        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
    //            exifOrientation = .upMirrored
    //        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
    //            exifOrientation = .left
    //        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
    //            exifOrientation = .right
    //        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
    //            exifOrientation = .up
    //        default:
    //            exifOrientation = .up
    //        }
    //        return exifOrientation
    //    }
    //}
    //extension CGImagePropertyOrientation {
    //    /**
    //     Converts a `UIImageOrientation` to a corresponding
    //     `CGImagePropertyOrientation`. The cases for each
    //     orientation are represented by different raw values.
    //
    //     - Tag: ConvertOrientation
    //     */
    //    init(_ orientation: UIImage.Orientation) {
    //        switch orientation {
    //        case .up: self = .up
    //        case .upMirrored: self = .upMirrored
    //        case .down: self = .down
    //        case .downMirrored: self = .downMirrored
    //        case .left: self = .left
    //        case .leftMirrored: self = .leftMirrored
    //        case .right: self = .right
    //        case .rightMirrored: self = .rightMirrored
    //        }
    //    }
    //}
    
    //private var requests = [VNRequest]()
    //let exifOrientation = exifOrientationFromDeviceOrientation()
    //let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
    //do {
    //  try imageRequestHandler.perform(self.requests)
    //} catch {
    //  print(error)
    //}
    
    
}
