import SwiftUI

public struct GuidedMeditation: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let duration: Int
    public let imageColor: Color
    public let audioFileName: String
    
    public init(id: String, title: String, description: String, duration: Int, imageColor: Color, audioFileName: String) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.imageColor = imageColor
        self.audioFileName = audioFileName
    }
}
