//
//  FooterView.swift
//  iMusic
//
//  Created by Arkasha Zuev on 08.12.2020.
//

import UIKit

class FooterView: UIView {
    
    private var myLable: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.textAlignment = .center
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.textColor = #colorLiteral(red: 0.631372549, green: 0.6470588235, blue: 0.662745098, alpha: 1)
        return lable
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
    }
    
    private func setupElements() {
        
        addSubview(myLable)
        addSubview(loader)
        
        loader.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        loader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        loader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        myLable.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        myLable.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 8).isActive = true
        
    }
    
    func showLoader() {
        loader.startAnimating()
        myLable.text = "LOADING"
    }
    
    func hideLoader() {
        loader.stopAnimating()
        myLable.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
