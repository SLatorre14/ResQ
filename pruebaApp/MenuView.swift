//
//  ContentView.swift
//  test
//
//  Created by Juan Sebastian Ibañez Capacho on 7/03/24.
//

import SwiftUI
import CoreMotion

@MainActor

final class CarrusselViewModel: ObservableObject{
    @Published var news = [Card]()
    @Published var errorMessage = ""
    private let cacheExpirationInterval: TimeInterval = 1200
    private let cacheKey = "cachedNews"
    
    
    init() {
        fetchNewsIfNeeded()
       }
       
    
    private func fetchNewsIfNeeded() {
        let cachedNewsData = UserDefaults.standard.data(forKey: cacheKey)
        let cachedDate = UserDefaults.standard.object(forKey: cacheKey + "_timestamp") as? Date
      
        if let cachedNewsData = cachedNewsData,
           let cachedNews = try? JSONDecoder().decode([Card].self, from: cachedNewsData),
           let cachedDate = cachedDate,
           Date().timeIntervalSince(cachedDate) < cacheExpirationInterval {
            // Data is still fresh, use cached news
            self.news = cachedNews
            print("news found in cache")
            return
        }
        
        Task {
            await fetchAllNews()
            
        }
        
    }
        
    // Modify fetchAllNews function to use async/await
    private func fetchAllNews() async {
        do {
            let documentsSnapshot = try await FirebaseManager.shared.firestore.collection("news").getDocuments()
            
            var fetchedNews = [Card]()
            documentsSnapshot.documents.forEach { snapshot in
                let data = snapshot.data()
                let title = data["title"] as? String ?? ""
                fetchedNews.append(Card(title: title))
                print("News found in server")
            }
            
            self.news = fetchedNews
            
            // Save fetched news to cache
            if let encodedData = try? JSONEncoder().encode(fetchedNews) {
                print("Saving in cache ", Date())
                UserDefaults.standard.set(encodedData, forKey: "cachedNews")
                UserDefaults.standard.set(Date(), forKey: "cachedNews_timestamp")
            }
        } catch {
            self.errorMessage = "Failed to fetch news: \(error)"
            print("Failed to fetch news: \(error)")
        }
    }

}

struct CarrouselView: View{
    @StateObject private var vm = CarrusselViewModel()
    @State private var screenWidth: CGFloat = 0
    @State private var cardHeight: CGFloat = 0
    @State var activeCardIndex = 0
    @State var dragOffset: CGFloat = 0
    let widthScale = 0.75
    let cardAspectRatio = 0.8
    
    var body: some View {
        GeometryReader { reader in
            ZStack{
                ForEach(vm.news.indices, id: \.self) { index in
                    VStack(spacing: 1.0){
                        Text(vm.news[index].title)
                            .foregroundStyle(.black)
                    }
                    .frame(width: screenWidth * widthScale, height: cardHeight)
                    .background(Color("LightWhite"))
                    .overlay(Color.white.opacity(1-cardScale(for: index)))
                    .cornerRadius(20)
                    .shadow(color: .primary, radius: 12)
                    .offset(x: cardOffset(for: index))
                    .scaleEffect(x: cardScale(for: index), y: cardScale(for: index))
                    .zIndex(-Double(index))
                    .gesture(
                        DragGesture().onChanged{ value in
                            self.dragOffset = value.translation.width
                        }.onEnded{ value in
                            let treshold = screenWidth * 0.2
                            withAnimation {
                                if value.translation.width < -treshold{
                                    activeCardIndex = min(activeCardIndex + 1, vm.news.count - 1)
                                } else if value.translation.width > treshold{
                                    activeCardIndex = max(activeCardIndex - 1, 0)
                                }
                            }
                            withAnimation{
                                dragOffset = 0
                            }                        })
                }
            }
            .onAppear{
                screenWidth = reader.size.width
                cardHeight = screenWidth * widthScale * cardAspectRatio
            }
            .offset(x: 16, y: 30)
        }
        
        
    }
    
    func cardOffset(for index: Int) -> CGFloat{
        let adjustedIndex = index - activeCardIndex
        let cardSpacing: CGFloat = 60 / cardScale(for: index)
        let initialOffset = cardSpacing * CGFloat(adjustedIndex)
        let progress = min(abs(dragOffset)/(screenWidth/2), 1)
        let maxCardMovement = cardSpacing
        if adjustedIndex < 0 {
            if dragOffset > 0 && index == activeCardIndex - 1{
                let distancetoMove = (initialOffset + screenWidth) * progress
                return -screenWidth + distancetoMove
            } else {
                return -screenWidth
            }
        } else if index > activeCardIndex {
            let distancetoMove = progress * maxCardMovement
            return initialOffset - (dragOffset < 0 ? distancetoMove : -distancetoMove)
        } else {
            if dragOffset < 0 {
                return dragOffset
            } else {
                let distancetoMove = maxCardMovement * progress
                return initialOffset - (dragOffset < 0 ? distancetoMove : -distancetoMove)
            }
        }
    }
    
