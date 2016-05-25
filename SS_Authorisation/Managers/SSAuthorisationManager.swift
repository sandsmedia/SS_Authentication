//
//  SSAuthorisationManager.swift
//  SS_Authorisation
//
//  Created by Eddie Li on 23/03/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

let TIME_OUT_INTERVAL = 120.0
let TIME_OUT_RESOURCE = 600.0

let WEB_SERVICE_RETRY = 1

public class SSAuthorisationManager {
    public typealias ServiceResponse = (AnyObject?, NSError?) -> Void;
    
    private var accessToken: String? = nil;
    
    // MARK: - Singleton Methods
    
    public static let sharedInstance: SSAuthorisationManager = {
        let instance = SSAuthorisationManager();
        return instance;
    }();
    
    // MARK: - Accessors
    
    private lazy var networkManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration();
        configuration.HTTPShouldSetCookies = false;
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData;
        configuration.timeoutIntervalForRequest = TIME_OUT_INTERVAL;
        configuration.timeoutIntervalForResource = TIME_OUT_RESOURCE;
        let manager = Alamofire.Manager(configuration: configuration);
        return manager;
    }();
    
    private lazy var baseURL: String = {
        let _baseUrl = "http://video-cms-development.signsoft.com/";
        return _baseUrl;
    }();
    
    private lazy var registerURL: String = {
        let _registerURL = self.baseURL + "user";
        return _registerURL;
    }();
    
    private lazy var loginURL: String = {
        let _loginURL = self.baseURL + "user/login";
        return _loginURL;
    }();
    
    private lazy var validateURL: String = {
        let _validateURL = self.baseURL + "token/validate";
        return _validateURL;
    }();
    
    private lazy var resetURL: String = {
        let _resetURL = self.baseURL + "";
        return _resetURL;
    }();
    
    private lazy var updateURL: String = {
        let _updateURL = self.baseURL + "";
        return _updateURL;
    }();
    
    // MARK: - Public Methods
    
    public func register(userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.registerURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("register: ", value);
                    completionHandler(value, nil);
                case .Failure(let error):
                    print("register error: ", error);
                    completionHandler(nil, error);
                }
        }
        
    }
    
    public func login(userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.loginURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("login: ", value);
                    completionHandler(value, nil);
                case .Failure(let error):
                    print("login error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
    
    public func validate(completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.validateURL, parameters: nil, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("validate: ", value);
                    completionHandler(value, nil);
                case .Failure(let error):
                    print("validate error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
    
    public func logout(completionHandler: ServiceResponse) -> Void {
        self.accessToken = nil;
    }
    
    public func reset(userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.resetURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("reset: ", value);
                    completionHandler(value, nil);
                case .Failure(let error):
                    print("reset error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
    
    public func update(userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.updateURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("update: ", value);
                    completionHandler(value, nil);
                case .Failure(let error):
                    print("update error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
}