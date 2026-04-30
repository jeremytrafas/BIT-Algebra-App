BIT Learning Suite (Algebra, Physics, & Geometry)
Overview
The BIT Learning Suite is an accessible, iOS-based educational application designed to help visually impaired students independently learn algebra, physics, and geometry. The application works in tandem with a physical kit—including a device stand, a magnetic workspace, and 3D-printed tactile characters. By utilizing Apple's VisionKit and AVFoundation frameworks, the app translates physical equations built on the workspace into audible feedback via VoiceOver.

System Requirements & Dependencies
Language/Framework: Swift / SwiftUI

Target OS: iOS 18.0 or later

Development Environment: Xcode 26.1+

Core Dependencies (Native Apple Frameworks):

VisionKit / DataScannerViewController: Used for Optical Character Recognition (OCR) of the 3D-printed characters.

AVFoundation / AVSpeechSynthesizer: Used to generate dynamic, token-by-token audio feedback for the user.

CoreNFC: Used for scanning the geometry flashcards in the Tap 'n Math module.

File Standards
All source code files within this repository require standard header blocks denoting the project name, author, and date of creation/modification to maintain version control and traceability.

Flowcharts & Architecture
(Upload your system flowcharts to the repository and link them below)

[INSERT LINK: System Data Flowchart] - Details the data pathway from camera capture to math engine verification.

[INSERT LINK: OCR Verification Logic] - Details the algorithm used to parse multiline linear equations.

[INSERT LINK: UI Navigation Tree] - Details the user pathways between Algebra, Physics, and Geometry modules.

Team Responsibilities
Jeremy Trafas: Lead Software Engineer. Responsible for overall system architecture, integrating Apple VisionKit for high-accuracy OCR, developing the custom math verification engine, configuring AVSpeechSynthesizer for accessibility, merging legacy modules (Physics/Geometry), and designing the unified SwiftUI interface.

Acknowledgements
The BIT Learning Suite incorporates and builds upon foundational work from previous engineering teams. Special thanks to:

Bryce Swearingen: Original development of the "Tap 'n Math" Geometry app and NFC scanning architecture.

Ryan Hernandez: Original development of the interactive Physics application.

Financial Considerations
Apple Developer Program: Distributing this application to user devices via TestFlight or the App Store requires an active Apple Developer Program membership, which incurs an annual fee of $99.

Operating Instructions (End User)
Setup: Assemble the physical device stand and the magnetic workspace. Place the iOS device securely in the stand so the rear camera faces the board.

Launch: Open the BIT app and select the desired subject (Algebra, Physics, or Geometry) from the main menu.

Build: Listen to the VoiceOver instruction, then use the 3D-printed magnetic characters to build the corresponding equation on the board.

Scan: Tap the "Check Scan" button on the iOS device.

Feedback: The app will verify the equation and read the results back aloud. If incorrect, the app will read exactly what it saw so the user can independently correct their physical tiles.

Installation & Deployment Guide
1. Required Components
(1) iOS Device

Internet Connection

2. Step-by-Step User Installation via TestFlight
Install TestFlight: Open the App Store on the intended device, search for “TestFlight”, and download the application from Apple.

Accept the Invitation: Open https://testflight.apple.com/join/RTTGVmJd on the intended device and tap “View in TestFlight.” This will accept the invite to be a tester of the app.

Install the App: Once the invitation is accepted, the TestFlight app will display the BITAlgebraApp profile. Tap “Accept”, then “Install” to download the application to the device. Once the app is downloaded, it can be opened from the home screen or from the TestFlight app.

Grant System Permissions: Lastly, when launching the app for the first time, iOS will prompt the user to grant camera permission. It is imperative that these permissions are granted for OCR to function.

3. Step-by-Step Instructions to Modify and Upload Code
Prerequisites: * A Mac computer running Xcode 26.1+ (available for free on Mac App Store)

An active Apple Developer Program membership (available here)

Clone the Repository: Launch Xcode, select “Clone Git Repository”, and paste in the URL to the BIT-Algebra-App repository: https://github.com/jeremytrafas/BIT-Algebra-App

Open the Project: Locate the cloned repository folder and double-click the “BITAlgebraApp.xcodeproj” (or .xcworkspace) file to open the project within Xcode.

Configure Signing: In the left-hand Project Navigator menu, click the root project file. Find the “Signing & Capabilities” tab, check the box for “Automatically manage signing”, and select the correct Apple Developer account from the Team drop-down menu.

Modify Code: At this step, the code can be accessed and modified. The following steps are for uploading the code to TestFlight.

Archive the Application: Once the code has been modified, select “Product”, then “Archive”.

Upload to TestFlight: Next, click the “Distribute App” button, select “TestFlight Internal Only”, then click “Distribute” then “Show in App Store Connect”, then sign-in with your Apple ID. Click “Apps”, then “BITAlgebraApp”, then “TestFlight”. Scroll down to the Version 1.0 tab. Click “Manage Compliance”. If the button is not there, you may need to wait. Then click “None of the algorithms mentioned above”, and “Save”. At this point, the app is available on TestFlight.

Add User Device: Since the app has been modified and is distributed by a different developer, the user will need to download the new app on TestFlight. On the left side of the same tab as the last step, click the “+” next to “External Testing”. Name the group whatever you’d like. Select “Invite Testers”. How you want to invite testers is up to you, but the easiest way is “Public Link”. Select “Open to Anyone”. Now either type in the link on the user’s device or email it to them.

Install BIT App on User Device: Follow from Step 3 in the User Installation via TestFlight section above.
