//
//  BookListTableTableViewController.swift
//  CulturePetMap
//
//  Created by 이혜민 on 9/9/24.
//

import UIKit

class BookListTableTableViewController: UITableViewController {
    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnPrev: UIBarButtonItem!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    
    //API key 개인정보이므로 숨겨야 함
    let myApiKey = "{API key}"
    var myDocuments: [[String: Any]]?
    var currentPage = 1{
        didSet{
            btnPrev.isEnabled = currentPage > 1
            searchWithQuery(searchBar.text, page: currentPage)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        btnPrev.isEnabled = false
        btnNext.isEnabled = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func searchWithQuery(_ query: String?, page: Int){
        guard let query else{
            return
        }
        
        //URL 가공하기
        let myEndPoint = "https://dapi.kakao.com/v3/search/book?query=\(query)&page=\(page)"
        guard let mystrURL = myEndPoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let myURL = URL(string: mystrURL)
        else { return  }
        
        
        //URLRequest structure에서 Header의 값을 API 프로토콜에 맞춰 변경해야 하므로 변수로 선언
        var myRequest = URLRequest(url: myURL)
        
        //API에서 요청하는 필수값 세팅하기
        myRequest.httpMethod = "GET"
        myRequest.addValue(myApiKey, forHTTPHeaderField: "Authorization")
        
        //Task 생성 및 실행 : mySession을 통해 MyRequest 전송; 신호 송수신이 끝나면 task 코드 실행
        let mySession = URLSession.shared
        let myTask = mySession.dataTask(with: myRequest){
            data, response, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            
            //네트워크 송수신 실패를 대비해 throw하기
            guard let data else
            {
                return
            }
            do{
                guard let myRoot = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        
                else { return }
                self.myDocuments = myRoot["documents"] as? [[String: Any]]
                
                //paginnation 활성화 여부 체크/업데이트하기
                if let meta = myRoot["meta"] as? [String: Any],
                   let isEnd = meta["is_end"] as? Bool{
                    
                    
                    //let isEnd = meta["is_end"] as? Bool {
                    DispatchQueue.main.async{
                        self.btnNext.isEnabled = !isEnd
                    }
                }
                
                //UI 변경하기 위해 Task를 메인큐로 보내기
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }catch{
                print("Json Parsing Error Occurred")
            }
        }
        myTask.resume()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // myDocuments가 없으면 0, 있으면 myDocuments Array의 갯수를 nil coalescing하기
        return myDocuments?.count ?? 0
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookListCell", for: indexPath)
        guard let book = myDocuments?[indexPath.row]
        else { return cell }
        let imgThumb = cell.viewWithTag(1) as? UIImageView
        
        let lblTitle = cell.viewWithTag(2) as? UILabel
        lblTitle?.text = book["title"] as? String
        
        let lblAuthors = cell.viewWithTag(3) as? UILabel
        let authors = book["authors"] as? [String]
        lblAuthors?.text = authors?.joined(separator: ", ")
        
        let lblPublisher = cell.viewWithTag(4) as? UILabel
        lblPublisher?.text = book["publisher"] as? String
        
        let lblPrice = cell.viewWithTag(5) as? UILabel
        lblPrice?.text = "\(book["price"] as? Int ?? 0)원"
        
        //썸네일 이미지의 경우 URL 형태로 저장돼있기 때문에 별도의 request 송신하기
        if let thumnail = book["thumbnail"] as? String{
            if let myUrl = URL(string: thumnail){
                let myRequst = URLRequest(url: myUrl)
                let myTask = URLSession.shared.dataTask(with: myRequst){
                    data, myRequst, error in
                    if let data{
                        DispatchQueue.main.async {
                            imgThumb?.image = UIImage(data: data)
                        }
                    }
                }
                myTask.resume()
            }
        }
        // Configure the cell...
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? BookDetailViewController
        guard let indexPath = tableView.indexPathForSelectedRow,
        let selectedBook = myDocuments?[indexPath.row]
        else { return  }
        detailVC?.strURL = selectedBook["url"] as? String
    }
    
    
    
    @IBAction func goToNext(_ sender: Any) {
        currentPage += 1
    }
    
    @IBAction func goToPrev(_ sender: Any) {
        currentPage -= 1
    }
    
    
}
  
extension BookListTableTableViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            currentPage = 1
        title = "'\(searchBar.text ?? "")' 도서검색 결과"
    
        searchBar.resignFirstResponder()
    }
}
    
    
    /*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */



//extension UISearchBarDelegate{
//    func searchBarClicked
//    
//}

