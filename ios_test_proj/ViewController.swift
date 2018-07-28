//
//  ViewController.swift
//  ios_test_proj
//
//  Created by Ning Wang on 7/3/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AWSCognito
import AWSS3
import AWSAuthCore
import AWSCore
import AWSAPIGateway
import AWSMobileClient
import Vision
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let bucketName = "ios-test-ning"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = UIImage(named:"sample1") else
        {return}
        let imageView = UIImageView(image:image)
        imageView.contentMode = .scaleAspectFit
        
        let scaledHeight = view.frame.width / image.size.width * image.size.height
        
        imageView.frame = CGRect(x:0, y:0, width:view.frame.width, height:scaledHeight)
        imageView.backgroundColor = .blue
        view.addSubview(imageView)
        
        let request = VNDetectFaceRectanglesRequest{(req, err)
            in
            if let err = err{
                print("Failed, err")
                return
            }
            print(req)
            
            req.results?.forEach({ (res) in
                
                DispatchQueue.main.async {
                    print(res)
                    
                    guard let faceObservation = res as? VNFaceObservation else {return}
                    
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    let height = scaledHeight * faceObservation.boundingBox.height
                    let y = scaledHeight * (1-faceObservation.boundingBox.origin.y)-height
                    let redView = UIView()
                    redView.backgroundColor = .red
                    redView.alpha = 0.4
                    
                    redView.frame = CGRect(x:x, y:y, width:width, height:height)
                    self.view.addSubview(redView)
                    
                    print(faceObservation.boundingBox)
                }
                
            })
        }
        guard let cgImage = image.cgImage else {return}
        
        DispatchQueue.global(qos: .background).async {
            let handler = VNImageRequestHandler(cgImage: cgImage,
                                                options: [:])
            do{
                try handler.perform([request])
            }catch let reqErr{
                print("Failed", reqErr)
            }
        }
        
        
        
        
        // Initialize the Amazon Cognito credentials provider
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:bbcb892d-7b21-472e-a580-f8563881b0b2")
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadFile(with resource: String, type:String){
        let key = "\(resource).\(type)"
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!
        let localImageUrl = URL(fileURLWithPath: localImagePath)
        
        // some S3 stuff here
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = bucketName
        request.key = key
        request.body = localImageUrl
        // permission
        request.acl = .publicReadWrite
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()){ (task) -> Any?
            in
            if let error = task.error{
                print(error)
            }
            if task.result != nil {
                print("Uploaded\(key)")
            }
            return nil
        }
        
    }
    @IBAction func onUploadTapped(){
        uploadFile(with: "banana", type: "jpeg")
    }
    @IBAction func onshowtapped(){
        doInvokeAPI()
    }
    func doInvokeAPI() {
        // change the method name, or path or the query string parameters here as desired
        let httpMethodName = "POST"
        // change to any valid path you configured in the API
        let URLString = "/items"
        let queryStringParameters = ["key1":"{value1}"]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let httpBody = "{ \n  " +
            "\"key1\":\"value1\", \n  " +
            "\"key2\":\"value2\", \n  " +
        "\"key3\":\"value3\"\n}"
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: httpBody)
        
        // Create a service configuration object for the region your AWS API was created in
        let serviceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_8E8NMVOA28_IoslambdaMobileHubClient.register(with: serviceConfiguration!, forKey: "CloudLogicAPIKey")
        
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient =
            AWSAPI_8E8NMVOA28_IoslambdaMobileHubClient(forKey: "CloudLogicAPIKey")
        
        invocationClient.invoke(apiRequest).continueWith { (
            task: AWSTask) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString =
                String(data: result.responseData!, encoding: .utf8)
            print("******")
            print(responseString)
            print("------")
            print(result.statusCode)

            
            return nil
        }
    }
    
}

