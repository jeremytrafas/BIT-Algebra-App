import SwiftUI

struct ContentView: View {
    var body: some View {
        // NavigationStack allows us to move between different screens
        NavigationStack {
            VStack(spacing: 30) {
                
                // Title of the App
                Text("BIT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .accessibilityAddTraits(.isHeader) // Tells VoiceOver this is a header
                
                Spacer()
                
                // 1. Teach Button
                NavigationLink(destination: TeachView()) {
                    MenuButtonView(title: "Teach", icon: "book.fill", color: .blue)
                }
                .accessibilityLabel("Teach")
                .accessibilityHint("Start a guided lesson")
                
                // 2. Practice Button
                NavigationLink(destination: PracticeView()) {
                    MenuButtonView(title: "Practice", icon: "pencil", color: .green)
                }
                .accessibilityLabel("Practice")
                .accessibilityHint("Solve problems on your own")
                
                // 3. Tutorial Button
                NavigationLink(destination: Text("Tutorial Screen Coming Soon")) {
                    MenuButtonView(title: "Tutorial", icon: "info.circle.fill", color: .orange)
                }
                .accessibilityLabel("Tutorial")
                .accessibilityHint("Learn how to use the physical kit")
                
                // 4. Settings Button
                NavigationLink(destination: SettingsView()) {
                    MenuButtonView(title: "Settings", icon: "gearshape.fill", color: .gray)
                }
                .accessibilityLabel("Settings")
                .accessibilityHint("Adjust audio and scanning preferences")
                
                Spacer()
            }
            .padding()
            .navigationTitle("Main Menu")
            .navigationBarHidden(true)
        }
    }
}

// This is a custom view design for the buttons to keep the code clean
struct MenuButtonView: View {
    var title: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .foregroundColor(.white) // High contrast text
        .cornerRadius(15)
    }
}

#Preview {
    ContentView()
}
