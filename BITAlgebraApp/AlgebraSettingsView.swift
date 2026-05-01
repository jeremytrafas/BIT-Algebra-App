// Project: BIT Algebra
// Author: Jeremy Trafas
// Date: 2026-05-01

import SwiftUI

// Settings screen for accessibility and feedback preferences.
struct AlgebraSettingsView: View {
    // Persisted user preferences for haptics, equation spelling, and speech rate.
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("spellOutEquations") private var spellOutEquations: Bool = false
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    
    var body: some View {
        Form {
            // Section: Accessibility and feedback controls.
            Section(header: Text("Accessibility & Feedback")) {
                Toggle("Vibration (Haptics)", isOn: $enableHaptics)
                    .accessibilityHint("Vibrates phone on successful scans")
                
                Toggle("Spell Out Equations", isOn: $spellOutEquations)
                    .accessibilityHint("Forces the app to read math character by character")
                
                // Control the rate used for spoken equations.
                VStack(alignment: .leading, spacing: 10) {
                    Text("Equation Speech Speed")
                        .font(.body)
                    
                    HStack {
                        Image(systemName: "tortoise.fill")
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)
                        
                        Slider(value: $speechRate, in: 0.1...1.0, step: 0.1)
                            .accessibilityLabel("Equation Speech Speed")
                            .accessibilityValue("\(Int(speechRate * 100)) percent")
                            .accessibilityHint("Swipe up or down to adjust the reading speed of equations")
                        
                        Image(systemName: "hare.fill")
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.vertical, 5)
                
                Text("Note: Menu navigation speed is controlled by your iPhone's global VoiceOver settings.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Section: App version and information.
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.1")
                        .foregroundColor(.gray)
                }
                Text("Designed for accessibility with Apple VisionKit.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

// Preview for the settings screen.
#Preview {
    AlgebraSettingsView()
}
