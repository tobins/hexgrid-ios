//
//  ViewController.swift
//  HexGrid
//
//  Created by Tobin Schwaiger-Hastanan on 3/19/18.
//  Copyright © 2018 Tobin Schwaiger-Hastanan. All rights reserved.
//

import UIKit

extension UIBezierPath {
    static func path(shapeIn size:CGSize, sides:Int) -> UIBezierPath {
        var points:[CGPoint] = []
        let path = UIBezierPath()
        let scale = CGFloat(size.width < size.height ? size.width : size.height) / 2.0
        
        for i in 0..<sides {
            let x = scale * sin(2.0 * CGFloat.pi * CGFloat(i) / CGFloat(sides))
            let y = scale * cos(2.0 * CGFloat.pi * CGFloat(i) / CGFloat(sides))
            
            points.append(CGPoint(x: x, y: y))
        }
        
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        
        return path
    }
}


class ViewController: UIViewController, CAAnimationDelegate {
    
    var from:CATransform3D = CATransform3DMakeScale(0, 0, 1)
    var to:CATransform3D = CATransform3DMakeScale(1, 1, 1)
    
    lazy var shapeLayers:[CAShapeLayer] = {
        var layers:[CAShapeLayer] = []
        
        for i in 0..<110 {
            let shape = CAShapeLayer()
            shape.path = UIBezierPath.path(shapeIn:CGSize(width: 50, height: 50), sides: 6).cgPath
            
            shape.fillColor = UIColor.white.cgColor
            shape.strokeColor = UIColor.red.cgColor
            shape.transform = CATransform3DMakeScale(0, 0, 1)
            
            layers.append(shape)
        }
        
        return layers
    }()
    
    lazy var topView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(view)
        
        let margins = self.view.layoutMarginsGuide
        
        view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.topView.backgroundColor = UIColor.darkGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func animate(from:CATransform3D, to:CATransform3D) {
        let hexWidth = CGFloat(sqrt(3) / 2 * 50)
        let start = CACurrentMediaTime()
        let duration = 0.5
        for y in 0..<11 {
            for x in 0..<10 {
                let shape = self.shapeLayers[y * 10 + x]
                let offset = (y % 2 == 0) ? 0 : hexWidth / 2.0
                shape.position = CGPoint(x:  CGFloat(x) * hexWidth + offset, y: CGFloat(y) *  (50.0 * 3.0/4.0) )
                
                let transformAnimation = CABasicAnimation(keyPath: "transform")
                transformAnimation.beginTime = start + Double(y) * (duration/8.0) + Double(x) * (duration / 8.0)
                transformAnimation.fromValue = from
                transformAnimation.toValue = to
                transformAnimation.duration = duration
                transformAnimation.isRemovedOnCompletion = false
                transformAnimation.fillMode = kCAFillModeForwards
                transformAnimation.repeatCount = 0
                transformAnimation.delegate = self
                transformAnimation.setValue(shape, forKey: "foo")
                self.topView.layer.addSublayer(shape)
                shape.add(transformAnimation, forKey: "transformAnimation")
            }
        }
        
        
    }

    @IBAction func press(_ sender: Any) {
        self.animate( from:self.from, to:self.to)
        let temp = self.from
        self.from = to
        self.to = temp
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let shape = anim.value(forKey: "foo") as? CAShapeLayer {
            shape.removeAnimation(forKey: "transformAnimation")
            anim.setValue(nil, forKey: "foo")
            shape.transform = self.from
        }
    }
}

