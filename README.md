# campustrade

A new Flutter project.

## AI Chat MVP Setup

This project now includes a Firebase Callable Function for flexible chat replies.

### 1) Install Flutter dependencies

From project root:

```bash
flutter pub get
```

### 2) Install Functions dependencies

```bash
cd functions
npm install
```

### 3) (Optional) Add Gemini API key

Create `functions/.env` from `functions/.env.example` and add your key:

```env
GEMINI_API_KEY=your_api_key_here
```

If no key is set, the function still works with deterministic fallback replies.

### 4) Deploy backend function

```bash
firebase deploy --only functions
```

Important:
- Firebase Cloud Functions deployment requires Blaze plan for this project.
- If Blaze is not enabled, chat still sends user messages to Firestore, but AI assistant replies will not be generated.

### 5) Run app

```bash
flutter run
```

Chat flow:
- Buyer sends message in chat screen
- App calls `askChatAssistant` callable function
- Function returns grounded response from item context

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
