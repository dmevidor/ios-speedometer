//
//  ContentView.swift
//  SimulationApp
//
//  Created by Darvin Evidor on 5/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AppViewModel()
    
    // MARK: Colors
    let mainBackgroundColor = #colorLiteral(red: 0.2366494669, green: 0.2366494669, blue: 0.2366494669, alpha: 1)
    let backgroundColor = Gradient(colors: [Color(#colorLiteral(red: 0.2078254006, green: 0.2078254006, blue: 0.2078254006, alpha: 1)), Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))])
    let neonGreenColor = #colorLiteral(red: 0.7490196078, green: 1, blue: 0.2980392157, alpha: 1)
    
    @Environment(\.scenePhase) var scenePhase
    
    //Display Toggle
    @AppStorage("isDistanceInKm") var isDistanceInKm = true
    @AppStorage("isSpeedInM") var isSpeedInM = true
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: backgroundColor, startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea()
            
            HStack {
                // MARK: Speed view
                VStack (alignment: .leading) {
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.white)
                        
                        Text(viewModel.time)
                            .foregroundStyle(.white)
                            .onAppear {
                                let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    viewModel.time = viewModel.getCurrentTime()
                                }
                                timer.fire()
                            }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack(alignment: .bottomTrailing) {
                        
                        Text(String(format: "%.2f", viewModel.isSpeedInM ? viewModel.speedInMPerSeconds : viewModel.speedInKmPerHour))
                            .font(.custom("DS-Digital-Bold", size: 200))
                            .foregroundStyle(Color(neonGreenColor))
                            .onTapGesture {
                                viewModel.isSpeedInM.toggle()
                                self.isSpeedInM = viewModel.isSpeedInM
                            }
                        
                        Text(viewModel.isSpeedInM ? "m/s" : "km/h")
                            .foregroundStyle(.white)
                            .font(.title)
                            .padding(.top, 20)
                            .padding(.trailing, 10)
                    }
                    
                    Spacer()
                }
                
                VStack {
                    // MARK: GPS Image and Text
                    HStack () {
                        Spacer()
                        
                        Group {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(viewModel.isLocationServicesEnabled ? .green : .red)
                            
                            Text("GPS")
                                .foregroundStyle(.white)
                        }
                        .onTapGesture {
                            // Open app setting to enable access to location
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }
                    }
                    
                    // MARK: Duration and time
                    HStack {
                        GroupBox() {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("Duration")
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            self.viewModel.isDurationPopoverPresented.toggle()
                                        }
                                }
                                
                                Text(viewModel.duration)
                                    .font(.largeTitle)
                                    .foregroundStyle(Color(neonGreenColor))
                                    .popover(isPresented: $viewModel.isDurationPopoverPresented) {
                                        Text("The length of time passed since you start driving.")
                                            .presentationCompactAdaptation((.popover))
                                    }
                            }
                            .frame(width: 380)
                        }
                        .backgroundStyle(Color(mainBackgroundColor))
                    }
                    
                    HStack {
                        // MARK: Distance
                        GroupBox() {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("Distance")
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            self.viewModel.isDistancePopoverPresented.toggle()
                                        }
                                }
                                
                                Text(String(format: "%.1f", viewModel.isDistanceInKm ? viewModel.totalDistanceInKilometers : viewModel.totalDistanceInMeters))
                                    .font(.system(size: 60))
                                    .foregroundStyle(Color(neonGreenColor))
                                    .popover(isPresented: $viewModel.isDistancePopoverPresented) {
                                        Text("The measurement of how far you drove your vehicle.")
                                            .presentationCompactAdaptation((.popover))
                                    }
                                
                                Text(viewModel.isDistanceInKm ? "km" : "m")
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 170)
                        }
                        .backgroundStyle(Color(mainBackgroundColor))
                        .onTapGesture {
                            viewModel.isDistanceInKm.toggle()
                            self.isDistanceInKm = viewModel.isDistanceInKm
                        }
                        
                        // MARK: Speed Limit
                        GroupBox() {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("Speed Limit")
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            self.viewModel.isSpeedLimitPopoverPresented.toggle()
                                        }
                                }
                                
                                TextField("80", text: $viewModel.speedLimit)
                                    .font(.system(size: 60))
                                    .foregroundStyle(viewModel.totalDistanceInKilometers > Double(viewModel.speedLimit) ?? 0.0 ? .white : Color(neonGreenColor))
                                    .multilineTextAlignment(.center)
                                    .popover(isPresented: $viewModel.isSpeedLimitPopoverPresented) {
                                        Text("It refers to the maximum speed allowed by law for vehicles on the road. \n The speed limit can be customized.")
                                            .presentationCompactAdaptation((.popover))
                                    }
                                
                                Text("km/h")
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 170, height: 110)
                        }
                        .backgroundStyle(viewModel.totalDistanceInKilometers > Double(viewModel.speedLimit) ?? 0.0 ? Color.red : Color(mainBackgroundColor))
                    }
                    
                    HStack {
                        Button(action: {
                            if(viewModel.isRunning) {
                                viewModel.stopTimer()
                            } else {
                                viewModel.startTimer()
                            }
                        }, label: {
                            HStack {
                                Image(systemName: viewModel.isRunning ? "stop.fill" : "play.fill")
                                Text(viewModel.isRunning ? "STOP" : "START")
                            }
                            .frame(width: 162)
                            
                        })
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .tint(Color(neonGreenColor))
                        .foregroundColor(.black)
                        
                        Button(action: {
                            if(!viewModel.isRunning) {
                                viewModel.resetValues()
                            }
                        }, label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("RESET")
                                .frame(width: 140)
                        })
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .tint(Color(neonGreenColor))
                        .foregroundColor(.black)
                    }
                }
                .padding(.leading, 20)
            }
        }
        .alert("Location services are not enabled.", isPresented: $viewModel.showingAlert) {
            Button("OK") {
                viewModel.showingAlert = false
            }
            Button("Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                viewModel.showingAlert = false
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.checkLocationServices()
            }
        }
        .onAppear {
            // Reload user defaults when opening the app again
            viewModel.isDistanceInKm = self.isDistanceInKm
            viewModel.isSpeedInM = self.isSpeedInM
        }
    }
}

#Preview {
    ContentView()
}
