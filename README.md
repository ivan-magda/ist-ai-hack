# ist-ai-hack

Mobile Language Tutor with Speech – Your AI language partner on-the-go.
A mobile (iOS) app where users practice a new language by having spoken conversations with an AI tutor.
Using speech recognition, the app listens to the learner’s spoken sentences, and an LLM in the backend plays the role of a fluent speaker responding in the target language.
For example, a user could chat in Spanish about their day and the AI responds with voice and text, correcting mistakes or teaching new phrases as needed.
User value: provides immersive, anytime practice for language learners who might not have human partners available.
The agent could also answer grammar questions or provide translations on the spot.
LLM role: generates context-appropriate, grammatically correct responses and instructions, while an integrated speech-to-text (for input) and text-to-speech (for the AI’s reply) create a seamless conversation experience. This leverages LLMs’ conversational ability to act as a patient, interactive language coach.

# 📄 Technical Specification

## 📌 **1. Project Overview**

**App Name:**
**Mobile Language Tutor**

**Platform:**

* **iOS** (Swift, SwiftUI)

**Core Purpose:**
A conversational AI language-learning app providing personalized speaking practice. Users speak to the app in their target language, receive natural conversational replies, grammar corrections, and vocabulary suggestions from GPT-4. Responses are delivered with natural speech synthesis via Eleven Labs.

---

## 📌 **2. Functional Requirements**

### 🔸 User Flows

* **Launch App**: User sees simple chat interface.
* **Initiate Conversation**: User taps microphone button to speak in target language.
* **Speech Recognition**: User speech is transcribed instantly via Apple's Speech Framework.
* **AI Response**: Transcribed text is sent to GPT-4 for context-aware language reply, grammar correction, and vocab enrichment.
* **Speech Output**: GPT-4's reply is synthesized into speech using Eleven Labs API, then played aloud.
* **Conversation History**: All interactions (speech bubbles with both user & AI responses) displayed clearly.

---

## 📌 **3. Technical Stack & API Integrations**

| Component             | Technology / API                              |
| --------------------- | --------------------------------------------- |
| **Frontend (iOS UI)** | Swift, SwiftUI                                |
| **Speech-to-Text**    | Apple Speech Framework (`SFSpeechRecognizer`) |
| **AI Language Model** | OpenAI GPT-4 (via OpenAI Swift SDK)           |
| **Text-to-Speech**    | Eleven Labs API (REST via URLSession)         |
| **Networking**        | Native Swift (`URLSession`)                   |

---

## 📌 **4. Detailed Integration Specification**

### 🔹 **Speech-to-Text (Apple Speech Framework)**

* **Framework**: `Speech`
* **Main Classes**:

  * `SFSpeechRecognizer`
  * `SFSpeechRecognitionRequest`
  * `SFSpeechRecognitionTask`

**Flow**:

1. User taps "record" button.
2. App records audio via microphone (`AVAudioEngine`).
3. Audio sent to `SFSpeechRecognizer` for instant transcription.
4. Display transcribed text in UI immediately upon recognition.

**Permission required**:

* `NSMicrophoneUsageDescription`
* `NSSpeechRecognitionUsageDescription`

---

### 🔹 **AI Backend (GPT-4 via OpenAI SDK)**

* **Library**: [OpenAI Swift SDK](https://github.com/MacPaw/OpenAI)
* **API Endpoint**: OpenAI GPT-4 (`chat/completions`)

**Prompt Template**:

```markdown
You are a friendly, patient language tutor. Converse naturally in [target language]. Gently correct grammar mistakes, suggest better expressions, and introduce useful vocabulary.

Conversation History:
User: [transcribed text from user]
Tutor:
```

**Flow**:

1. Transcribed text from Apple Speech framework sent to GPT-4.
2. GPT-4 generates context-aware, personalized language response.
3. Response displayed in chat interface.

---

### 🔹 **Text-to-Speech (Eleven Labs API)**

* **API Documentation**: [Eleven Labs API docs](https://docs.elevenlabs.io/)
* **Method**: HTTP POST via Swift’s `URLSession`.

**API Endpoint Example**:

```
POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}/stream
```

**Request Headers**:

```json
{
  "accept": "audio/mpeg",
  "xi-api-key": "<YOUR_API_KEY>",
  "Content-Type": "application/json"
}
```

**Request Body**:

```json
{
  "text": "GPT-4 generated response goes here.",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.6,
    "similarity_boost": 0.75
  }
}
```

**Audio Playback**:

* Use `AVAudioPlayer` to play received audio data immediately upon download.

---

## 📌 **5. User Interface (SwiftUI)**

### Main Views:

* **Chat View**:

  * Scrollable chat bubbles, alternating for user and AI.
  * Microphone button prominently placed at the bottom for speech input.

* **Recording State**:

  * Visual indicator when actively recording (animation or color change).

* **Playback Indicator**:

  * Visual cue when AI response audio is playing.

---

## 📌 **6. Error Handling**

* Display appropriate UI messages for:

  * Microphone permissions denied.
  * No speech detected.
  * API errors (OpenAI or Eleven Labs).
* Provide clear and concise messages to guide users (e.g., “Please speak clearly and try again.”).

---

## 📌 **7. Security and Privacy**

* API keys securely stored (using `Keychain` or environment variables).
* User data/transcripts not stored externally beyond local conversation history during the session.