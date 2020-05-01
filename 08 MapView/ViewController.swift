//
//  ViewController.swift
//  08 MapView
//
//  Created by Gukhwa Jeon on 30.04.20.
//  Copyright © 2020 G-Kay. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var myMap: MKMapView!
    @IBOutlet var lblLocationInfo1: UILabel!
    @IBOutlet var lblLocationInfo2: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager() // locationManager: CLLocationManager 클래스의 인스턴스
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblLocationInfo1.text = ""
        lblLocationInfo2.text = ""
        
        // show map
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 정확도 최고 설정
        locationManager.requestWhenInUseAuthorization() // 위치 데이터를 추적하기 위해 사용자에게 승인을 요구
        locationManager.startUpdatingLocation() // 사용자 현재위치 업데이트를 시작
        myMap.showsUserLocation = true // 위치보기 값을 true로 설정, 스위스 지도
    }

    // 위도와 경도로 위치 좌표(CLLocationCoordinate2D) 반환
    func setLocationCoordinate2D(latitudeValue: CLLocationDegrees,
                    longitudeValue: CLLocationDegrees) -> CLLocationCoordinate2D {
        let pLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeValue, longitudeValue) // CLLocationCoordinate2D: 구조체
        return pLocation
    }
    
    // 위치 좌표(CLLocationCoordinate2D)와 span값으로 원하는 위치 보여주기
    func setRegion(pLocation :CLLocationCoordinate2D,
                   delta span: Double) {
        let spanValue: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span) // MKCoordinateSpan: 구조체
        let pRegion: MKCoordinateRegion = MKCoordinateRegion(center: pLocation, span: spanValue) // MKCoordinateRegion: 구조체
        myMap.setRegion(pRegion, animated: true)
    }
    
    // 특정 위도와 경도에 빨간 핀 설치, 핀에 타이틀 서브타이틀 문자열 셋팅
    // (세그먼트 메뉴에서. 위도, 경도 및 정보는 그 안의 세그먼트 변경 함수에 저장. 그 함수에서 이 함수를 사용할 것임)
    func setAnnotation(latitudeValue: CLLocationDegrees,
                       longitudeValue: CLLocationDegrees,
                       delta span: Double,
                       title strTitle: String,
                       subtitle strSubtitle: String) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = setLocationCoordinate2D(latitudeValue: latitudeValue, longitudeValue: longitudeValue) // CLLocationCoordinate2D: 구조체
        setRegion(pLocation: annotation.coordinate, delta: span)
        annotation.title = strTitle // 빨간핀 아래 제목
        annotation.subtitle = strSubtitle // 빨간핀 아래 부제목 (빨간핀 클릭하면 보여줌)
        myMap.addAnnotation(annotation) // 빨간 핀 지도에 추가
    }
    
    //  CLLocationManagerDelegate 프로토콜의 함수
    // 위치가 업데이트 되었을 때 지도에 위치를 나타내기 위한 함수
    // 위치 정보에서 국가, 지역, 도로를 추출하여 레이블에 표시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation: CLLocation? = locations.last // 위치가 업데이트 되면 먼저 마지막 위치값을 찾아 상수에 저장
        let pLocation: CLLocationCoordinate2D? = lastLocation?.coordinate // 마지막 장소 좌표값
        setRegion(pLocation: pLocation!, delta: 0.01) // delta = 1 이 확대 없음. 0.01은 백배확대
        
        // 위도 경도로 위치정보 겟
        // typealias CLGeocodeCompletionHandler = ([CLPlacemark]?, Error?) -> Void
        // Class CLPlacemark : 장소정보 가지고 있음
        CLGeocoder().reverseGeocodeLocation(lastLocation!, completionHandler: {
            (placemarks, error) -> Void in
            let pm = placemarks!.first
            let country = pm!.country
            var address: String = country!
            if pm!.locality != nil { // pm상수에 지역값이 존재하면 address문자열에 추가
                address += " "
                address += pm!.locality!
            }
            if pm!.thoroughfare != nil { // pm상수에 도로값이 존재하면 address문자열에 추가
                address += " "
                address += pm!.thoroughfare!
            }
            
            self.lblLocationInfo1.text = "현재 위치"
            self.lblLocationInfo2.text = address
        })
        
        locationManager.stopUpdatingLocation() // 마지막으로 위치가 없데이트 되는 것을 멈추게 함
    }
    
    // 세그먼트 컨트롤을 선택하였을 때 호출
    @IBAction func sgChangeLocation(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.lblLocationInfo1.text = ""
            self.lblLocationInfo2.text = ""
            locationManager.startUpdatingLocation()
        } else if sender.selectedSegmentIndex == 1 {
            setAnnotation(latitudeValue: 46.711987, longitudeValue: 7.962519, delta: 1, title: "Iselwalt", subtitle: "Lake Brienz, Switzerland")
            self.lblLocationInfo1.text = "You are looking at: "
            self.lblLocationInfo2.text = "Iselwalt"
        } else if sender.selectedSegmentIndex == 2 {
            setAnnotation(latitudeValue: 46.718837, longitudeValue: 7.707390, delta: 1, title: "SigrisWil", subtitle: "Raftstrasse 31-33, 3655 Sigriswil")
            self.lblLocationInfo1.text = "You are looking at: "
            self.lblLocationInfo2.text = "SigrisWil"
        }
    }
}
