// swift-tools-version:5.7.1
import UIKit
import MapKit
import CoreLocation


class mainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hozonmapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var onceOnly = true
    var kensakukekkaArray:[MKAnnotation] = []
    var hozonArray = [MKAnnotation]()
    
    
    var hozonString = String()
    var addresses = [String]()
    var hozonaddress = [String]()
    var travelTimeArray = [TimeInterval]()
    var stringtimeArray = [String]()
    var hozontimeArray = [String]()
    var searchResults: [MKMapItem] = []
    var selectedPin: MKAnnotation?
    var routes: [MKRoute] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // デリゲートを設定
        mapView.delegate = self
        hozonmapView.delegate = self
        locationManager.delegate = self
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource  = self
        
        // 現在地取得の許可をとってるよ！
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        
        
        
        
    }
    
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {//現在地が更新された時
        guard let location = locations.last else {
            return
        }
        
        mapView.showsUserLocation = true
        
        
        if onceOnly{
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            onceOnly = false
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        
     //   hozonArray.append(annotation)
        
       
    }
    
    
    // 選択されたピンの情報を保存するよ
    
    
    
    
    
    //ピンの設定をしてるよ！
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = annotation as? coloranotation
        //     let PinView = MKMarkerAnnotationView()
        let picPinView = MKAnnotationView()
        if annotation is MKUserLocation {
            return nil
        }
        //   PinView.markerTintColor = pin?.pinColor
        
        picPinView.image = UIImage(named:(pin?.pinImage)!)
        picPinView.canShowCallout = true
        let addButton = UIButton(type: .contactAdd)
        picPinView.rightCalloutAccessoryView = addButton
        
        
        return picPinView
    }
    //吹き出しのボタン
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else {
                return
            }
        //ボタン押したらarrayに追加するよ
        hozonArray.append(annotation)
        
        //所要時間を計算するよ
        let sourcePlacemark = MKPlacemark(coordinate: mapView.userLocation.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: annotation.coordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            guard let response = response, let route = response.routes.first else {
                return
            }
            
            self.routes.append(route)
            
            self.collectionView.reloadData()
            
        }
           
        }
    
    
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.mapView.removeAnnotations(self.kensakukekkaArray)
        
        self.kensakukekkaArray.removeAll()
        
        searchBar.resignFirstResponder()
        
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        // 現在地の緯度経度を取得
        if let currentLocation = currentLocation {
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 1000)
            searchRequest.region = region
        }
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let response = response {
                if response.mapItems.isEmpty {
                    print("検索結果はありませんでした。")
                    return
                }
                
                for mapItem in response.mapItems {
                    
                    
                    //こっちは普通のピンの設定
                    let annotation = coloranotation()
                   
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    annotation.subtitle = mapItem.placemark.title
                    annotation.pinImage = "pink.png"
                    
                    
                    
                    self.searchResults.append(mapItem)
                    self.kensakukekkaArray.append(annotation)
                    
                    self.collectionView.reloadData()
                    
                    
                    
                    //hozonarrayを取り出して保存用のピンを指してるよ！
                    for hozon in self.hozonArray {
                        let  annotation1 = coloranotation()
                        annotation1.coordinate = hozon.coordinate
                        annotation1.pinImage = "blue.png"
                        self.mapView.addAnnotation(annotation1)
                        
                        
                        
                        
                    }
                    //検索結果のピンを指してるよ！
                    self.mapView.addAnnotations(self.kensakukekkaArray)
                    
                    
                    
                    
                    
                    if let firstMapItem = response.mapItems.first {
                        let region = MKCoordinateRegion(center: firstMapItem.placemark.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        self.mapView.setRegion(region, animated: true)
                    }
                }
            }
            
            
            
            
            
            
            
            
        }
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // 2-2. セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(hozonArray.count)
        return hozonArray.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let pin = hozonArray[indexPath.row]
        let route = routes[indexPath.row]
        cell.shopnamelabel?.text = pin.title ?? ""
        cell.adresslabel?.text = pin.subtitle ?? ""
        cell.timelabel.text = "\(round(route.expectedTravelTime / 60)) 分"
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSizeWidth:CGFloat = 350
        let cellSizeHeight:CGFloat = 300
        
        
        // widthとheightのサイズを返す
        return CGSize(width: cellSizeWidth, height: cellSizeHeight/2)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0 // 行間
    }
    
    
    
    
}




