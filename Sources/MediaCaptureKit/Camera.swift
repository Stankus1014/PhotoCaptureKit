//
//  Camera.swift
//  MediaCaptureKit
//
//  Created by William Stankus on 9/26/25.
//
import Foundation
import AVFoundation
import UIKit

public class Camera : NSObject {
    
    private var captureSession: AVCaptureSession
    private var stillImageOutput: AVCapturePhotoOutput
    private var settings: AVCapturePhotoSettings

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    public weak var delegate: CameraFunctionsProtocol?
    
    public init(
        settings: AVCapturePhotoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg]),
        sessionPreset: AVCaptureSession.Preset = .hd1280x720,
        delegate: CameraFunctionsProtocol? = nil
    ) {
        self.settings = settings
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = sessionPreset
        self.stillImageOutput = AVCapturePhotoOutput()
        self.delegate = delegate
    }
    
    public func startCamera() throws {
        
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        
        let input = try AVCaptureDeviceInput(device: camera)
        
        if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
            captureSession.addInput(input)
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    public func stopCamera() {
        self.captureSession.stopRunning()
        self.videoPreviewLayer?.session?.stopRunning()
        self.videoPreviewLayer = nil
    }
    
    public func setCapturePhotoSettings(settings: AVCapturePhotoSettings) {
        self.settings = settings
    }
    
    @MainActor
    public func setupLivePreview(
        on view: UIView,
        gravity: AVLayerVideoGravity = .resizeAspectFill,
        orientation: AVCaptureVideoOrientation = .portrait
    ) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = gravity
        videoPreviewLayer?.connection?.videoOrientation = orientation
        videoPreviewLayer?.frame = view.bounds
        
        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
            
            let session = self.captureSession
            
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
        }
        
    }
    
    public func takePicture() {
        stillImageOutput.capturePhoto(with: self.settings, delegate: self)
    }
    
}

extension Camera: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let imageData = photo.fileDataRepresentation() else { print("No photo"); return }
        self.delegate?.didCapturePhoto(data: imageData)
    }
}

public protocol CameraFunctionsProtocol : AnyObject {
    func didCapturePhoto(data: Data)
}
