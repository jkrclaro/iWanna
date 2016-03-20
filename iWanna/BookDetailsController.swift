//
//  BookDetailsController.swift
//  
//
//  Created by John Claro on 19/03/2016.
//
//

import UIKit

class BookDetailsController: UIViewController {
    
    var book: Book!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("WTF2")
    }
}