//
//  SSAuthenticationRegisterViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationRegisterDelegate: class {
    func registerSuccess(user: SSUser);
}

public class SSAuthenticationRegisterViewController: SSAuthenticationBaseViewController {
    public weak var delegate: SSAuthenticationRegisterDelegate?;
    
    private var textFieldsStackView: UIStackView?;
    private var buttonsStackView: UIStackView?;
    private var registerButton: UIButton?;
    
    private var hasLoadedConstraints = false;

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
        self.delegate = nil;
    }
    
    // MARK: - Accessors

    private(set) lazy var emailAlreadyExistAlertController: UIAlertController = {
        let _emailAlreadyExistAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailExistError.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _emailAlreadyExistAlertController.addAction(cancelAction);
        return _emailAlreadyExistAlertController;
    }();

    private(set) lazy var registerFailedAlertController: UIAlertController = {
        let _registerFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "userRegisterFail.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _registerFailedAlertController.addAction(cancelAction);
        return _registerFailedAlertController;
    }();

    // MARK: - Events
    
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder();
        }
    }

    func registerButtonAction() {
        self.tapAction();
        guard (self.isEmailValid && self.isPasswordValid && self.isConfirmPasswordValid) else {
            if (!self.isEmailValid) {
                if (!self.emailFailureAlertController.isBeingPresented()) {
                    self.emailTextField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.emailFailureAlertController, animated: true, completion: nil);
                }
            } else if (!self.isPasswordValid) {
                if (!self.passwordValidFailAlertController.isBeingPresented()) {
                    self.passwordTextField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.passwordValidFailAlertController, animated: true, completion: nil);
                }
            } else {
                if (!self.confirmPasswordValidFailAlertController.isBeingPresented()) {
                    self.confirmPasswordTextField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.confirmPasswordValidFailAlertController, animated: true, completion: nil);
                }
            }
            return;
        }

        self.registerButton?.userInteractionEnabled = false;
        self.showLoadingView();
        let email = self.emailTextField.text as String!;
        let password = self.passwordTextField.text as String!;
        let userDict = [EMAIL_KEY: email,
                        PASSWORD_KEY: password];
        SSAuthenticationManager.sharedInstance.emailValidate(email: email) { (bool, statusCode, error) in
            if (bool == true) {
                SSAuthenticationManager.sharedInstance.register(userDictionary: userDict) { (user, statusCode, error) in
                    if (user != nil) {
                        self.delegate?.registerSuccess(user!);
                    } else {
                        if (statusCode == INVALID_STATUS_CODE) {
                            self.presentViewController(self.emailAlreadyExistAlertController, animated: true, completion: nil);
                        } else {
                            self.presentViewController(self.registerFailedAlertController, animated: true, completion: nil);
                        }
                    }
                    self.hideLoadingView();
                    self.registerButton?.userInteractionEnabled = true;
                }
            } else {
                if (error != nil) {
                    self.presentViewController(self.registerFailedAlertController, animated: true, completion: nil);
                } else {
                    self.presentViewController(self.emailFailureAlertController, animated: true, completion: nil);
                }
                self.hideLoadingView();
                self.registerButton?.userInteractionEnabled = true;
            }
        }
    }
        
    // MARK: - Public Methods
    
    override public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.confirmPasswordTextField) {
            self.registerButtonAction();
        } else if (textField == self.passwordTextField) {
            self.confirmPasswordTextField.becomeFirstResponder();
        } else {
            self.passwordTextField.becomeFirstResponder();
        }
        return super.textFieldShouldReturn(textField);
    }

    // MARK: - Subviews
    
    private func setupTextFieldsStackView() {
        self.textFieldsStackView = UIStackView();
        self.textFieldsStackView?.axis = .Vertical;
        self.textFieldsStackView?.alignment = .Center;
        self.textFieldsStackView!.distribution = .EqualSpacing;
        self.textFieldsStackView?.spacing = 20.0;
    }
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView();
        self.buttonsStackView!.axis = .Vertical;
        self.buttonsStackView!.alignment = .Center;
        self.buttonsStackView!.distribution = .EqualSpacing;
        self.buttonsStackView?.spacing = 20.0;
    }

    private func setupRegisterButton() {
        self.registerButton = UIButton(type: .System);
        self.registerButton?.setAttributedTitle(NSAttributedString.init(string: self.localizedString(key: "user.register"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal);
        self.registerButton?.addTarget(self, action: .registerButtonAction, forControlEvents: .TouchUpInside);
        self.registerButton?.layer.borderWidth = 1.0;
        self.registerButton?.layer.borderColor = UIColor.blackColor().CGColor;
    }
    
    override func setupSubviews() {
        super.setupSubviews();
        
        self.setupTextFieldsStackView();
        self.textFieldsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.textFieldsStackView!);
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField);
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField);
        
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.confirmPasswordTextField);

        self.setupButtonsStackView();
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.buttonsStackView!);
        
        self.setupRegisterButton();
        self.registerButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.registerButton!);
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: .tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override public func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "confirm": self.confirmPasswordTextField,
                         "buttons": self.buttonsStackView!,
                         "register": self.registerButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[texts]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[buttons]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[email]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[password]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[confirm]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[confirm(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[register]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[register(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }

    // MARK: - View lifecycle
    
    override public func loadView() {
        super.loadView();
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationBar?.titleLabel?.attributedText = NSAttributedString(string: self.localizedString(key: "user.register"), attributes: FONT_ATTR_LARGE_BLACK_BOLD);
        self.emailTextField.returnKeyType = .Next;
        self.passwordTextField.returnKeyType = .Next;
        self.confirmPasswordTextField.returnKeyType = .Go;
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.emailTextField.becomeFirstResponder();
    }
}

private extension Selector {
    static let registerButtonAction = #selector(SSAuthenticationRegisterViewController.registerButtonAction);
    static let tapAction = #selector(SSAuthenticationRegisterViewController.tapAction);
}