# Child Account Creation Flow

This document outlines the process of creating a new child account within the HomeHarmony application.

## High-Level Overview

The child account creation process involves a parent user initiating the creation, filling out the child's details, and the system then creating a new user in Firebase Authentication and a corresponding child profile in Firestore.

## Sequence Diagram

The following sequence diagram illustrates the interactions between the user and the different components of the system during child account creation.

```mermaid
sequenceDiagram
    actor Parent
    Parent->>FamilyMembersScreen: Taps "Add Child Account"
    FamilyMembersScreen->>ChildAccountForm: Shows dialog
    Parent->>ChildAccountForm: Fills in child's details
    Parent->>ChildAccountForm: Taps "Add"
    ChildAccountForm->>AuthService: Calls createChildAccount()
    AuthService->>Firebase Auth: createUserWithEmailAndPassword()
    Firebase Auth-->>AuthService: Returns new child user credential
    AuthService->>Firestore: Creates child document in parent's family
    Firestore-->>AuthService: Confirms creation
    AuthService->>ScreenTimeService: Initializes screen time bucket
    ScreenTimeService-->>AuthService: Confirms initialization
    AuthService-->>ChildAccountForm: Returns success
    ChildAccountForm-->>FamilyMembersScreen: Closes dialog
    FamilyMembersScreen->>FamilyMembersView: Refreshes to show new child
```

## Class Diagram

This diagram shows the main classes involved in the child account creation flow and their relationships.

```mermaid
classDiagram
    class FamilyMembersScreen {
        +user: User
        -_familyService: FamilyService
        -_addChildAccount()
    }
    class ChildAccountForm {
        +onSubmit: Function
        -nameController: TextEditingController
        -ageController: TextEditingController
        -emailController: TextEditingController
        -passwordController: TextEditingController
    }
    class AuthService {
        <<static>> +createChildAccount()
    }
    class FamilyService {
        +addChildProfile()
        +updateChildProfile()
        +deleteChildProfile()
    }
    class ScreenTimeService {
        +updateBucket()
    }

    FamilyMembersScreen --> ChildAccountForm : displays
    ChildAccountForm --> AuthService : calls
    AuthService --> ScreenTimeService : calls
    FamilyMembersScreen --> FamilyService : uses
```

## State Diagram

This diagram illustrates the states of the `ChildAccountForm` during the creation process.

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading: User clicks "Add"
    Loading --> Idle: Success, dialog closes
    Loading --> Error: Failure
    Error --> Loading: User retries
    Error --> Idle: User cancels
```
