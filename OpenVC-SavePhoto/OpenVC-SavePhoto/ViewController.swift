//
//  ViewController.swift
//  OpenVC-SavePhoto
//
//  Created by Jaeseong on 2017. 11. 14..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AVCaptureDelegate {

    
    @IBOutlet weak var imaeView: UIImageView!
    @IBOutlet weak var opVew: UIView!
    @IBOutlet weak var blur0: UISlider!
    @IBOutlet weak var blur1: UISlider!
    @IBOutlet weak var threshold0: UISlider!
    @IBOutlet weak var threshold1: UISlider!
    
    let avCapture = AVCapture()
    let openCv = OpenCv()
    var isChecking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avCapture.delegate = self
        opVew.layer.cornerRadius = 20
        opVew.isHidden = true
    }
    // delegate
    func capture(image: UIImage) {
        if !isChecking {
            imaeView.image = openCv.filter(image)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func tapShuterButton(_ sender: Any) {
        
        isChecking = true
        let alert: UIAlertController = UIAlertController(title: nil, message: "저장?", preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //let resize = self.resizeImage(image: self.imageView.image!, width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.height) * 2)
            UIImageWriteToSavedPhotosAlbum(self.imaeView.image!, self, nil, nil)
            self.isChecking = false
        })
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            self.isChecking = false
        }))
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Mark - OperationView
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if (touches.first?.view?.tag)! == 1 {
            if opVew.isHidden {
                opVew.isHidden = false
            }
        }
    }
    
    @IBAction func tapOpClseButton(_ sender: Any) {
        opVew.isHidden = true
    }
    
    // Blur
    @IBAction func changeBlrSwitch(_ sender: UISwitch) {
        openCv.useBlur = sender.isOn
        blur0.isEnabled = sender.isOn
        blur1.isEnabled = sender.isOn
    }
    
    @IBAction func changeBur0Slider(_ sender: UISlider) {
        openCv.blur0 = Int32(sender.value)
    }
    
    @IBAction func changelur1Slider(_ sender: UISlider) {
        openCv.blur1 = Int32(sender.value)
    }
    
    // Treshold
    @IBAction func changeTreholdSwitch(_ sender: UISwitch) {
        openCv.useTreshold = sender.isOn
    }
    
    // AdaptiveTreshold
    @IBAction func changeAdptiveTresholdSwitch(_ sender: UISwitch) {
        openCv.useAdaptiveTreshold = sender.isOn
        threshold0.isEnabled = sender.isOn
        threshold1.isEnabled = sender.isOn
    }
    
    @IBAction func changeAdapiveTreshold0Slider(_ sender: UISlider) {
        openCv.adaptiveThreshold0 = Int32(sender.value)
    }
    
    @IBAction func changeAdaptveTreshold1Slider(_ sender: UISlider) {
        openCv.adaptiveThreshold1 = Int32(sender.value)
    }
    
    

}

