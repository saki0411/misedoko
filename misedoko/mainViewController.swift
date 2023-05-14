
import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore



class mainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hozonmapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var loginMailLabel: UILabel!
    
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
    let saveData: UserDefaults = UserDefaults.standard
    
    var misetitle = [String]()
    var misesubtitle = [String]()
    var documentid = [String]()
    
    var loginMailText = ""
    //firestoreのやつ
    let db = Firestore.firestore()
    var geoPoints =  [GeoPoint]()
    
    
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
        
        
        
        
        
        
        
        //collectionview長押しのやつ
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width / 4, height: view.bounds.size.width / 4)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.headerReferenceSize = CGSize(width:0,height:0)
        
        //ログアウト
        loginMailText = Auth.auth().currentUser?.email ?? "エラー"
        loginMailText += "さんでログイン中"
        loginMailLabel.text = loginMailText
        
        //データベースに保存
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        
        var annotations: [MKAnnotation] = []
        
        // 全てのドキュメントを取得する
        db.collection("hozoncollection").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 取得したドキュメントごとに実行する
                    let data = document.data()
                    let idokeido = data["idokeido"] as? GeoPoint
                    let title = data["title"] as? String ?? "title:Error"
                    let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                    let timestamp = data["timestamp"] as? Timestamp
                    self.misetitle.append(title)
                    self.misesubtitle.append(subtitle)
                    
                    let latitude = idokeido?.latitude
                    let longitude = idokeido?.longitude
                    let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotations.append(annotation)
                   
                    
                    self.documentid.append(document.documentID)
                    
                    self.hozonArray = annotations
                    
                    
                    for hozonroute in self.hozonArray {
                        
                        let sourcePlacemark = MKPlacemark(coordinate: self.mapView.userLocation.coordinate)
                        let destinationPlacemark = MKPlacemark(coordinate:hozonroute.coordinate)
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
                            if hozonroute.isEqual(self.hozonArray.last){
                                DispatchQueue.main.async {
                                    self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                                    self.collectionView.reloadData()
                                }
                                
                            }
                        }
                    }
                    
                }
                
            }
            
        }
        
        
      
    
     

 

       

      
        
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
        //      guard let annotation = view.annotation else {
        //          return
        //      }
        
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
        if pin?.pinImage != "blue.png"{
            let addButton = UIButton(type: .contactAdd)
            picPinView.rightCalloutAccessoryView = addButton
            
            
        }
      
        return picPinView
    }
    //吹き出しのボタン
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else {
            return
        }
        
        if hozonArray.contains(where: { $0.isEqual(annotation) }) {
            // hozonArrayにannotationが含まれる場合の処理
        } else {
            // hozonArrayにannotationが含まれない場合の処理
            //ボタン押したらarrayに追加するよ
            hozonArray.append(annotation)
            var ref: DocumentReference? = nil
             
                    let coordinate = annotation.coordinate
                    let geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    geoPoints.append(geoPoint)
                    
                    ref = db.collection("hozoncollection").addDocument(data: [
                        
                        "idokeido": geoPoint,
                        "title":   annotation.title!!,
                        "subtitle":annotation.subtitle!!,
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
           
            print(documentid)
            misetitle.append(annotation.title!!)
            misesubtitle.append(annotation.subtitle!!)
                
             
            
    
        

        }
        
        
        
        
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
        directions.calculate { [self] response, error in
            guard let response = response, let route = response.routes.first else {
                return
            }
            
            routes.append(route)
            
            
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
                        annotation1.title = mapItem.name
                        annotation1.subtitle = mapItem.placemark.title
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
        
        let route = routes[indexPath.row]
                    cell.shopnamelabel?.text = misetitle[indexPath.row]
                    cell.adresslabel?.text = misesubtitle[indexPath.row]
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
    
    
    //長押しのやつ
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            //ボタン
            let delete = UIAction(title: "DELETE", image: UIImage(systemName: "trash.fill")) { action in
                
                guard let itemToDelete = self.hozonArray[indexPath.item] as? MKAnnotation else {
                    return
                }
                if let indexToDelete = self.hozonArray.firstIndex(where: { $0 === itemToDelete }) {
                    self.db.collection("hozoncollection").document(self.documentid[indexPath.row]).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            self.collectionView.reloadData()
                        }
                    }
                    self.documentid.remove(at: indexPath.row)
                    self.mapView.removeAnnotation(itemToDelete)
                    self.hozonArray.remove(at: indexToDelete)
                    self.misetitle.remove(at: indexPath.row)
                    self.misesubtitle.remove(at: indexPath.row)
                    self.collectionView.reloadData()
                    
                }
            }
            
            return UIMenu(title: "Menu", children: [delete])
            
            
        }
        )
        
    }
    
    @IBAction func logout(){
        do{
            try Auth.auth().signOut()
            self .dismiss(animated: true, completion: nil)
        }catch let error as NSError {
            print(error)
        }
    }
    @IBAction func tebleview(){
        self.performSegue(withIdentifier: "totableview", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tostart" {
            let nextView = segue.destination as! tableviewViewController
            
            nextView.hozonArray = hozonArray
            
            
            
        }
        
        
        
    }
    
    
    
    
}




