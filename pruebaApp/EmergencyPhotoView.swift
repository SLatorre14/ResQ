import SwiftUI
import Firebase



struct EmergencyPhotoView: View {
    @State private var emergencyImages: [UIImage] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("Emergency Photos")
                .font(.largeTitle)
                .padding()
                .foreground(.black)
            
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                if !emergencyImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(emergencyImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(10)
                                    
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No emergency photos found.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .onAppear {
            fetchEmergencyPhotos()
        }
        
    }

    private func fetchEmergencyPhotos() {
        isLoading = true
        FirebaseManager.shared.firestore.collection("emergencies").getDocuments { snapshot, error in
            isLoading = false
            if let error = error {
                errorMessage = "Error fetching photos: \(error.localizedDescription)"
            } else {
                guard let snapshot = snapshot else {
                    errorMessage = "No data found."
                    return
                }
                var images: [UIImage] = []
                for document in snapshot.documents {
                    
                    
                    if let imageData = document.data()["image"] as? Data,
                        let uiImage = UIImage(data: imageData){
                        images.append(uiImage)
                    }
                    
                    
                }
                emergencyImages = images
            }
        }
    }
    
    private func saveImageLocally(image: Image) {
            guard let uiImage = UIImage(named: "your_image_name_here") else {
                print("Failed to convert Image to UIImage")
                return
            }
            
            guard let data = uiImage.jpegData(compressionQuality: 1) else {
                print("Failed to convert UIImage to Data")
                return
            }
            
            let filename = getDocumentsDirectory().appendingPathComponent("copyOfSample.jpg")

            do {
                try data.write(to: filename)
                print("Saved to \(filename)")
            } catch {
                print("Failed to save data: \(error.localizedDescription)")
            }
        }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


#Preview {
    EmergencyPhotoView()
}
