import SwiftUI
import PhotosUI

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameState: GameState
    @State private var postContent: String
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    let linkedOpportunity: BusinessOpportunity?
    let linkedInvestment: Asset?
    
    // Initialize with empty content for new posts
    init(gameState: GameState) {
        self.init(gameState: gameState, initialContent: "", initialImages: [])
    }
    
    // Initialize with pre-populated content for draft posts
    init(gameState: GameState, 
         initialContent: String, 
         initialImages: [String] = [], 
         linkedOpportunity: BusinessOpportunity? = nil,
         linkedInvestment: Asset? = nil) {
        self.gameState = gameState
        self._postContent = State(initialValue: initialContent)
        self.linkedOpportunity = linkedOpportunity
        self.linkedInvestment = linkedInvestment
        
        // Convert base64 strings to UIImages if any
        let images = initialImages.compactMap { base64String -> UIImage? in
            guard let data = Data(base64Encoded: base64String) else { return nil }
            return UIImage(data: data)
        }
        self._selectedImages = State(initialValue: images)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $postContent)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .placeholder(when: postContent.isEmpty) {
                        Text("What's on your mind?")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                    }
                
                PhotosPicker(selection: $selectedItems,
                           maxSelectionCount: 4,
                           matching: .images) {
                    Label("Add Images", systemImage: "photo.on.rectangle.angled")
                }
                
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Button(action: { removeImage(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                if !postContent.isEmpty {
                    Button(action: createPost) {
                        Text("Post")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle(linkedOpportunity != nil || linkedInvestment != nil ? "Edit Draft Post" : "Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: selectedItems) { items, _ in
            Task {
                selectedImages = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
    
    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        selectedItems.remove(at: index)
    }
    
    private func createPost() {
        // Convert images to strings
        let imageStrings = selectedImages.compactMap { image -> String? in
            guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
            return data.base64EncodedString()
        }
        
        guard let profile = gameState.profile else { return }
        
        let newPost = Post(
            author: profile.name,
            role: profile.role,
            content: postContent,
            linkedOpportunity: linkedOpportunity,
            linkedInvestment: linkedInvestment,
            images: imageStrings,
            isAutoGenerated: linkedOpportunity != nil || linkedInvestment != nil
        )
        
        gameState.addPost(newPost)
        dismiss()
    }
}

// Helper view modifier for placeholder text in TextEditor
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 