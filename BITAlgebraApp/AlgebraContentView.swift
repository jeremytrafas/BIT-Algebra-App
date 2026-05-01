// Project: BIT Algebra
// Author: Jeremy Trafas
// Date: 2026-05-01

import SwiftUI

// Root menu with navigation to Teach, Practice, Tutorial, and Settings.
struct AlgebraContentView: View {
    
    var body: some View {
        // Wraps main menu in a navigation context.
        NavigationStack {
            // Main vertical layout for title and navigation buttons.
            VStack(spacing: 30) {
                
                Text("BIT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                // Navigate to Teach flow
                NavigationLink(destination: AlgebraTeachView()) {
                    MenuButtonView(title: "Teach", icon: "book.fill", color: .blue)
                }
                .accessibilityLabel("Teach")
                .accessibilityHint("Start a guided lesson")
                
                // Navigate to Practice flow
                NavigationLink(destination: AlgebraPracticeView()) {
                    MenuButtonView(title: "Practice", icon: "pencil", color: .green)
                }
                .accessibilityLabel("Practice")
                .accessibilityHint("Solve problems on your own")
                
                // Navigate to Tutorial placeholder
                NavigationLink(destination: Text("Tutorial Screen Coming Soon")) {
                    MenuButtonView(title: "Tutorial", icon: "info.circle.fill", color: .orange)
                }
                .accessibilityLabel("Tutorial")
                .accessibilityHint("Learn how to use the physical kit")
                
                // Navigate to Settings
                NavigationLink(destination: AlgebraSettingsView()) {
                    MenuButtonView(title: "Settings", icon: "gearshape.fill", color: .gray)
                }
                .accessibilityLabel("Settings")
                .accessibilityHint("Adjust audio and scanning preferences")
                
                Spacer()
            }
            .padding()
        }
    }
}

// Reusable styled menu button component.
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
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

// Preview for the content view.
#Preview {
    AlgebraContentView()
}
