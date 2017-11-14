//
//  AvCapture.swift
//  OpenVC-SavePhoto
//
//  Created by Jaeseong on 2017. 11. 14..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import Foundation
import AVFoundation
//import UIKit

protocol AVCaptureDelegate {
    func capture(image: UIImage)
}

class AVCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var delegate: AVCaptureDelegate?
    
    var count = 0
    
    override init() {
        super.init()
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        videoDataOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA) ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        captureSession.addOutput(videoDataOutput)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if (count % 5) == 0 {
            let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            delegate?.capture(image: image)
        }
        count += 1
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        // 이미지버퍼 잠금
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        // 이미지정보
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        // 비트맵 컨텍스트 작성
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        // 이미지만들기
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.right)
        
        // 이미지 버퍼 잠금 해제
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return image
    }
}
