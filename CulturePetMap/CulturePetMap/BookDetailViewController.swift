//
//  BookDetailViewController.swift
//  CulturePetMap
//
//  Created by 이혜민 on 9/9/24.
//

import UIKit
import WebKit

class BookDetailViewController: UIViewController {
    @IBOutlet weak var webview: WKWebView!
    
    //리스트에서 전달받을 Url 선언하기
    var strURL : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let strURL, let myURL = URL(string: strURL) else { return }
        
        //Request를 담아 Web view에 로드하기
        
        let myRequst = URLRequest(url: myURL)
        webview.load(myRequst)

        // Do any additional setup after loading the view.
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
