
import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import BackgroundTasks
import UserNotifications



class mainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UNUserNotificationCenterDelegate,UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate,UITabBarDelegate {
    
    
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hozonmapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var loginMailLabel: UILabel!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var tabMenuBar: UITabBar!
    
    var completer = MKLocalSearchCompleter()
    var completions = [MKLocalSearchCompletion]()
    var taptext = String()
    
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
    var selectedChoices2 = [String]()
    
    var nearbyAnnotations = [MKAnnotation]()
    var misetitle2 = [String]()
    var misesubtitle2 = [String]()
    
    var name = String()
    var commentArray = [String]()
    
    var choicecount = [Int]()
    var choicecount2 = [Int]()
    
    var distanceArray = [CLLocation]()
    
    
    var colorArray = [String]()
    
    var loginMailText = ""
    //firestoreのやつ
    let db = Firestore.firestore()
    var geoPoints =  [GeoPoint]()
    let uid = Auth.auth().currentUser?.uid
    
    
    var tableviewindexpath = Int()
    
    
    var teamId = String()
    var teammisetitle = [String]()
    var teammisesubtitle = [String]()
    var teamselectedChoices = [String]()
    var teamcolorArray = [String]()
    var teamdocumentid = [String]()
    var teamhozonArray = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // デリゲートを設定
        mapView.delegate = self
        hozonmapView.delegate = self
        locationManager.delegate = self
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource  = self
        tableView.dataSource = self
        tableView.delegate = self
        completer.delegate = self
        
        
        // 現在地取得の許可をとってるよ！
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //      homeButton.isEnabled = false
        
        
        
        
        //collectionview長押しのやつ
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width / 4, height: view.bounds.size.width / 4)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.headerReferenceSize = CGSize(width:0,height:0)
        
        
        
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.current,
            hour: 12,
            minute: 30,
            weekday: 2
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let content = UNMutableNotificationContent()
        content.body = "テストメッセージ"
        content.badge = 1
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        
        
        tableView.isHidden = true
        
        
        //データベースに保存
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        
        var annotations: [MKAnnotation] = []
        
        zyanrukakuninn()
        getname()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            
            self.zyanrusyutoku()
            
            //ログアウト
            
        
         
            
            print("All Process Done!")
            
            
        }
        
       getteam()
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.teamsyutoku()
        }
        
        let collectionRef = db.collection("users").document(uid ?? "").collection("shop")
        
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
                self.db.collection("users").document(self.uid ?? "").collection("shop").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            // 取得したドキュメントごとに実行する
                            let data = document.data()
                            let idokeido = data["idokeido"] as? GeoPoint
                            let title = data["title"] as? String ?? "title:Error"
                            let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                            
                            let genre = data["genre"] as? String ?? "カフェ"
                            let color = data["color"] as? String ?? "pink"
                            let comment = data["comment"] as? String ?? ""
                            
                            let latitude = idokeido?.latitude
                            let longitude = idokeido?.longitude
                            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            annotations.append(annotation)
                            
                            
                            
                            
                            self.commentArray.append(comment)
                            
                            self.hozonArray = annotations
                            self.selectedChoices.append(genre)
                            self.documentid.append(document.documentID)
                            
                            
                            self.colorArray.append(color)
                            
                            self.misetitle.append(title)
                            self.misesubtitle.append(subtitle)
                            
                            
                            let genzaiti = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude,longitude: self.mapView.userLocation.coordinate.longitude)
                            
                            
                            // annotationのCLLocationCoordinate2DをCLLocationに変換する
                            let annotationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            
                            // 現在地とannotationの距離を計算する
                            let distance = genzaiti.distance(from: annotationLocation)
                            self.distanceArray.append(annotationLocation)
                            
                            
                            // 距離が1000m以下なら、nearbyAnnotationsに追加する
                            if distance <= 1000 {
                                
                                
                                self.nearbyAnnotations.append(annotation)
                                self.selectedChoices2.append(genre)
                                self.misetitle2.append(title)
                                self.misesubtitle2.append(subtitle)
                            }
                        }
                        
                    }
                    
                    if !self.nearbyAnnotations.isEmpty{
                        
                        
                        
                        for hozonroute in self.nearbyAnnotations {
                            
                            
                            
                            
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
                                
                                
                                
                                
                                if hozonroute.isEqual(self.nearbyAnnotations.last){
                                    
                                    
                                    
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
                                        for (index, teamhozon) in self.teamhozonArray.enumerated(){
                                            let annotation2 = coloranotation()
                                            annotation2.coordinate = teamhozon.coordinate
                                            annotation2.title = self.teammisetitle[index]
                                            annotation2.subtitle = self.teammisesubtitle[index]
                                            annotation2.pinImage = "yellow.png"
                                            self.mapView.addAnnotation(annotation2)
                                        }
                                    
                                        
                                        print("全部終わったよ")
                                        
                                     
                                            self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                                            self.collectionView.reloadData()
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }else{
                        
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
                
            } else {
                // コレクションが存在しないかドキュメントが存在しない場合の処理
                print("コレクションがないよ")
                
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
            
            ref = db.collection("users").document(uid ?? "").collection("shop").addDocument(data: [
                
                "idokeido": geoPoint,
                "title":   annotation.title!!,
                "subtitle":annotation.subtitle!!,
                "timestamp": FieldValue.serverTimestamp(),
                "genre":"カフェ",
                "kyouyu": false,
                "color": "pink"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.documentid.append(ref!.documentID)
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            
            colorArray.append("pink")
            misetitle.append(annotation.title!!)
            misesubtitle.append(annotation.subtitle!!)
            
            let genzaiti = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude,longitude: self.mapView.userLocation.coordinate.longitude)
            
            
            
            
            
            let latitude = geoPoint.latitude
            let longitude = geoPoint.longitude
            let coordinate2 = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // annotationのCLLocationCoordinate2DをCLLocationに変換する
            let annotationLocation = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
            
            // 現在地とannotationの距離を計算する
            let distance = genzaiti.distance(from: annotationLocation)
            
            
            // 距離が1000m以下なら、nearbyAnnotationsに追加する
            if distance <= 1000 {
                self.selectedChoices2.append("カフェ")
                self.nearbyAnnotations.append(annotation)
                self.misetitle2.append((annotation.title ?? "") ?? "")
                self.misesubtitle2.append((annotation.subtitle ?? "") ?? "")
            }
            
            
            
            db.collection("users").document(uid ?? "").collection("shop").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let genre = data["genre"] as? String ?? "カフェ"
                        
                        self.selectedChoices.append(genre)
                        
                        
                        self.documentid.append(document.documentID)
                        
                        
                    }
                }
            }
            
            
            
            
            
            
            
            
            
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
                
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // 2-2. セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return nearbyAnnotations.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        if  zyanru.first != nil{
            
        }else{
            zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
            
        }
        
        cell.documentid = documentid
        
        
        
        choicecount2 = []
        for choice in selectedChoices2 {
            choicecount2.append(zyanru.firstIndex(of: choice) ?? 2)
            
        }
        
        cell.commentButton.isHidden = true
        
        cell.pickerView.isHidden = true
        
        cell.URLtextfield.isHidden = true
        cell.URLbutton.isHidden = true
        
        
        
        cell.zyanruTextField.isUserInteractionEnabled = false
        let initialRow = choicecount2[indexPath.row]
        cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false)
        cell.zyanruTextField.text = zyanru[initialRow]
        
        
        
        cell.indexPath = indexPath // インデックスパスを渡す
        
        
        if routes.count == misetitle2.count{
            let route = routes[indexPath.row]
            cell.shopnamelabel?.text = misetitle2[indexPath.row]
            cell.adresslabel?.text = misesubtitle2[indexPath.row]
            cell.timelabel?.text = "\(round(route.expectedTravelTime / 60)) 分"
            
            
        }else{
            cell.shopnamelabel?.text = misetitle2[indexPath.row]
            cell.adresslabel?.text = misesubtitle2[indexPath.row]
        }
        
        
        
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
    
    
    
    
    
    @IBAction func logout(){
        do{
            try Auth.auth().signOut()
            
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "login")
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: true, completion: nil)
            
            
            
            
        }catch let error as NSError {
            print(error)
        }
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            tableView.isHidden = true
            
        }else{
            
            
            
            // 入力された文字列を補完検索用のインスタンスに渡す
            completer.queryFragment = searchText
            tableView.isHidden = false
        }
    }
    
    // 補完検索用のインスタンスが候補を更新したときに呼ばれるメソッド
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        // 候補の配列を取得する
        completions = completer.results
        
        // テーブルビューを更新する
        tableView.reloadData()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // テーブルビューのセル数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if completions.first != nil{
            let title = completions[indexPath.row].title
            let subtitle = completions[indexPath.row].subtitle
            
            
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = subtitle
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableviewindexpath = indexPath.row
        taptext = completions[indexPath.row].title
        kensaku()
        
        
        
        
    }
    
    
    
    
    func kensaku(){
        
        self.searchBar.resignFirstResponder()
        self.mapView.removeAnnotations(self.kensakukekkaArray)
        
        self.kensakukekkaArray.removeAll()
        
        
        
        guard let searchText = self.searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = taptext
        
        // 現在地の緯度経度を取得
        if let currentLocation = self.currentLocation {
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
                print(response.mapItems)
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
            
            
            
            
            
            
            
            
            
            
            let annotation = self.kensakukekkaArray[0]
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.tableView.isHidden = true
            
            
        }
        
        
        
    }
    
    @IBAction func genzaiti(){
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 0:
            print("1") // カレンダーアイコンをタップした場合
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "list")
            nextView.modalPresentationStyle = .fullScreen
            present(nextView, animated: true, completion: nil)
            
        case 1:
            print("2") // 設定アイコンをタップした場合
            
            
        case 2:
            print("3") // 設定アイコンをタップした場合
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "friend")
            nextView.modalPresentationStyle = .fullScreen
            present(nextView, animated: true, completion: nil)
            
        default : return
            
        }
        
    }
    func zyanrusyutoku(){
        
        
        
        if self.zyanru.first == nil{
            print("naiyo")
            self.zyanru.append("カフェ")
            self.zyanru.append("レストラン")
            self.zyanru.append("食べ放題")
            self.zyanru.append("持ち帰り")
            self.zyanru.append("レストラン")
            self.db.collection("users").document(self.uid ?? "").collection("zyanru").document("list").setData([
                "zyanrulist": self.zyanru
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    
                }
            }
            
            
            
            
            
            
        }
        print("これだ！",zyanru)
    }
    
    
    func zyanrukakuninn(){
        zyanru = []
        self.db.collection("users").document(self.uid ?? "").collection("zyanru").document("list").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let zyanrulist = data?["zyanrulist"] as! Array<Any>
                for string in zyanrulist {
                    self.zyanru.append(string as! String)
                    print("これだよ！",self.zyanru)
                }
            }else {
                print("Document does not exist")
            }
            
            
        }
        
        
        
    }
    func getname(){
        let docRef = db.collection("users").document(uid ?? "").collection("personal").document("info")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name2 = data?["name"] as? String ?? "Name:Error"
                self.name = name2
                print("Success! Name:\(self.name)")
                print(self.name)
                self.loginMailText = self.name
                self.loginMailText += "さんでログイン中"
                self.loginMailLabel.text = self.loginMailText
            } else {
                print("Document does not exist")
            }
            
        }
    }
    func getteam(){
        print(uid)
        db.collection("users").document(uid ?? "").collection("personal").document("info").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let team = data?["teams"] as? String ?? "team:Error"
                print(data?["teams"] as Any)
                self.teamId = team
                print("aaaaa")
                self.teamsyutoku()
            } else {
                print("Document does not exist")
            }
            print("ほほほ")
        }
        
      
    }
    
    
    func teamsyutoku(){
        teamselectedChoices = []
        teammisetitle = []
        teammisesubtitle = []
        teamcolorArray = []
        teamdocumentid = []
        teamhozonArray = []
        
        print(teamId,"uuu")
        
        let collectionRef = db.collection("teams").document(teamId).collection("shops")
        
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
                self.db.collection("teams").document(self.teamId).collection("shops").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            // 取得したドキュメントごとに実行する
                            let data = document.data()
                            let idokeido = data["idokeido"] as? GeoPoint
                            let genre = data["genre"] as? String ?? "カフェ"
                            let color = data["color"] as? String ?? "pink"
                            let comment = data["comment"] as? String ?? ""
                            let URL = data["URL"] as? String ?? ""
                            let title = data["title"] as? String ?? "title:Error"
                            let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                            
                            
                            self.teamselectedChoices.append(genre)
                            self.teamcolorArray.append(color)
                            self.teammisetitle.append(title)
                            self.teammisesubtitle.append(subtitle)
                            self.teamdocumentid.append(document.documentID)
                            
                            
                            
                            let latitude = idokeido?.latitude
                            let longitude = idokeido?.longitude
                            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            self.teamhozonArray.append(annotation)
                            
                            
                            
                            
                            
                            
                            
                        }
                        self.choicecount  = []
                        for choice in self.selectedChoices {
                            self.choicecount.append(self.zyanru.firstIndex(of: choice) ?? 2)
                            
                        }
                        
                        
                        
                        
                        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
                        self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                        self.collectionView.reloadData()
                        
                    }
                    
                    
                }
            }else {
                // コレクションが存在しないかドキュメントが存在しない場合の処理
                print("Collection does not exist or is emptyコレクションがないよ")
                self.collectionView.delegate = self
                self.collectionView.dataSource  = self
                
                let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
                
                self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                self.collectionView.reloadData()
            }
            
        }
        
    }
}
    
    

