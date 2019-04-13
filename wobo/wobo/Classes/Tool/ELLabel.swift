//
//  ELLabel.swift
//  wobo
//
//  Created by Soul Ai on 4/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

enum TapHandlerType : Int {
    case noneHandle = 0
    case userHandle = 1
    case topicHandle = 2
    case linkHandle = 3
}

public class ELLabel: UILabel {
    // 重写系统的属性
    public override var text: String? {
        didSet {
            prepareText()
        }
    }
    
    public override var attributedText: NSAttributedString? {
        didSet {
            prepareText()
        }
    }

    public override var font: UIFont! {
        didSet {
            prepareText()
        }
    }
    
    public override var textColor: UIColor! {
        didSet {
            prepareText()
        }
    }
    
    public var matchTextColor = UIColor(red: 87/255.0, green: 196/255.0, blue: 251/255.0, alpha: 1.0) {
        didSet {
            prepareText()
        }
    }
    
    public var matchTextColorGreen = UIColor(red: 0/255.0, green: 255/255.0, blue: 158/255.0, alpha: 1.0) {
        didSet {
            prepareText()
        }
    }
    public var matchTextColorPurple = UIColor.purple {
        didSet {
            prepareText()
        }
    }
    
     // 懒加载属性
    /// NSMutableAttributeString的子类
    private lazy var textStorage = NSTextStorage() 
    /// 布局管理者
    private lazy var layoutManager = NSLayoutManager() 
    
    /// 容器,需要设置容器的大小
    private lazy var textContainer = NSTextContainer()
    
    /// 用于记录下标值
    private lazy var linkRanges = [NSRange]()
    private lazy var userRanges = [NSRange]()
    private lazy var topicRanges = [NSRange]()
    
    /// 用于记录用户选中的range
    private var selectedRange : NSRange?
    
    /// 用户记录点击还是松开
    private var isSelected : Bool = false
    
    /// 闭包属性,用于回调
    private var tapHandlerType = TapHandlerType.noneHandle
    
    //typealias 类型别名
    public typealias ELTapHandler = (ELLabel, String, NSRange) -> Void
    public var linkTapHandler : ELTapHandler?
    public var topicTapHandler : ELTapHandler?
    public var userTapHandler : ELTapHandler?
    
     // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareTextSystem()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTextSystem()
    }
    
    // MARK:- 布局子控件
    public override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = frame.size
    }
    
    // MARK:- 重写drawTextInRect方法
    public override func drawText(in rect: CGRect) {
        // 1.绘制背景
        if selectedRange != nil {
            // 2.0.确定颜色
            let selectedColor = isSelected ? UIColor(white: 0.7, alpha: 0.2) : UIColor.clear
            
            // 2.1.设置颜色 NSBackgroundColorAttributeName
            textStorage.addAttribute(.backgroundColor, value: selectedColor, range: selectedRange!)
            
            // 2.2.绘制背景
            layoutManager.drawBackground(forGlyphRange: selectedRange!, at: CGPoint(x: 0, y: 0))
            
        }
        
        // 2.绘制字形
        // 需要绘制的范围
        let range = NSRange(location: 0, length: textStorage.length)
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint.zero)
    }
    
}


extension ELLabel {
    /// 准备文本系统
    private func prepareTextSystem() {
        // 0.准备文本
        prepareText()
        // 1.将布局添加到storeage中
        textStorage.addLayoutManager(layoutManager)
        
        // 2.将容器添加到布局中
        layoutManager.addTextContainer(textContainer)
        
        // 3.让label可以和用户交互
        isUserInteractionEnabled = true
        // 4.设置间距为0
        textContainer.lineFragmentPadding = 0
        
    }
    
    /// 准备文本
    private func prepareText() {
        // 1.准备字符串
        var attrString : NSAttributedString?
        
        if attributedText != nil {
            attrString = attributedText
        } else if text != nil {
            attrString = NSAttributedString(string: text!)
        } else {
            attrString = NSAttributedString(string: "")
        }
        
        selectedRange = nil
        
        // 2.设置换行模型
        let attrStringM = addLineBreak(attrString!)
        
        attrStringM.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrStringM.length))
        
        // 3.设置textStorage的内容
        textStorage.setAttributedString(attrStringM)
        
        // 4.匹配URL
        if let linkRanges = getLinkRanges() {
            self.linkRanges = linkRanges
            for range in linkRanges {
                textStorage.addAttribute(.foregroundColor, value: matchTextColorGreen, range: range)
            }
        }
        
        // 5.匹配@用户
        if let userRanges = getRanges("@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*") {
            self.userRanges = userRanges
            for range in userRanges {
                textStorage.addAttribute(.foregroundColor, value: matchTextColor, range: range)
            }
        }
        
        // 6.匹配话题##
        if let topicRanges = getRanges("#.*?#") {
            self.topicRanges = topicRanges
            for range in topicRanges {
                textStorage.addAttribute(.foregroundColor, value: matchTextColorPurple, range: range)
            }
        }
        
        setNeedsDisplay()
    }
    
}

