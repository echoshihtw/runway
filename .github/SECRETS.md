# Required GitHub Secrets

## iOS (TestFlight)
| Secret | Description |
|--------|-------------|
| `IOS_CERTIFICATE_BASE64` | Base64 encoded .p12 distribution certificate |
| `IOS_CERTIFICATE_PASSWORD` | Password for the .p12 certificate |
| `KEYCHAIN_PASSWORD` | Any strong password for the temp keychain |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 encoded .mobileprovision file |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 encoded .p8 API key file |

## Android (Play Store)
| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded .jks keystore file |
| `ANDROID_KEY_ALIAS` | Keystore key alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play service account JSON |

## How to encode files to Base64
```bash
base64 -i your_file.p12 | pbcopy   # copies to clipboard
```

## Pipeline triggers
- `pull_request` to `staging` or `main` → runs quality only
- `push` to `staging` → runs quality + builds, and opens or updates the release PR
- merge into `main` → quality + builds, then tag and release to stores

## Releasing
Merge the open `chore(release): …` PR from `staging` into `main` with a merge
commit. To redeploy an existing tag, run the CD workflow from the Actions tab.
