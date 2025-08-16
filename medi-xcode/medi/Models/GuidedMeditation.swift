import SwiftUI

struct GuidedMeditation: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: Int
    let imageColor: Color
    let audioFileName: String
    
    init(id: String, title: String, description: String, duration: Int, imageColor: Color, audioFileName: String) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.imageColor = imageColor
        self.audioFileName = audioFileName
    }
}
