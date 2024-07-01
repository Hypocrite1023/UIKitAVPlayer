//
//  ClipRecordDelegate.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/2.
//

import Foundation
protocol ClipRecordDelegate: AnyObject {
    func receiveClipRecord(clipRecord: [clipInfo])
}
