//
//  TickView.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 30/10/18.
//  Copyright © 2018 Ninxsoft. All rights reserved.
//

import Cocoa

@IBDesignable
class TickView: NSView {

  @IBInspectable var thickness: CGFloat = 10.0
  @IBInspectable var color: NSColor = NSColor(calibratedRed: 86.0/255.0,
                                              green: 215.0/255.0,
                                              blue: 43.0/255.0,
                                              alpha: 1.0)
  @IBInspectable var tickColor: NSColor = NSColor.white

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    color.setFill()
    tickColor.setStroke()
    let lineWidth = dirtyRect.height * thickness / 100
    let ratio = CGFloat(0.75)
    let padding = CGFloat((dirtyRect.width - dirtyRect.height * ratio) / 2)
    let rect = NSRect(x: padding, y: dirtyRect.height * (1 - ratio) / 2,
                      width: dirtyRect.height * ratio,
                      height: dirtyRect.height * ratio)
    let ovalPath = NSBezierPath(ovalIn: rect)
    ovalPath.fill()
    let bezierPath = NSBezierPath()
    bezierPath.move(to: NSPoint(x: padding + dirtyRect.height * ratio * 0.29,
                                y: dirtyRect.height * (1 - ratio) / 2 + dirtyRect.height * ratio * 0.47))
    bezierPath.line(to: NSPoint(x: padding + dirtyRect.height * ratio * 0.42,
                                y: dirtyRect.height * (1 - ratio) / 2 + dirtyRect.height * ratio * 0.32))
    bezierPath.line(to: NSPoint(x: padding + dirtyRect.height * ratio * 0.68,
                                y: dirtyRect.height * (1 - ratio) / 2 + dirtyRect.height * ratio * 0.71))
    bezierPath.lineCapStyle = .round
    bezierPath.lineJoinStyle = .round
    bezierPath.lineWidth = lineWidth
    bezierPath.stroke()
  }
}
