//
//  ViewController.swift
//  OpenVC
//
//  Created by Jaeseong on 2017. 11. 14..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!

    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var output: AVCaptureVideoDataOutput!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSession.Preset.medium

        let devicesSession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video , position: AVCaptureDevice.Position.back)
        let devices = devicesSession.devices

        for device in devices {
            if ((device as AnyObject).position == AVCaptureDevice.Position.back) {
                self.device = device
            }
        }
        if self.device == nil {
            print("no device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: self.device)
            self.session.addInput(input)
        } catch {
            print("no device input")
            return
        }

        self.output = AVCaptureVideoDataOutput()
        self.output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA) ]

        let queue: DispatchQueue = DispatchQueue(label: "videocapturequere", attributes: [])
        self.output.setSampleBufferDelegate(self, queue: queue)
        self.output.alwaysDiscardsLateVideoFrames = true

        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
        } else {
            print("could not add a sesseion output")
            return
        }

        do {
            try self.device.lockForConfiguration()
            self.device.activeVideoMinFrameDuration = CMTimeMake(1, 20)
            self.device.unlockForConfiguration()
        } catch {
            print("could not configure a device")
            return
        }
        self.session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var shouldAutorotate: Bool {
        return false
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("could not get a pixel buffer")
            return
        }
        let capturedImage: UIImage
        do {
            CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
            defer {
                CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
            }
            let address = CVPixelBufferGetBaseAddressOfPlane(buffer, 0)
            let bytes = CVPixelBufferGetBytesPerRow(buffer)
            let width = CVPixelBufferGetWidth(buffer)
            let height = CVPixelBufferGetHeight(buffer)
            let color = CGColorSpaceCreateDeviceRGB()
            let bits = 8
            let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
            guard let context = CGContext(data: address, width: width, height: height, bitsPerComponent: bits, bytesPerRow: bytes, space: color, bitmapInfo: info) else {
                print("Could not create an context")
                return
            }
            guard let image = context.makeImage() else {
                print("could not create an cgimage")
                return
            }
            capturedImage = UIImage(cgImage: image, scale: 1.0, orientation: UIImageOrientation.right)
        }
        let resultImage = OpenCV.cvtColorBGR2GRAY(capturedImage)
        DispatchQueue.main.async {
            self.imageView.image = resultImage

        }
    }
}

