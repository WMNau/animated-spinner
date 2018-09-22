//
//  SpinnerVC.swift
//  Animated Spinner
//
//  Created by Mike Nau on 9/21/18.
//  Copyright © 2018 Mike Nau. All rights reserved.
//

import UIKit

class SpinnerVC: UIViewController {
    var trackLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    var pulseLayer = CAShapeLayer()
    
    let percentageLbl: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next Condensed", size: 32.0)
        label.textColor = .white
        return label
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        view.backgroundColor = Color.backgroundColor
        
        setupNotificationObservers()
        setupLabel()
        setupLayers()
        setupSublayers()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        animatePulseLayer()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupLabel() {
        percentageLbl.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        percentageLbl.center = view.center
    }
    
    private func setupLayers() {
        trackLayer = createCircleLayer(strokeColor: Color.trackStrokeColor, fillColor: Color.backgroundColor, lineWidth: 20.0, transform: false)
        pulseLayer = createCircleLayer(strokeColor: UIColor.clear, fillColor: Color.pulseFillColor, lineWidth: 0.0, transform: false)
        progressLayer = createCircleLayer(strokeColor: Color.outlineStrokeColor, fillColor: UIColor.clear, lineWidth: 20.0, transform: true)
    }
    
    private func setupSublayers() {
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(pulseLayer)
        view.layer.addSublayer(progressLayer)
        view.addSubview(percentageLbl)
    }
    
    private func createCircleLayer(strokeColor: UIColor, fillColor: UIColor, lineWidth: CGFloat, transform: Bool) -> CAShapeLayer {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: view.frame.width / 5.0, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
        let layer = CAShapeLayer()
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = CAShapeLayerLineCap.round
        layer.strokeEnd = 0.0
        layer.position = view.center
        if transform {
            layer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2.0, 0.0, 0.0, 1.0)
        }
        return layer
    }
    
    let urlString = "https://firebasestorage.googleapis.com/v0/b/firestorechat-e64ac.appspot.com/o/intermediate_training_rec.mp4?alt=media&token=e20261d0-7219-49d2-b32d-367e1606500c"
    
    private func beginDownloadingFile() {
        progressLayer.strokeEnd = 0.0
        let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    private func animatePulseLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulseLayer.add(animation, forKey: "pulseAnim")
    }
    
    private func animate() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1.0
        animation.duration = 5.0
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "basicAnim")
    }
    
    @objc func handleTap() {
        beginDownloadingFile()
        animate()
    }
    
    @objc private func handleEnterForeground() {
        animatePulseLayer()
    }
}

extension SpinnerVC: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading file.")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.sync {
            progressLayer.strokeEnd = percentage
            percentageLbl.text = "\(Int(percentage * 100))%"
        }
    }
}
