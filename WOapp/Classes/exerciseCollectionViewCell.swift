//
//  exerciseCollectionViewCell.swift
//  WOapp
//
//  Created by David Cheng on 12/6/17.
//  Copyright © 2017 David Cheng. All rights reserved.
//

import UIKit

class exerciseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var border: UIView!
    
    @IBOutlet weak var exerciseName: UILabel!
    
    @IBOutlet weak var sets: UILabel!
    
    @IBOutlet weak var reps: UILabel!
    @IBOutlet weak var type: UILabel!
}
