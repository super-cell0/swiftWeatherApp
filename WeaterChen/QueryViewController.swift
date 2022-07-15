//
//  QueryViewController.swift
//  WeaterChen
//
//  Created by xiaoxiong beidi on 2022/5/1.
//

import UIKit

//第一步1
protocol QueryViewControllerDelegate {
    func didChangeCity(city: String)
}

class QueryViewController: UIViewController {
    
    var currentCity = ""
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    //第二步2
    var queryDelegate: QueryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityTextField.becomeFirstResponder()
        //收起键盘
        //cityTextField.resignFirstResponder()
        currentCityLabel.text = currentCity
    }
    
    @IBAction func goback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func queryButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        //第三步3
        if !cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryDelegate?.didChangeCity(city: cityTextField.text!)
        }
    }
    
}
