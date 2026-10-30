//
//  ViewController.swift
//  ZLFlexKit
//
//  Created by fanpeng on 06/08/2026.
//  Copyright (c) 2026 fanpeng. All rights reserved.
//

import UIKit
import ZLFlexKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if #available(iOS 27.1, *) {
            let arrangementVC = UIArrangementViewController()
            arrangementVC.setViewController(FlexKitDemoViewController(), for: .primary)
            
            arrangementVC.setViewController(TableViewController(), for: .secondary)
            
            arrangementVC.updateArrangement(.split.axes(.horizontal))
            addChild(arrangementVC)
            view.addSubview(arrangementVC.view)
            arrangementVC.view.box.edgesZero()
            arrangementVC.didMove(toParent: self)
            
            let interaction = UIHingeInteraction { [weak self] _, update in

                      guard let self else { return }

                      guard let hinge = update.hinge else {

                          print("当前 View 不在可提供铰链状态的视图层级中")

                          return

                      }

                      let angle = hinge.angle * 180 / .pi

                      print("铰链角度：\(angle)°")

                      print("铰链状态：\(hinge.status)")

                      self.handleHingeChange(

                          angle: angle,

                          status: hinge.status

                      )

                  }
            print("isEnabled:", interaction.isEnabled)

                  view.addInteraction(interaction)
        } else {
            // Fallback on earlier versions
        }
    }
    @available(iOS 27.1, *)
    private func handleHingeChange(

           angle: CGFloat,

           status: UIHinge.Status

       ) {

           // 根据铰链角度和状态调整业务逻辑

       }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }

    

}

