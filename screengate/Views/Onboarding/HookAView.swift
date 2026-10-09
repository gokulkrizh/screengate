import SwiftUI

struct HookAView: View {
    @ObservedObject var data: OnboardingData
    var body: some View { StoryChapterView(data: data, chapter: 0) }
}
