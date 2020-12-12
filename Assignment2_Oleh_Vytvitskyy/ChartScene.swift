//
//  ChartScene.swift
//  Assignment2_Oleh_Vytvitskyy
//
//  Created by oleh on 2020-11-20.
//

import UIKit
import SpriteKit

class ChartScene: SKScene
{
    
    // property for the line graph
    var shapeLine = SKShapeNode()
    var labelDate = SKLabelNode() // label to display the selected date
    var hLine = SKShapeNode() // nodes for horizontal lines
    var marker = SKShapeNode(circleOfRadius: 15)

    
    func updateChart(_ values: [Int], startDate: Date, currDate: Date)
    {
        // generate path to draw line graph
        let path = CGMutablePath()
        
        let scaleX = 800 / CGFloat(values.count - 1)
        let maxValue = values.max() ?? 0
        let scaleY = 800 / CGFloat(maxValue)
        var currPosX : Int = 0
        var currPosY : Int = 0
        
        
        for i in 0 ..< (values.count - 1)
        {
            path.move(to: CGPoint(x: scaleX * CGFloat(i) + 100,
                                  y: scaleY * CGFloat(values[i] + 100)))
            path.addLine(to: CGPoint(x: scaleX * CGFloat(i+1) + 100,
                                     y: scaleY * CGFloat(values[i+1]) + 100))
            currPosX = i
            currPosY = values[i]
        }
        
        
        
        // assign new path to the line node
        shapeLine.removeFromParent()
        shapeLine.path = path
        shapeLine.strokeColor = .systemBlue
        shapeLine.lineWidth = 2
        addChild(shapeLine)
        
        let currPoslabelX = CGFloat(currPosX ?? values.count) * scaleX + 100
        let currPoslabelY = CGFloat(currPosY) * scaleY + 100
        
        //let selectedY = CGFloat(selectedDateValue ?? 0) * scaleY + 100
        
        // add date label
        labelDate.removeFromParent()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        labelDate.text = dateFormatter.string(from: currDate)
        labelDate.color = .black
        labelDate.position.x = currPoslabelX
        labelDate.position.y = 60
        self.addChild(labelDate)
        
        // add current market
        marker.removeFromParent()
        marker.fillColor = .white
        marker.strokeColor = .orange
        marker.lineWidth = 5
        marker.position.x = currPoslabelX
        marker.position.y = currPoslabelY
        marker.zPosition = 1
        self.addChild(marker)
        
        // create veritcal line
        hLine.removeFromParent()
        let path1 = CGMutablePath()
        path1.move(to: CGPoint(x: currPoslabelX, y: currPoslabelY))
        path1.addLine(to: CGPoint(x: currPoslabelX, y: 100))
        hLine.path = path1
        hLine.strokeColor = .gray
        hLine.lineWidth = 6
        self.addChild(hLine)
    }

}
