//
//  ViewController.swift
//  CubicSwiftIOS
//
//  Created by coldfin_lb on 4/14/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import cubic_swift

class ViewController: UIViewController {
    var audioRecoder:AudioRecorder = AudioRecorder()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func onClick_btnRecorder(_ sender: Any) {
        audioRecoder.startRecording("0123", block: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

