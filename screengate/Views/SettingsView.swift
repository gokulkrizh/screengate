import SwiftUI

struct SettingsView: View {
    @State private var showDebug = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Development") {
                    NavigationLink("Debug Center", destination: DebugView())
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
