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
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0
        progressBar.hidden = true
        imageView.hidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func handleSearchGo(sender: AnyObject) {
        
        progressBar.hidden = false
        if !searchBar.text!.isEmpty {
            // 1
            if dataTask != nil {
                dataTask?.cancel()
            }
            // 2
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            // 4
            let url = NSURL(string: searchBar.text!)
            // 5
            dataTask = defaultSession.dataTaskWithURL(url!) {
                data, response, error in
                // 6
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                // 7
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if(httpResponse.MIMEType! == "image/jpeg"){
                            self.isImage = true
                        }
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
    
   /* func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
            print("Finished downloading.")
    }
    */
   
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        // 1
         let originalURL = downloadTask.originalRequest?.URL?.lastPathComponent
        
            let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        
            let destinationURL = documentsPath.URLByAppendingPathComponent(originalURL!)
           // print(destinationURL)
        
            //https://img.pokemondb.net/artwork/charizard.jpg
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
                    imageView.hidden = false
                }else{
                    let alertController = UIAlertController(title: "Complete", message: "Download Complete", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                }
                
              
                
               //
               // let vc = UIActivityViewController(activityItems: fileManager, applicationActivities: )
               // self.presentViewController(vc, animated: true, completion:nil )
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
            // 1
            let download = Download(url: urlString)
            // 2
            download.downloadTask = downloadsSession.downloadTaskWithURL(url!)
            // 3
            download.downloadTask!.resume()
            // 4
            download.isDownloading = true
            // 5
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 1


    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 1
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressBar.progress = progress
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
