//
//  Apiclient.swift
//  ios_test_proj
//
//  Created by Ning Wang on 7/11/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import UIKit
import AWSAuthCore
import AWSCore
import AWSAPIGateway
import AWSMobileClient

// ViewController or application context . . .

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
    
    YOUR-API-CLASS-NAMEMobileHubClient.register(with: serviceConfiguration!, forKey: "CloudLogicAPIKey")
    
    // Fetch the Cloud Logic client to be used for invocation
    let invocationClient =
        YOUR-API-CLASS-NAMEMobileHubClient(forKey: "CloudLogicAPIKey")
    
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
        
        print(responseString)
        print(result.statusCode)
        
        return nil
    }
}
