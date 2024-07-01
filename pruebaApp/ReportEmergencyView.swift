import SwiftUI
import FirebaseAuth
import PhotosUI
import AVFoundation
import FirebaseFirestore

private var noInternetPopup: some View {
    @ObservedObject var monitor = NetworkMonitor()
        if !monitor.isConnected {
            return AnyView(
                Button(action: {
                    // Handle action when tapped
                }) {
                    Text("No Internet Connection")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }


struct ReportEmergencyView: View {
    @State private var selectedBuilding: String = "SD" // Default selection
    @State private var description: String = ""
    @State private var image: UIImage?
    @State private var isImageSelectorPresented = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State var showImagePicker = false
    @ObservedObject var monitor = NetworkMonitor()
    @State private var ImageSelectorSourceType:
    UIImagePickerController.SourceType = .photoLibrary
    
    let buildings = ["SD", "ML", "Lleras", "C", "RGD"]
    
    var body: some View {
        VStack {
            Text("Report Emergency")
                .font(.largeTitle)
                .padding()
            
                .foregroundColor(.black)
            Form {
                Section(header: Text("Building").foregroundColor(.black) ) {
                    Picker("Select a building", selection: $selectedBuilding) {
                        ForEach(buildings, id: \.self) { building in
                            Text(building)
                                .foregroundColor(.black)
                        }
                    }
                }
                
                Section(header: Text("Description").foregroundColor(.black)) {
                    TextField("Enter description", text: $description)
                        .foregroundColor(.black)
                }
                
                Section(header:Text("Image").foregroundColor(.black)) {
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        VStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            
                                    
                                    .padding(.vertical, 4) // Add padding if necessary
                            } else {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color("LighterGreen"))
                                    .padding(.vertical, 4) // Add padding if necessary
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity) // Expand to fill button
                        .background(Color.white) // Ensure button background is white
                        .cornerRadius(10) // Apply corner radius to button
                        .padding() // Optional padding around button
                        .shadow(radius: 3) // Optional shadow for button
                    }
                    .buttonStyle(PlainButtonStyle()) // Remove default button style
                }

                
                
            }
            Button(action: submitReport) {
                Text("Submit Report")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isLoading || !monitor.isConnected)
            .opacity((isLoading || !monitor.isConnected) ? 0.5 : 1.0)
        
            
            if isLoading {
                ProgressView()
            }
        }
        
        .alert(isPresented: $showError) {
            Alert(title: Text(""), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }.fullScreenCover(isPresented: $showImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }.navigationBarItems(trailing:
                                NavigationLink(destination: EmergencyPhotoView()) {
                                    Text("See Emergency Report Images")
                                        .foregroundColor(Color("LighterGreen"))
                                })
        .navigationBarItems(trailing: noInternetPopup)
    }
    
    func submitReport() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "User not logged in."
            showError = true
            return
        }
        
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
               errorMessage = "Image data is missing."
               showError = true
               isLoading = false
               return
           }
        
        
        
        isLoading = true
        
        let reportData: [String: Any] = [
                "userEmail": userEmail,
                "building": selectedBuilding,
                "description": description,
                "timestamp": Timestamp(),
                "image": imageData
                // You can add more fields as needed
            ]


        
        FirebaseManager.shared.firestore.collection("emergencies").addDocument(data: reportData) { error in
            isLoading = false
            
            if let error = error {
                self.errorMessage = "Error adding document: \(error.localizedDescription)"
                self.showError = true
            } else {
                // Successfully added the document
                self.errorMessage = "Report submitted successfully!"
                self.showError = true
                
                // Clear the form after submission
                self.selectedBuilding = "Building A"
                self.description = ""
                self.image = nil
            }
        }
        
    }
    
}

#Preview {
    ReportEmergencyView()
}

