//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Леонид  Егоров on 01.07.2023.
//

import UIKit

class TodoListViewController: UIViewController {
    
    private let labelsAndButtonView = LabelsAndButtonView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setConstraints()
    }
    
    private func setupLayout() {
        view.backgroundColor = Resources.Colors.primaryBack
        
        view.addSubview(labelsAndButtonView)
    }
    
}

extension TodoListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            labelsAndButtonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            labelsAndButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.edgeSize * 2),
            labelsAndButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Resources.Constants.edgeSize * -2)
        ])
    }
}
