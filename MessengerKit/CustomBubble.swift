//
//  CustomBubble.swift
//  MeetSivi
//
//  Created by Norayr Harutyunyan on 1/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class CustomBubble: UITextView {
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupView()
    }
    
    fileprivate func setupView() {
        
        backgroundColor = .clear
        
        layer.cornerRadius = 22
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        
        isEditable = false
        isSelectable = true // TODO: Check that links are tappable
        dataDetectorTypes = [.flightNumber, .calendarEvent, .address, .phoneNumber, .link, .lookupSuggestion]
        isUserInteractionEnabled = true
        delaysContentTouches = true
        font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        translatesAutoresizingMaskIntoConstraints = false
        textContainerInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        textContainer.lineFragmentPadding = 0
        
        linkTextAttributes[NSAttributedStringKey.underlineStyle.rawValue] = NSUnderlineStyle.styleSingle.rawValue
        
    }
    
    
    func calculatedSize(in size: CGSize) -> CGSize {
        return sizeThatFits(CGSize(width: size.width - 40, height: .infinity))
    }
    
    // Disables text selection
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let pos = closestPosition(to: point) else {
            return false
        }
        
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character,
                                                           inDirection: UITextLayoutDirection.left.rawValue) else {
                                                            return false
        }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }

}
