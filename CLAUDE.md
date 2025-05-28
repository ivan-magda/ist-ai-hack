# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mobile Language Tutor is an iOS app for practicing spoken conversations with an AI language tutor. Users speak in their target language, receive AI responses with grammar corrections and vocabulary suggestions, delivered through natural speech synthesis.

## Development Commands

### Building and Running
- **Build**: Use Xcode or `xcodebuild -project ist-ai-hack.xcodeproj -scheme ist-ai-hack build`
- **Run**: Use Xcode simulator or device
- **Tests**: `xcodebuild test -project ist-ai-hack.xcodeproj -scheme ist-ai-hack -destination 'platform=iOS Simulator,name=iPhone 15'`

### Package Management
- Uses Swift Package Manager integrated with Xcode
- Current dependency: OpenAI Swift SDK from MacPaw

## Architecture

### MVVM Pattern
- **Models**: `ChatMessage` - simple data structures for chat messages
- **ViewModels**: `ChatViewModel` - manages chat state using SwiftUI's `@Observable`
- **Views**: SwiftUI-based with `ContentView` → `ChatView` → `ChatBubble` hierarchy

### Service Layer
Three main services handle external integrations:
- **SpeechService**: Apple Speech Framework for speech-to-text recognition
- **OpenAIService**: GPT-4 integration via OpenAI Swift SDK for conversational AI
- **ElevenLabsService**: Text-to-speech synthesis via REST API

### Core Flow
1. User taps microphone → `SpeechService` transcribes speech
2. Transcribed text → `OpenAIService` generates response 
3. AI response → `ElevenLabsService` converts to audio
4. Audio playback while displaying chat bubbles

## Key Implementation Details

### Permissions Required
- `NSMicrophoneUsageDescription`: "Allow microphone access to speak with the tutor."
- `NSSpeechRecognitionUsageDescription`: "Allow speech recognition for understanding your input."

### API Integrations
- **OpenAI**: Uses MacPaw OpenAI Swift SDK (v0.4.3+) for GPT-4 chat completions
- **Eleven Labs**: Direct REST API calls via URLSession for multilingual TTS
- **Apple Speech**: Native SFSpeechRecognizer for real-time transcription

### State Management
- Uses SwiftUI's new `@Observable` macro for reactive ViewModels
- Chat messages stored as array in `ChatViewModel`
- Services are stateless and injected as needed

## Project Structure Notes

- Target iOS 18.4+ with Swift 5.0
- Bundle ID: `com.ivan.magda.app.ios.ist-ai-hack`
- Development team configured for automatic code signing
- Xcode 16.3 project with SwiftUI previews enabled