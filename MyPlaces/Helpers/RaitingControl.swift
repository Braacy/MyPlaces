//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 14.11.2025.
//

import UIKit

@IBDesignable class RaitingControl: UIStackView {
//MARK: - Properties
    private var raitingButtons: [UIButton] = []
    
    var raiting = 0 {
        didSet{
            updateButtonSelectionStates()
        }
    }
    
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
        guard let index = raitingButtons.firstIndex(of: button) else {return}
        
        //определяем рейтинг, соответствующий звезде
        let selectedRaiting = index + 1
        
        if selectedRaiting == raiting{
            raiting = 0
        } else {
            raiting = selectedRaiting
        }
        
    }
    
    
    //MARK: - Private Methods
    
    private func setupButtons() {
        
        for button in raitingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        raitingButtons.removeAll()
        
        //загрузка картинки кнопки
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle, compatibleWith:
                                    self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let highLightedStar = UIImage(named: "highLightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        
        //создаем кнопки
        for _ in 0..<starCount {
            let button = UIButton()
            
            // определем изображение кнопки
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highLightedStar, for: .highlighted)
            button.setImage(highLightedStar, for: [.highlighted, .selected])
            
            
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
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in raitingButtons.enumerated() {
            button.isSelected = index < raiting
        }
    }
}
