
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as! UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            let userInfo = bestAttemptContent.userInfo
            
            if let userString = userInfo["attachment-url"], let fileUrl = URL(string: userString as! String){
                
                URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
                    if let location = location {
                        
                        let tmpDirectory = NSTemporaryDirectory()
                        let tmpFile = "file:".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                        let tmpUrl = URL(string: tmpFile)!
                        try! FileManager.default.moveItem(at: location, to: tmpUrl)
                        
                        if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl) {
                            self.bestAttemptContent?.attachments = [attachment]
                        }
                    }
                    
                    self.contentHandler!(self.bestAttemptContent!)
                    }.resume()
            }
        }
        
        // Sample Payload
        
//        {
//            "aps": {
//                "mutable-content":1,
//                "category": "test",
//                "alert":{
//                    "title": "Notification title",
//                    "subtitle": "Notification subtitle",
//                    "body": "Notification body"
//                }
//            },
//            "attachment-url": "https://www.gstatic.com/webp/gallery3/1.png"}
        
        //
        
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        if let bestAttemptContent = bestAttemptContent {
//            // Modify the notification content here...
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//
//            contentHandler(bestAttemptContent)
//        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
