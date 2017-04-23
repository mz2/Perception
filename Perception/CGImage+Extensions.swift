//
//  CGImage+Extensions.swift
//  Perception
//
//  Created by Matias Piipari on 23/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

import Foundation

extension CGImage {
    
    func split(horizontally horizontalSectors: UInt, vertically verticalSectors: UInt) -> AnyCollection<CGImage>
    {
        let height = CGFloat(verticalSectors)
        let width = CGFloat(horizontalSectors)
        
        let pairs = (0 ..< horizontalSectors).flatMap { i in
            (0 ..< verticalSectors).flatMap { j in
                return (i, j)
            }
        }
        
        let lazyImages = pairs.lazy.flatMap { (i, j) -> CGImage? in
            let rect = CGRect(origin:CGPoint(x: CGFloat(i) * width,
                                             y: CGFloat(j) * height),
                              size: CGSize(width: width, height: height))
            return self.cropping(to: rect)
        }
        
        return AnyCollection<CGImage>(lazyImages)
    }
    
}
