//
//  LocationManager.swift
//  SimulationApp
//
//  Created by Darvin Evidor on 5/7/24.
//

import CoreLocation

class AppViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var speedInMPerSeconds = 0.0
    @Published var speedInKmPerHour = 0.0
    @Published var isLocationServicesEnabled = false
    
    // Timer
    @Published private var elapsedTime: TimeInterval = 0
    @Published private var timer: Timer?
    @Published var duration = "00:00:00"
    @Published var isRunning = false
    
    // Distance
    private var previousLocation: CLLocation?
    @Published var totalDistanceInMeters: Double = 0.0
    @Published var totalDistanceInKilometers: Double = 0.0
    
    // Alert
    @Published var showingAlert = false
    
    // Time
    @Published var time = "00:00"
    
    // Display toggle
    @Published var isDistanceInKm = true
    @Published var isSpeedInM = true
    
    // Speed limit text field
    @Published var speedLimit = "80"
    
    // Popover toggle
    @Published var isDurationPopoverPresented = false
    @Published var isDistancePopoverPresented = false
    @Published var isSpeedLimitPopoverPresented = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.checkLocationServices()
        self.resetValues()
        self.locationManager.distanceFilter = 20
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func processLocation(_ current: CLLocation) {
        if let previousLocation = previousLocation {
            let distance = current.distance(from: previousLocation)
            totalDistanceInMeters += distance
            
            self.totalDistanceInKilometers = totalDistanceInMeters / 1000
        }
        previousLocation = current
        
        let currentSpeed = current.speed
        if !currentSpeed.isInfinite && !currentSpeed.isNaN {
            speedInMPerSeconds = currentSpeed > 0 ? currentSpeed : 0.0
            speedInKmPerHour = speedInMPerSeconds * 3.6 > 0.0 ? speedInMPerSeconds * 3.6 : 0.0
        } else {
            speedInMPerSeconds = 0.0
            speedInKmPerHour = 0
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            processLocation(location)
        }
        
        checkLocationServices()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    DispatchQueue.main.async {
                        self.isLocationServicesEnabled = false
                    }
                case .authorizedAlways, .authorizedWhenInUse:
                    DispatchQueue.main.async {
                        self.isLocationServicesEnabled = true
                    }
                @unknown default:
                    break
                }
            } else {
                print("Location services are not enabled")
            }
        }
    }
    
    func startTimer() {
        if !isLocationServicesEnabled {
            self.showingAlert = true
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.elapsedTime += 1
                
                self.duration = self.timeString(time: self.elapsedTime)
            }
            self.isRunning = true
            self.resetValues()
            self.locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        self.elapsedTime = 0
        self.isRunning = false
        self.locationManager.stopUpdatingLocation()
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func getCurrentTime() -> String {
        let currentTime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter.string(from: currentTime)
    }
    
    func resetValues() {
        speedInMPerSeconds = 0.0
        speedInKmPerHour = 0.0
        duration = "00:00:00"
        totalDistanceInMeters = 0.0
        totalDistanceInKilometers = 0.0
    }
}
