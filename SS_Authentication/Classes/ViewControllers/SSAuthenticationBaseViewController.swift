//
//  SSAuthenticationBaseViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

import Validator

public class SSAuthenticationBaseViewController: UIViewController, SSAuthenticationNavigationBarDelegate, UITextFieldDelegate {
    var navigationBar: SSAuthenticationNavigationBar?;
    private var loadingView: SSAuthenticationLoadingView?;
    
    var hideStatusBar: Bool = false;
    var isEmailValid: Bool = false;
    var isPasswordValid: Bool = false;
    var isRetypePasswordValid: Bool = false;
    
    private var hasLoadedConstraints: Bool = false;

    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil);
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.setup();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setup();
    }
    
    deinit {
        self.emailTextField.validateOnEditingEnd(false);
        self.passwordTextField.validateOnEditingEnd(false);
        self.retypePasswordTextField.validateOnEditingEnd(false);
        self.emailTextField.delegate = nil;
        self.passwordTextField.delegate = nil;
        self.retypePasswordTextField.delegate = nil;
    }
    
    // MARK: - Accessors
    
    private(set) lazy var resourceBundle: NSBundle = {
        let bundleURL = NSBundle(forClass: SSAuthenticationBaseViewController.self).resourceURL;
        let _resourceBundle = NSBundle(URL: bundleURL!);
        return _resourceBundle!;
    }();
    
    private(set) lazy var emailTextField: UITextField = {
        let _emailTextField = UITextField();
        _emailTextField.delegate = self;
        _emailTextField.keyboardType = .EmailAddress;
        _emailTextField.spellCheckingType = .No;
        _emailTextField.autocorrectionType = .No;
        _emailTextField.autocapitalizationType = .None;
        _emailTextField.attributedPlaceholder = NSAttributedString.init(string: self.localizedString(key: "user.email"), attributes: nil);
        _emailTextField.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        _emailTextField.leftViewMode = .Always;
        _emailTextField.layer.borderColor = UIColor.grayColor().CGColor;
        _emailTextField.layer.borderWidth = 1.0;
        var rules = ValidationRuleSet<String>();
        let emailRule = ValidationRulePattern(pattern: .EmailAddress, failureError: ValidationError(message: self.localizedString(key: "emailFormatError.message")));
        rules.addRule(emailRule);
        _emailTextField.validationRules = rules;
        _emailTextField.validationHandler = { result, control in
            self.isEmailValid = result.isValid;
        }
        _emailTextField.validateOnEditingEnd(true);
        return _emailTextField;
    }();
    
    private(set) lazy var passwordTextField: UITextField = {
        let _passwordTextField = UITextField();
        _passwordTextField.delegate = self;
        _passwordTextField.spellCheckingType = .No;
        _passwordTextField.autocorrectionType = .No;
        _passwordTextField.autocapitalizationType = .None;
        _passwordTextField.secureTextEntry = true;
        _passwordTextField.clearsOnBeginEditing = true;
        _passwordTextField.attributedPlaceholder = NSAttributedString.init(string: self.localizedString(key: "user.password"), attributes: nil);
        _passwordTextField.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        _passwordTextField.leftViewMode = .Always;
        _passwordTextField.layer.borderColor = UIColor.grayColor().CGColor;
        _passwordTextField.layer.borderWidth = 1.0;
        var rules = ValidationRuleSet<String>();
        let passwordRule = ValidationRulePattern(pattern: PASSWORD_VALIDATION_REGEX, failureError: ValidationError(message: self.localizedString(key: "passwordValidFail.message")));
        rules.addRule(passwordRule);
        _passwordTextField.validationRules = rules;
        _passwordTextField.validationHandler = { result, control in
            self.isPasswordValid = result.isValid;
        }
        _passwordTextField.validateOnEditingEnd(true);
        return _passwordTextField;
    }();

    private(set) lazy var retypePasswordTextField: UITextField = {
        let _retypePasswordTextField = UITextField();
        _retypePasswordTextField.delegate = self;
        _retypePasswordTextField.spellCheckingType = .No;
        _retypePasswordTextField.autocorrectionType = .No;
        _retypePasswordTextField.autocapitalizationType = .None;
        _retypePasswordTextField.secureTextEntry = true;
        _retypePasswordTextField.clearsOnBeginEditing = true;
        _retypePasswordTextField.attributedPlaceholder = NSAttributedString.init(string: self.localizedString(key: "user.confirmPassword"), attributes: nil);
        _retypePasswordTextField.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        _retypePasswordTextField.leftViewMode = .Always;
        _retypePasswordTextField.layer.borderColor = UIColor.grayColor().CGColor;
        _retypePasswordTextField.layer.borderWidth = 1.0;
        var rules = ValidationRuleSet<String>();
        let retypePasswordRule = ValidationRuleEquality(dynamicTarget: { return self.passwordTextField.text ?? "" }, failureError: ValidationError(message: self.localizedString(key: "passwordNotMatchError.message")));
        rules.addRule(retypePasswordRule);
        _retypePasswordTextField.validationRules = rules;
        _retypePasswordTextField.validationHandler = { result, control in
            self.isRetypePasswordValid = result.isValid;
        }
        _retypePasswordTextField.validateOnEditingEnd(true);
        return _retypePasswordTextField;
    }();
    
    private(set) lazy var emailFailureAlertController: UIAlertController = {
        let _emailFailureAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailFormatError.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _emailFailureAlertController.addAction(cancelAction);
        return _emailFailureAlertController;
    }();
    
    private(set) lazy var passwordValidFailAlertController: UIAlertController = {
        let _passwordValidFailAlertController = UIAlertController(title: nil, message: self.localizedString(key: "passwordValidFail.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.passwordTextField.becomeFirstResponder();
        });
        _passwordValidFailAlertController.addAction(cancelAction);
        return _passwordValidFailAlertController;
    }();

    private(set) lazy var passwordNotMatchAlertController: UIAlertController = {
        let _passwordNotMatchAlertController = UIAlertController(title: nil, message: self.localizedString(key: "passwordNotMatchError.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.retypePasswordTextField.becomeFirstResponder();
        });
        _passwordNotMatchAlertController.addAction(cancelAction);
        return _passwordNotMatchAlertController;
    }();

    // MARK: - Implementation of SSAuthenticationNavigationBarDelegate protocols
    
    func skip() {
        
    }
    
    func back() {
        self.emailTextField.delegate = nil;
        self.passwordTextField.delegate = nil;
        self.retypePasswordTextField.delegate = nil;
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    // MARK: - Implementation of UITextFieldDelegate protocols
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        textField.layer.borderColor = UIColor.grayColor().CGColor;
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text?.characters.count > 0) {
            if (textField == self.emailTextField) {
                if (self.isEmailValid == false) {
                    textField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.emailFailureAlertController, animated: true, completion: nil);
                }
            } else if (textField == self.passwordTextField) {
                if (self.isPasswordValid == false) {
                    textField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.passwordValidFailAlertController, animated: true, completion: nil);
                }
            } else {
                if (self.isRetypePasswordValid == false) {
                    textField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.passwordNotMatchAlertController, animated: true, completion: nil);
                }
            }
        }
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return false;
    }
    
    // MARK: - Public Methods
    
    func setup() {
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    func showLoadingView() {
        self.view.bringSubviewToFront(self.loadingView!);
        UIView.animateWithDuration(0.3) { 
            self.loadingView?.alpha = 1.0;
        }
    }
    
    func hideLoadingView() {
        UIView.animateWithDuration(0.3) {
            self.loadingView?.alpha = 0.0;
        }
    }
    
    func localizedString(key key: String) -> String {
        return self.resourceBundle.localizedStringForKey(key, value: nil, table: "SS_Authentication");
    }
    
    // MARK: - Subviews
    
    private func setupNavigationBar() {
        self.navigationBar = SSAuthenticationNavigationBar.init();
        self.navigationBar?.delegate = self;
        self.navigationBar?.backgroundColor = UIColor.yellowColor();
    }
    
    private func setupLoadingView() {
        self.loadingView = SSAuthenticationLoadingView.init();
        self.loadingView?.alpha = 0.0;
    }
    
    func setupSubviews() {
        self.setupLoadingView();
        self.loadingView!.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.loadingView!);
        
        self.setupNavigationBar();
        self.navigationBar?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.navigationBar!);
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return self.hideStatusBar;
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override public func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["loading": self.loadingView!,
                         "bar": self.navigationBar!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[loading]", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bar]|", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[loading]", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(64)]", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraint(NSLayoutConstraint.init(item: self.loadingView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0));

            self.view.addConstraint(NSLayoutConstraint.init(item: self.loadingView!, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0));

            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }

    // MARK: - View lifecycle
    
    override public func loadView() {
        self.view = UIView.init();
        self.view.backgroundColor = UIColor.whiteColor();
        self.view.translatesAutoresizingMaskIntoConstraints = true;
        
        self.setupSubviews();
        self.updateViewConstraints();
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
