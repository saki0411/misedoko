
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
    var zyanru = [String]()
    var savedata: UserDefaults = UserDefaults.standard
    
    var searchResults: [MKMapItem] = []
    var selectedPin: MKAnnotation?
    var routes: [MKRoute] = []
    
    var misetitle = [String]()
    var misesubtitle = [String]()
    
    var documentid = [String]()
    var selectedChoice: String = ""
    var selectedChoices = [String]()
    
    var nearbyAnnotations = [MKAnnotation]()
    var misetitle2 = [String]()
    var misesubtitle2 = [String]()
    //var genres: [String] = []
    var genres: [(genre: String, documentID: String)] = []
    var choicecount = [Int]()
    
    var loginMailText = ""
    //firestoreのやつ
    let db = Firestore.firestore()
    var geoPoints =  [GeoPoint]()
    let uid = Auth.auth().currentUser?.uid
    
    //多次元配列、位置情報とジャンルを入れたい
    var hozondic = [[String]]()
    
    
    
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
        
        
        //ジャンル保存取り出すよ
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }
        
        
        
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
        let collectionRef = db.collection(uid ?? "hozoncollection")
        
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                // エラーが発生した場合の処理
                print("Error fetching documents: \(error)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                // コレクションにドキュメントが存在する場合の処理
                print("Collection exists and contains documents")
                // 全てのドキュメントを取得する
                self.db.collection(self.uid ?? "hozoncollection").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            // 取得したドキュメントごとに実行する
                            let data = document.data()
                            let idokeido = data["idokeido"] as? GeoPoint
                            let title = data["title"] as? String ?? "title:Error"
                            let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                            
                            let genre = document.data()["genre"] as? String ?? "カフェ"
                            
                            self.selectedChoices.append(genre)
                            print(self.selectedChoices,"choicesだよ！")
                            self.documentid.append(document.documentID)
                            
                            
                            
                            
                            self.misetitle.append(title)
                            self.misesubtitle.append(subtitle)
                            
                            let latitude = idokeido?.latitude
                            let longitude = idokeido?.longitude
                            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            annotations.append(annotation)
                            
                            
                            
                            
                            
                            
                            self.hozonArray = annotations
                            
                            
                            let genzaiti = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude,longitude: self.mapView.userLocation.coordinate.longitude)
                            
                            
                            // annotationのCLLocationCoordinate2DをCLLocationに変換する
                            let annotationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            
                            // 現在地とannotationの距離を計算する
                            let distance = genzaiti.distance(from: annotationLocation)
                            
                            // 距離が1000m以下なら、nearbyAnnotationsに追加する
                            if distance <= 1000 {
                                self.nearbyAnnotations.append(annotation)
                                self.misetitle2.append(title)
                                self.misesubtitle2.append(subtitle)
                            }
                        }
                        
                    }
                    
                    
                    
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
                                    //最初からピンを立てたいよ
                                    for (index, hozon) in self.hozonArray.enumerated() {
                                        let  annotation1 = coloranotation()
                                        annotation1.coordinate = hozon.coordinate
                                        annotation1.title = self.misetitle[index]
                                        annotation1.subtitle = self.misesubtitle[index]
                                        annotation1.pinImage = "blue.png"
                                        self.mapView.addAnnotation(annotation1)
                                        
                                    }
                                    
                                  
                                    
                                    
                                    print("全部終わったよ")
                                    
                                    
                                    self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                                    self.collectionView.reloadData()
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            } else {
                // コレクションが存在しないかドキュメントが存在しない場合の処理
                print("Collection does not exist or is emptyコレクションがないよ")
                self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                self.collectionView.reloadData()
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
            
            ref = db.collection(uid ?? "hozoncollection").addDocument(data: [
                
                "idokeido": geoPoint,
                "title":   annotation.title!!,
                "subtitle":annotation.subtitle!!,
                "timestamp": FieldValue.serverTimestamp(),
                "genre":"カフェ"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.documentid.append(ref!.documentID)
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
            
            let genzaiti = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude,longitude: self.mapView.userLocation.coordinate.longitude)
            
            let coordinate = annotation.coordinate
            let geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let latitude = geoPoint.latitude
            let longitude = geoPoint.longitude
            let coordinate2 = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // annotationのCLLocationCoordinate2DをCLLocationに変換する
            let annotationLocation = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
            
            // 現在地とannotationの距離を計算する
            let distance = genzaiti.distance(from: annotationLocation)
            
            // 距離が1000m以下なら、nearbyAnnotationsに追加する
            if distance <= 1000 {
                self.nearbyAnnotations.append(annotation)
                self.misetitle2.append((annotation.title ?? "") ?? "")
                self.misesubtitle2.append((annotation.subtitle ?? "") ?? "")
            }
            
            
            
            
            
            
            
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
                    
                }
                
                
                
                
                DispatchQueue.main.async {
                    print("aaaaaaaaa")
                    
                    self.collectionView.reloadData()
                }
            }
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
                    for (index, hozon) in self.hozonArray.enumerated() {
                        let  annotation1 = coloranotation()
                        annotation1.coordinate = hozon.coordinate
                        annotation1.title = self.misetitle[index]
                        annotation1.subtitle = self.misesubtitle[index]
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
        
        return hozonArray.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }else{
            zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
            
        }
        
        cell.documentid = documentid
        
        cell.genres = genres
      //  cell.selectedChoices = selectedChoices
        choicecount = []
        for choice in selectedChoices {
            choicecount.append(zyanru.firstIndex(of: choice) ?? 2)
            
        }
        print("collection",selectedChoices)
        
        let initialRow = choicecount[indexPath.row] // インデックスをintArrayの要素で取得
        cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false) // ピッカービューの初期値を設定
        cell.zyanruTextField.text = zyanru[initialRow] // テキストフィールドの初期値を設定
        
        
        cell.indexPath = indexPath // インデックスパスを渡す
        
        print(routes)
        let route = routes[indexPath.row]
        cell.shopnamelabel?.text = misetitle[indexPath.row]
        cell.adresslabel?.text = misesubtitle[indexPath.row]
        cell.timelabel?.text = "\(round(route.expectedTravelTime / 60)) 分"
        
        
        
        
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
                    self.db.collection(self.uid ?? "hozoncollection").document(self.documentid[indexPath.row]).delete() { err in
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
        
        if segue.identifier == "tocollectionview2" {
            let nextView = segue.destination as! colectionviewViewController
            
            
            nextView.hozonArray = hozonArray
            nextView.routes = routes
            nextView.misetitle = misetitle
            nextView.misesubtitle = misesubtitle
            nextView.documentid = documentid
            nextView.zyanru = zyanru
            nextView.genres = genres
            db.collection(self.uid ?? "hozoncollection").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.selectedChoices = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let genre = document.data()["genre"] as? String ?? "カフェ"
                        
                        self.selectedChoices.append(genre)
                        print(self.selectedChoices,"choicesだよ！")
                     
                        self.documentid.append(document.documentID)
                        
                    }
                    
                }
            }
            
          
         choicecount  = []
            for choice in selectedChoices {
                self.choicecount.append(zyanru.firstIndex(of: choice) ?? 2)
                
            }
            nextView.selectedChoices = selectedChoices
            nextView.choicecount = choicecount
            print(choicecount,"a")
            
        }
        
        
        
    }
    
    
}




