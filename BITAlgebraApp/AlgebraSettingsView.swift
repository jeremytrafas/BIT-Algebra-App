import SwiftUI

struct AlgebraSettingsView: View {
    // These variables automatically save to the user's phone
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("spellOutEquations") private var spellOutEquations: Bool = false
    
    var body: some View {
        Form {
            // SECTION 1: FEEDBACK
            Section(header: Text("Accessibility & Feedback")) {
                Toggle("Vibration (Haptics)", isOn: $enableHaptics)
                    .accessibilityHint("Vibrates phone on successful scans")
                
                Toggle("Spell Out Equations", isOn: $spellOutEquations)
                    .accessibilityHint("Forces VoiceOver to read math character by character")
                
                Text("Voice guidance is handled by your system VoiceOver settings.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // SECTION 2: APP INFO
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

#Preview {
    AlgebraSettingsView()
}
