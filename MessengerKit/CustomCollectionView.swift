//
//  CustomCollectionView.swift
//  MeetSivi
//
//  Created by Norayr Harutyunyan on 1/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MessengerKit

class CustomCollectionView: MSGImessageCollectionView {

    override func registerCells() {
        super.registerCells()
        
        register(UINib(nibName: "CustomOutgoingTextCell", bundle: nil), forCellWithReuseIdentifier: "outgoingText")
        register(UINib(nibName: "CustomIncomingTextCell", bundle: nil), forCellWithReuseIdentifier: "incomingText")
    }

}
