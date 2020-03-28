//
//  CompositionImageView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/28.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import GPUImage

public class CompositionImageView: UIView {
    
    public var image: UIImage? {
        willSet {
            imageView.image = newValue
        }
    }
    
    public var filter: CompositionFilter? {
        willSet {
            guard let filter = newValue?.instance() else { return }
            guard let image = image else { return }
            imageView.image = try? image.filterWithPipeline { (input, output) in
                input.removeAllTargets()
                input.addTarget(filter, atTargetIndex: 0)
                filter.addTarget(output, atTargetIndex: 0)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

}
