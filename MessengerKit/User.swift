//
//  User.swift
//  MeetSivi
//
//  Created by Norayr Harutyunyan on 1/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import MessengerKit

struct User: MSGUser {
    
    var displayName: String
    
    var avatar: UIImage?
    
    var avatarUrl: URL?
    
    var isSender: Bool
    
}
