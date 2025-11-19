# Bitwarden Secrets Manager Setup

This document outlines the steps to set up and use Bitwarden Secrets Manager for managing secrets in this project.

## 1. Bitwarden Secrets Manager Project Setup

1. Create a new project in the Bitwarden Secrets Manager web UI.
2. Add the secrets from the `.env.example` file to the new project.
3. Create an access token for the project.

## 2. Local Development Setup

1. Install the Bitwarden CLI: `bws`.
2. Log in to the Bitwarden CLI: `bws login`.
3. Set the `BWS_ACCESS_TOKEN` environment variable to the access token created in the previous step.
4. Run the application using the `bws run` command. This will inject the secrets into the environment.

## 3. CI/CD Setup

1. Add the `BWS_ACCESS_TOKEN` as a secret to the GitHub repository.
2. Update the CI/CD workflows to use the Bitwarden CLI to fetch secrets.

### `.github/workflows/ci.yml`

```yaml
- name: Install Bitwarden CLI
  run: |
    wget https://github.com/bitwarden/sdk/releases/download/bws-v0.1.0/bws-x86_64-unknown-linux-gnu
    chmod +x bws-x86_64-unknown-linux-gnu
    sudo mv bws-x86_64-unknown-linux-gnu /usr/local/bin/bws
- name: Get secrets
  run: |
    echo "BWS_ACCESS_TOKEN=${{ secrets.BWS_ACCESS_TOKEN }}" >> $GITHUB_ENV
    bws secret get <SECRET_ID> --access-token ${{ secrets.BWS_ACCESS_TOKEN }} >> .env
```

### `.github/workflows/firebase-hosting-merge.yml`

```yaml
- name: Install Bitwarden CLI
  run: |
    wget https://github.com/bitwarden/sdk/releases/download/bws-v0.1.0/bws-x86_64-unknown-linux-gnu
    chmod +x bws-x86_64-unknown-linux-gnu
    sudo mv bws-x86_64-unknown-linux-gnu /usr/local/bin/bws
- name: Get secrets
  run: |
    echo "BWS_ACCESS_TOKEN=${{ secrets.BWS_ACCESS_TOKEN }}" >> $GITHUB_ENV
    bws secret get <SECRET_ID> --access-token ${{ secrets.BWS_ACCESS_TOKEN }} >> .env
```

### `.github/workflows/firebase-hosting-pull-request.yml`

```yaml
- name: Install Bitwarden CLI
  run: |
    wget https://github.com/bitwarden/sdk/releases/download/bws-v0.1.0/bws-x86_64-unknown-linux-gnu
    chmod +x bws-x86_64-unknown-linux-gnu
    sudo mv bws-x86_64-unknown-linux-gnu /usr/local/bin/bws
- name: Get secrets
  run: |
    echo "BWS_ACCESS_TOKEN=${{ secrets.BWS_ACCESS_TOKEN }}" >> $GITHUB_ENV
    bws secret get <SECRET_ID> --access-token ${{ secrets.BWS_ACCESS_TOKEN }} >> .env
```

## 4. Platform-Specific Setup

### Android

Update `android/app/build.gradle.kts` to load secrets from the environment.

### iOS

Update `ios/Runner/AppDelegate.swift` to load secrets from the environment.

### Linux

Update `linux/runner/main.cc` to load secrets from the environment.

### macOS

Update `macos/Runner/AppDelegate.swift` to load secrets from the environment.

### Web

Update `web/index.html` to load secrets from the environment.

### Windows

Update `windows/runner/main.cpp` to load secrets from the environment.
