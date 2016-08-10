//
//  Assign2ViewController.swift
//  ShashankSR
//
//  Created by Shashank on 09/08/16.
//  Copyright © 2016 Shashank. All rights reserved.
//

import UIKit

class Assign2ViewController: UIViewController, NSURLSessionDelegate,NSURLSessionDownloadDelegate {

    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    // 2
    var dataTask: NSURLSessionDataTask?
    var isImage  = false
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var proglabel: UILabel!
    @IBOutlet weak var label: UILabel!
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0
        progressBar.hidden = true
        proglabel.hidden = true
        label.hidden = true
        imageView.hidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func handleSearchGo(sender: AnyObject) {
        
      
        if !searchBar.text!.isEmpty {
            
            if dataTask != nil {
                dataTask?.cancel()
            }
          
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
          
            let url = NSURL(string: searchBar.text!)
          
            dataTask = defaultSession.dataTaskWithURL(url!) {
                data, response, error in
                
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
               
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if(httpResponse.MIMEType!.lowercaseString.rangeOfString("image") != nil){
                            self.isImage = true
                        }
                        print(httpResponse)
                        self.startDownload((httpResponse.URL?.absoluteString)!)
                    }
                }
            }
            dataTask?.resume()
        }
        
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
   
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        // 1
         let originalURL = downloadTask.originalRequest?.URL?.lastPathComponent
        
            let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        
            let destinationURL = documentsPath.URLByAppendingPathComponent(originalURL!)
        
            // http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4
            //https://img.pokemondb.net/artwork/charizard.jpg
            //http://wallpapercave.com/wp/Qf9SNmS.png
            // 2
        
            let fileManager = NSFileManager.defaultManager()
            
            do {
                try fileManager.removeItemAtURL(destinationURL)
            } catch {
                // Non-fatal: file probably doesn't exist
            }
            do {
                try fileManager.copyItemAtURL(location, toURL: destinationURL)
               
                if(self.isImage){
                    print("Setting img")
                    let imgdata = NSData(contentsOfURL:(downloadTask.originalRequest?.URL)!)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.imageView.image = UIImage(data:imgdata!)
                    })
                    progressBar.hidden = true
                    proglabel.hidden = true
                    label.hidden = true
                    imageView.hidden = false
                }else{
                    let alertController = UIAlertController(title: "Complete", message: "Download Complete", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
                
              
                let thedate = NSDate()
                let datecomp = NSDateComponents()
                datecomp.second = 1
                
                let cal = NSCalendar.currentCalendar()
                let mfiredate = cal.dateByAddingComponents(datecomp, toDate: thedate , options: NSCalendarOptions())
                
                let notification:UILocalNotification = UILocalNotification()
                notification.alertBody = "Download completed"
                notification.fireDate = mfiredate
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                

            } catch let error as NSError {
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
    }
 
   
    func startDownload(str: String) {
            let urlString = str
            let url =  NSURL(string: urlString)
            let download = Download(url: urlString)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url!)
            download.downloadTask!.resume()
            download.isDownloading = true
    }


    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        if totalBytesExpectedToWrite < 0 {
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBar.hidden = true
                self.proglabel.hidden = false
                self.label.hidden = false
                self.proglabel.text = NSString(format: "%.2f", Float(totalBytesWritten)/1024) as String
            }
           
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBar.hidden = true
                self.proglabel.hidden = false
                self.label.hidden = false
                self.progressBar.progress = progress
            }
        }
        
    }

    class Download: NSObject {
        
        var url: String
        var isDownloading = false
        var progress: Float = 0.0
        var downloadTask: NSURLSessionDownloadTask?
        var resumeData: NSData?
        
        init(url: String) {
            self.url = url
        }
    }

}
