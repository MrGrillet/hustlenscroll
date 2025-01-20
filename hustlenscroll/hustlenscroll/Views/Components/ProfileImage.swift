import SwiftUI

struct ProfileImage: View {
    let senderId: String
    let size: CGFloat
    
    var body: some View {
        Group {
            if senderId.lowercased() == "mentor" {
                Image("mentor", bundle: nil)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            } else {
                // Fallback to system person circle if no image found
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .foregroundColor(.gray)
            }
        }
    }
} 