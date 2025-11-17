//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 14.11.2025.
//

import UIKit

class RaitingControl: UIStackView {
//MARK: - Properties
    private var raitingButtons: [UIButton] = []
    
    var raiting = 0
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
//MARK: -Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    //MARK: - Button Action
    
    @objc func raitingBtnTapped(button: UIButton) {
        print("Button tapped")
    }
    
    
    //MARK: - Private Methods
    
    private func setupButtons() {
        
        for button in raitingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        raitingButtons.removeAll()
        
        
        //создаем кнопки
        
        for _ in 0..<starCount {
            let button = UIButton()
            button.backgroundColor = .red
            
            //добавляем констрейты
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //настройка действия кнопки
            button.addTarget(self, action: #selector(raitingBtnTapped(button:)), for: .touchUpInside)
            
            //добавляем кнопку в стэк вью
            addArrangedSubview(button)
            
            //после каждой итерации помещение новой кнопки в масив кнопок
            raitingButtons.append(button)
        }
    }
}
