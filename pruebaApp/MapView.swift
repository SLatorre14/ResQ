//
//  MapView.swift
//  pruebaApp
//
//  Created by IMAC on 21/03/24.
//

import SwiftUI
import MapKit



struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}



struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    
    let annotations = [
        MapAnnotationItem(coordinate: CLLocationCoordinate2D(latitude: 4.6018, longitude: -74.0661), title: "ML"),
        MapAnnotationItem(coordinate: CLLocationCoordinate2D(latitude: 4.604400872503055, longitude: -74.0659650900807), title: "SD")
        
    ]
    
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: annotations) { annotation in
            MapPin(coordinate: annotation.coordinate, tint: .blue)
            
        }
            .edgesIgnoringSafeArea(.all)
            .onAppear{
                viewModel.checkIfLocationServicesIsEnabled()
            }
        
    }
        
    
}
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 4.6018, longitude: -74.0661),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.delegate = self
        } else{
            print("Location services unabled")
        }
    }
   
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location Restricted")
        case .denied:
            print("Location Permission Denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span:MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        checkLocationAuthorization()
    }
}
