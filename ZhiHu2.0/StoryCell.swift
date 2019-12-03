//
//  StoryCell.swift
//  ZhiHu2.0
//
//  Created by 游奕桁 on 2019/11/28.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit

class StoryCell: UITableViewCell {
    var thumbNail: UIImageView!
    var titleLabel: UILabel!
    
    var story: Story! {
        didSet {
            self.titleLabel.text = story.title
            self.thumbNail.af_setImage(withURL: story.thumbNailURL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .gray
    }
    
    func configure(for story: Story) {
        self.story = story
    }
}
