//
//  Assign1ViewController.swift
//  ShashankSR
//
//  Created by Shashank on 09/08/16.
//  Copyright © 2016 Shashank. All rights reserved.
//

import UIKit
import PhoneNumberKit

class Assign1ViewController: UIViewController {

    @IBOutlet weak var PhonenumField: UITextField!
    @IBOutlet weak var ValidityLabel: UILabel!
    
    @IBAction func handleButtonClick(sender: UIButton) {
        do {
            let phoneNumber = try PhoneNumber(rawNumber:PhonenumField.text!)
            if(phoneNumber.isValidNumber){
                self.ValidityLabel.text = "Valid"
                print("Valid")
            }else{
                 self.ValidityLabel.text = "Invalid"
                print("Invalid")
            }
        }
        catch {
            self.ValidityLabel.text = ""
            let alertController = UIAlertController(title: "Error", message: "Numberparse error", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
            print("Generic parser error")
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Assign1ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Assign1ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func keyboardWillShow(notification: NSNotification) {
    
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/4
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height/4
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
