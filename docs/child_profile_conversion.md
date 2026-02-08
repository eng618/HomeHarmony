# Child Profile Conversion Guide

## Overview

The Home Harmony app supports two types of child profiles: **Local Profiles** and **Full Accounts**. This guide explains the difference between these profile types and how parents can convert local profiles to full accounts.

## Profile Types

### Local Profiles (Limited)

- **Purpose**: Parent-managed only profiles for initial setup
- **Capabilities**:
  - Managed by parents through the family dashboard
  - Cannot log in independently
  - Basic profile information and family relationships
- **Use Cases**: Getting started, younger children, supervised usage

### Full Accounts (Authentic)

- **Purpose**: Independent login profiles for older children
- **Capabilities**:
  - Child can log in with their own email/password
  - Access to personal account features
  - Independent screen time tracking
  - Full app features when signed in as child
- **Use Cases**: Teens, older children who need independence

## Converting Local to Full Account

### Process Overview

1. Identify child with local profile in Family Members
2. Navigate to child's detail view
3. Click "Upgrade to Full Account" button
4. Provide email and password credentials
5. Complete account creation

### Step-by-Step Instructions

#### Step 1: Access Child Profile

1. Sign in as parent account
2. Navigate to "Family" tab
3. Select the child profile you want to upgrade
4. View child details screen

#### Step 2: Initiate Conversion

- Look for the "Upgrade to Full Account" button (appears only for local profiles)
- Click the button to start the process

#### Step 3: Review Information

- Read the confirmation dialog explaining the upgrade process
- Understand that this allows the child to sign in independently

#### Step 4: Create Credentials

- Enter child's email address (must be valid email)
- Create a secure password (minimum 6 characters)
- Confirm password to prevent typos
- Provide clear password to child in real life

#### Step 5: Complete Conversion

- Account creation may take a moment
- **Important**: Upon successful creation, you will automatically be signed in with the child's credentials
- This allows you to verify the account works correctly
- Child profile type changes to "full" and the upgrade button disappears
- Success notification guides you to sign back in as a parent
- Use the back navigation or sign-out to return to parent account

### Important Security Notes

#### Parent Responsibilities

- Store password securely until child can manage it
- Explain password security to child
- Monitor child's account usage initially

#### Account Management

- Child email must be unique (not used by another account)
- Password requirements: 6+ characters
- Email must be accessible to child
- Child can manage their own password after login

#### Data Privacy

- Child data remains associated with family
- Parents retain administrative access
- Child has personal account control

## Technical Implementation

### Architecture

```
Local Profile → Conversion Process → Full Account
     ↓             ↓              ↓
families/{parentId}/children/{childId}
     ↓             ↓              ↓
users/{childFirebaseAuthId} (new)
Firebase Auth account (new)
```

### Database Changes

- **Profile Type**: `'local'` → `'full'`
- **New User Document**: Created for authentication
- **Auth UID**: Set to generated Firebase Auth user ID

### Security Rules

Parents (users with `role: 'parent'`) can create child user documents:

```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId ||
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'parent';
}
```

## Troubleshooting

### Common Issues

#### "Missing or Insufficient Permissions"

**Cause**: Firestore rules preventing document creation
**Solution**: Ensure parent account has correct role, restart app

#### "Email Already in Use"

**Solution**: Use a different email address, check existing accounts

#### "Weak Password"

**Solution**: Password must be at least 6 characters

#### Conversion Fails

**Solution**: Check internet connection, try again, contact support if persistent

### Support Contact

For technical issues with account conversion:

- Check internet connection
- Ensure parent account is correctly configured
- Contact support through app settings

## Best Practices

### For Parents

1. **Start Simple**: Use local profiles initially
2. **Gradual Transition**: Upgrade as children mature
3. **Secure Credentials**: Use strong passwords, explain security
4. **Monitor Usage**: Review child accounts initially

### For Child Safety

1. **Appropriate Content**: Ensure content rules are set
2. **Time Limits**: Configure screen time boundaries
3. **Emergency Access**: Parents retain override capabilities
4. **Regular Reviews**: Monitor and adjust as needed

## Future Enhancements

### Planned Features

- Email verification during account creation
- Parental password reset capabilities
- Child account activity reports
- Temporary profile locking

### Usage Analytics

- Conversion rate tracking
- Account usage patterns
- Family engagement metrics

This feature enables families to start simple and scale their digital parenting approach as their children's needs evolve, maintaining security and parental oversight while promoting healthy digital independence.