// MARK:- 字符串匹配封装
extension ELLabel {
    
    private func getRanges(_ pattern: String) -> [NSRange]? {
        // 创建正则表达式对象
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        return  getRangesFromResult(regex)
    }
    
    private func getLinkRanges() -> [NSRange]? {
        // 创建正则表达式
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        
        return getRangesFromResult(detector)
    }
    
    private func getRangesFromResult(_ regex: NSRegularExpression) -> [NSRange] {
        // 1.匹配结果
        let results = regex.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        // 2.遍历结果
        var ranges = [NSRange]()
        for res in results {
            ranges.append(res.range)
        }
        return ranges
        
    }
    
    
    
    
}

// MARK:- 点击交互的封装
extension ELLabel {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 0.记录点击
        isSelected = true
        
        // 1.获取用户点击的点
        let selectedPoint = touches.first!.location(in: self)
        
        // 2.获取该点所在的字符串的range
        selectedRange = getSelectRange(selectedPoint)
        
        // 3.是否处理了事件
        if selectedRange == nil {
            super.touchesBegan(touches, with: event)
        }
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectedRange == nil {
            super.touchesBegan(touches, with: event)
            return
        }
        
        // 0.记录松开
        isSelected = false
        
        // 2.重新绘制
        setNeedsDisplay()
        
        // 3.取出内容
        let contentText = (textStorage.string as NSString).substring(with: selectedRange!)
        
        // 3.回调
        switch tapHandlerType {
        case .userHandle:
            if userTapHandler != nil {
                userTapHandler!(self, contentText, selectedRange!)
            }
        case .topicHandle:
            if topicTapHandler != nil {
                topicTapHandler!(self, contentText, selectedRange!)
            }
        case .linkHandle:
            if linkTapHandler != nil {
                linkTapHandler!(self, contentText, selectedRange!)
            }
        default:
            break
        }
    }
    
    
    private func getSelectRange(_ selectedPoint: CGPoint) -> NSRange? {
        // 0.如果属性字符串为nil,则不需要判断
        if textStorage.length == 0 {
            return nil
        }
        
        // 1.获取选中点所在的下标值(index)
        let index = layoutManager.glyphIndex(for: selectedPoint, in: textContainer)
        
        // 2.判断下标在什么内
        // 2.1.判断是否是一个链接
        for linkRange in linkRanges {
            if index > linkRange.location && index < linkRange.location + linkRange.length {
                setNeedsDisplay()
                tapHandlerType = .linkHandle
                return linkRange
            }
        }
        
        
        // 2.2.判断是否是一个@用户
        for userRange in userRanges {
            if index > userRange.location && index < userRange.location + userRange.length {
                setNeedsDisplay()
                tapHandlerType = .userHandle
                return userRange
            }
        }
        
        // 2.3.判断是否是一个#话题#
        for topicRange in topicRanges {
            if index > topicRange.location && index < topicRange.location + topicRange.length {
                setNeedsDisplay()
                tapHandlerType = .topicHandle
                return topicRange
            }
        }
        
        return nil
    }
    
    
}

// MARK:- 补充
extension ELLabel {
    /// 如果用户没有设置lineBreak,则所有内容会绘制到同一行中,因此需要主动设置
    private func addLineBreak(_ attrString: NSAttributedString) -> NSMutableAttributedString {
        let attrStringM = NSMutableAttributedString(attributedString: attrString)
        
        if attrStringM.length == 0 {
            return attrStringM
        }
        
        var range = NSRange(location: 0, length: 0)
        var attributes = attrStringM.attributes(at: 0, effectiveRange: &range)
        var paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle
        
        if paragraphStyle != nil {
            paragraphStyle!.lineBreakMode = NSLineBreakMode.byWordWrapping
        } else {
            paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle!.lineBreakMode = NSLineBreakMode.byWordWrapping
            attributes[.paragraphStyle] = paragraphStyle
            
            attrStringM.setAttributes(attributes, range: range)
        }
        
        return attrStringM
    }
}