//
//  HomePageNavigationViewController.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/1.
//

import UIKit

class HomePageNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.view.backgroundColor = .gray
        self.viewControllers = [MainViewViewController()]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
