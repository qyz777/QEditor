//
//  EditPlayerView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

public class EditPlayerView: UIView {
    
    public let player: CompositionPlayer
    
    public var playerView: CompositionPlayerView {
        return player.playerView
    }

    public init(player: CompositionPlayer) {
        self.player = player
        super.init(frame: .zero)
        addSubview(playerView)
    }
    
    required init?(coder: NSCoder) {
        self.player = CompositionPlayer()
        super.init(coder: coder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerView.frame = bounds
    }

}
