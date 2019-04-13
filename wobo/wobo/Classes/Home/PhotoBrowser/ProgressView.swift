//
//  ProgressView.swift
//  wobo
//
//  Created by Soul Ai on 5/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

class ProgressView: UIView {

    var progress : CGFloat = 0 {
        didSet {
            setNeedsDisplay() //设置需要显示
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        /*
         1.center: CGPoint  中心点坐标
         2.radius: CGFloat  半径
         3.startAngle: CGFloat 起始点所在弧度
         4.endAngle: CGFloat   结束点所在弧度
         5.clockwise: Bool     是否顺时针绘制
         7.画圆时，没有坐标这个概念，根据弧度来定位起始点和结束点位置。M_PI即是圆周率。画半圆即(0,M_PI),代表0到180度。全圆则是(0,M_PI*2)，代表0到360度
         */
        
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let radius = rect.width * 0.5
        let startAngle = CGFloat(Double.pi)
        let endAngle = CGFloat(Double.pi) * 2 + progress + startAngle
        
        // 创建贝塞尔曲线
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // 绘制一条中心点的线
        path.addLine(to: center)
        path.close()
        
        // 设置绘制的颜色
        UIColor(white: 1.0, alpha: 0.5).setFill()
        
        // 开始绘制fill
        path.stroke()
    }
    
}