    func cardScale(for index: Int, proportion: CGFloat = 0.2) -> CGFloat{
        let adjustedIndex = index - activeCardIndex
        if index >= activeCardIndex {
            let progress = min(abs(dragOffset)/(screenWidth/2), 1)
            return 1 - proportion * CGFloat(adjustedIndex) + (dragOffset < 0 ? proportion * progress : -proportion * progress)
        }
        return 1
    }
    
    
    
}


final class MenuViewModel: ObservableObject{
   

    
    func logOut() throws {
        try AuthenticationManager.shared.signUserOut()
    }
}


struct MenuView: View {
    @Binding var showSigninView: Bool
    @StateObject private var viewModel = MenuViewModel()
    @State var isLoggedIn: Bool = false
    @State var toggleIsOn: Bool = true
    @State var showingAlert: Bool = false
    let motionManager = CMMotionManager()
    @ObservedObject var monitor = NetworkMonitor()
    
    var body: some View {
        NavigationView {
        
                VStack{
                    ZStack{
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .fill(Color("LightWhite"))
                            .frame(width:290,height:40)
                        Text("Universidad de Los Andes Homepage")
                            .font(.caption)
                            .foregroundColor(.black)
                        
                      
                    }
                    
                    CarrouselView()
                     
                    ScrollView{
                        VStack {
                            
                        
                            
                            Group{
                                NavigationLink(destination: MainChatView()) {
                                                    Text("Contact Student Brigade")
                                                }
                                
                                .font(.footnote)
                                .foregroundColor(.white)
                                .bold()
                                .frame(width: 210, height: 45)
                                .background{
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color("LighterGreen"))
                                }
                                .padding(.top)
                               
                                
                                
                                NavigationLink(destination: MaadReportView()) {
                                                    Text("Report MAAD Case")
                                                }
                             
                                .font(.footnote)
                                .foregroundColor(.white)
                                .bold()
                                .frame(width: 210, height: 45)
                                .background{
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color("LighterGreen"))
                                }
                                .padding(.top)
                                
                                
                                
                                NavigationLink(destination: MapView()) {
                                                    Text("Open Campus Map")
                                                }
                             
                                .font(.footnote)
                                .foregroundColor(.white)
                                .bold()
                                .frame(width: 210, height: 45)
                                .background{
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color("LighterGreen"))
                                }
                                .padding(.top)
                                
                                NavigationLink(destination: BotView()) {
                                                    Text("Chat with Brandnew Bot")
                                                }
                             
                                .font(.footnote)
                                .foregroundColor(.white)
                                .bold()
                                .frame(width: 210, height: 45)
                                .background{
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color("LighterGreen"))
                                }
                                .padding(.top)
                            }
                            
                            VStack{
                                        }.alert(isPresented: $showingAlert) {
                                            Alert(title: Text("Shake Detected"), message: Text("You shook your device!"), dismissButton: .default(Text("OK")))
                                        }
                            VStack{
                            }.alert(isPresented: Binding<Bool>(
                                get:{!monitor.isConnected},
                                set:{ _ in}
                                )) {
                                            Alert(title: Text("Shake Detected"), message: Text("You shook your device!"), dismissButton: .default(Text("OK")))
                                        }
                                    }
                                    .onAppear {
                                        if motionManager.isAccelerometerAvailable {
                                            motionManager.accelerometerUpdateInterval = 0.1
                                            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                                                guard let data = data else { return }
                                                
                                                let accelerationThreshold: Double = 1.5 // Umbral de aceleración para detectar la sacudida
                                                let totalAcceleration = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
                                                
                                                if totalAcceleration >= accelerationThreshold {
                                                    showingAlert = true // Mostrar la alerta cuando se detecta una sacudida
                                                }
                                            }
                                        }
                                    }
                                    .onDisappear {
                                        motionManager.stopAccelerometerUpdates()
                                    }
                            
                            
                            
                            
                        
                        
                            
                            Spacer()
                                .frame(height: 30)
                            VStack{
                                Toggle(
                                    isOn: $toggleIsOn,
                                    label: {
                                        Text("Activate alerts")
                                            .font(.footnote)
                                            .foregroundColor(.black)
                                    }
                                )
                                .toggleStyle(SwitchToggleStyle(tint: Color("LighterGreen")))
                                
                                
                            }
                            .padding(.horizontal,108)
                            
                            Button("Log Out"){
                                Task{
                                    do {
                                        try viewModel.logOut()
                                        showSigninView = true
                                    } catch {
                                    }
                                }
                            }
                            .padding()
                            .font(.footnote)
                            .foregroundColor(.white)
                            .bold()
                            .frame(width: 120, height: 45)
                            .background{
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(Color.red)
                                
                            }
                            
                            
                            
                        }
                            
                    }
        }.onAppear()
    }
}
    
    


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(showSigninView: .constant(false))
        //MenuView(showSigninView: .constant(false))
    }
}

struct Card: Codable {
    let id: UUID
    let title: String

    init(id: UUID = UUID(), title: String)   {
        self.id = id
        self.title = title
      
    }
}


struct ScaleButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label.scaleEffect(configuration.isPressed ? 2 : 1)
    }
}

