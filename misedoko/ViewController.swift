import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
   
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var tappedLocation: String?
    var tappedCoordinate: CLLocationCoordinate2D?
    
    
    // 検索バーのIBAction
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    // 検索バーのデリゲートメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 検索バーのテキストを取得
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        // MKLocalSearchを使用して場所を検索
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            if let response = response, let item = response.mapItems.first {
                // 検索結果の最初の場所を取得
                self?.centerMapOnLocation(location: item.placemark.location)
                self?.addCustomPinToMap(location: item.placemark.location, title: searchBar.text)
                self?.tappedLocation = searchBar.text
                self?.tappedCoordinate = item.placemark.coordinate
                self?.tableView.reloadData()
            }
            searchBar.resignFirstResponder()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    // 地図をセンタリングするメソッド
    func centerMapOnLocation(location: CLLocation?) {
        guard let location = location else {
            return
        }
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0,
                                                  longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // 地図にカスタムピンを追加するメソッド
    func addCustomPinToMap(location: CLLocation?, title: String?) {
        guard let location = location, let title = title else {
            return
        }
        let annotation = MKPointAnnotation()
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? MKPointAnnotation {
                let title = annotation.title ?? ""
                let subtitle = annotation.subtitle ?? ""
                let pinInfo = "Title: \(title), Subtitle: \(subtitle)"
                
                // ピン情報をリストに追加
                tappedLocation = title
                tappedCoordinate = annotation.coordinate
                tableView.reloadData() // テーブルビューを更新
            }
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tappedLocation != nil ? 1 : 0 // セルの数は1とする
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = tappedLocation // ピンをタップした場所の名前を表示する
            return cell
        }
        
