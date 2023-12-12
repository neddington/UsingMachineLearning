//
//  ContentView.swift
//  UsingMachineLearning
//
//  Created by Eddington, Nick on 12/11/23.
//

import SwiftUI
import NaturalLanguage
import CoreML
import Vision

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var detectedLanguage: String = ""
    @State private var selectedImage: UIImage?
    @State private var recognizedObjects: [String] = []
    @State private var isShowingImagePicker = false
    
    var body: some View {
        TabView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .padding()
                
                Text("Enter text:")
                
                TextField("Type here", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button("Detect Language") {
                    detectLanguage()
                }
                .padding()
                
                if !detectedLanguage.isEmpty {
                    Text("Detected Language: \(detectedLanguage)")
                        .padding()
                }
            }
            .tabItem {
                Label("Text", systemImage: "doc.text")
            }
            
            VStack {
                if selectedImage == nil {
                    Button("Select an Image") {
                        isShowingImagePicker.toggle()
                    }
                    .padding()
                } else {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                        
                        if !recognizedObjects.isEmpty {
                            Text("Recognized Objects:")
                            ForEach(recognizedObjects, id: \.self) { object in
                                Text(object)
                            }
                            .padding()
                        }
                    }
                }
            }
            .tabItem {
                Label("Image", systemImage: "photo")
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    func detectLanguage() {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(inputText)
        
        if let languageCode = recognizer.dominantLanguage?.rawValue {
            let detectedLanguage = Locale.current.localizedString(forIdentifier: languageCode) ?? "Unknown"
            self.detectedLanguage = detectedLanguage
        } else {
            self.detectedLanguage = "Unable to detect language"
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
