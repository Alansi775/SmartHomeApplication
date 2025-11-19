**Overview**

The Smart Home Control application is a Flutter based app designed for managing and controlling smart home devices via a voice controlled interface and manual interactions. The app integrates Cloud For Realtime Database for real time device state updates and uses voice commands to provide hands free control. The app is designed with a dark mode and light mode theme switcher dynamically, making it visually adaptable to user preferences.

**Application ScreenShots**
 https://slender-forsythia-e75.notion.site/SmartHome-Project-16f883fb9e358002b09de27e56b36266

 **Project Prototype Demonstration**
 https://www.youtube.com/watch?v=SxPO22OO0eE

**Key Features**

1.	**Voice Control**:

•	Processes voice commands to control home devices such as doors, lights, curtains, water and health care track for old people also live streaming for the camera and communication with the home components like refrigerator. 

•	Utilizes a natural language matching algorithm for command recognition.

2.	**Device Management**:

•	Real-time synchronization with Cloud Realtime Database.

•	Manual control options via buttons and dynamic status indicators.

3.	**Dark/Light Theme Switching**:

•	Provides a toggle to switch between dark and light themes for better user experience.

4.	**Navigation Drawer**:

•	Access to camera streaming and logout options.

5.	**Bottom Navigation Bar**:

•	Quick navigation to home, chatbot, and home assistance pages.

6.	**Dynamic Icons**:

•	Updates device status icons based on real-time data.

**Modules and Components**

1.	SmartHomeControl **(Main Screen)**:

•	The primary interface for controlling smart home devices.

•	Integrates with SpeechToTextControl for voice commands.

•	Uses dynamic icons to reflect the current state of devices.

2.	**Cloud Integration**:

•	Listens for changes in device states from Firebase Realtime Database.

•	Sends updates to Firebase when device states are manually changed.

3.	**Theming**:

•	Dark and light mode themes managed through ThemeProvider.

•	Updates UI elements such as text, buttons, and backgrounds based on the selected theme.

4.	**Drawer Navigation**:

•	**Camera Stream**: Opens a real-time camera stream page.

•	**Logout**: Redirects users to the sign-in screen.

5.	**Bottom Navigation Bar**:

•	**Home**: Redirects to the main control page.

•	**Chatbot**: Opens an AI chat assistant.

•	**Home Assistance**: Integrates with a conversational AI which it is a call with AI system.

**Key Classes and Methods**

1.	**State Management**:

•	deviceStatus: Maintains the current status of each device.

•	_loadDeviceStatus: Fetches real time updates from Firebase.

•	_updateDeviceStatus: Sends new status updates to Firebase.

2.	**Voice Command Processing**:

•	processVoiceCommand(String command): Normalizes and interprets voice commands to trigger corresponding device actions.

3.	**UI Elements**:

•	_buildDeviceButton(String label, String device): Creates interactive buttons for manual device control.

•	_buildDeviceStatusIcons(): Dynamically generates icons to represent the state of devices.

4.	**Navigation**:

•	Utilizes Navigator.push and Navigator.pushReplacement for page transitions.

**Dependencies**

•	**Firebase Realtime Database**:

•	Provides real time synchronization of device states.

•	**Speech-to-Text**:

•	Enables voice control functionality.

•	**Provider**:

•	Manages theme state across the application.

•	**Material Design**:

•	Implements user friendly and visually appealing UI elements.

**Potential Enhancements**

1.	**Voice Command Feedback**:

•	Add audio or visual feedback to confirm successful execution of commands.

2.	**Localization**:

•	Support multiple languages for voice commands.

3.	**Advanced AI Integration**:

•	Use AI models to improve voice command recognition and context understanding.

4.	**Automation**:

•	Allow users to set schedules or triggers for device operations.

