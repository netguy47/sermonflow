# SermonFlow: Final Deployment Checklist

Follow these 10 steps to submit **SermonFlow** to the App Store.

---

### 📦 1. Xcode Project Assets
- [ ] Add the `Resources/` folder to your Xcode project.
- [ ] Ensure `web.json` is listed in **Build Phases > Copy Bundle Resources**.
- [ ] Add the `GoogleService-Info.plist` to the project root.

### 🔑 2. Identity & Signing
- [ ] Set **Bundle ID** to `com.sermonflow.app`.
- [ ] Enable **In-App Purchase** capability.
- [ ] Enable **Push Notifications** capability.

### 💰 3. StoreKit Verification
- [ ] Open `SermonFlowApp.swift` and verify `PurchaseManager.shared` is initialized.
- [ ] Ensure `Configuration.storekit` is active in your Scheme's Run options.

### 🛡️ 4. Legal (Privacy & Terms)
- [ ] Upload content of `Submission/PRIVACY_POLICY.md` to App Store Connect.
- [ ] Set `Submission/TERMS_OF_SERVICE.md` as your EULA.

### 🏷️ 5. Metadata
- [ ] Copy **App Name** and **Keywords** from `Submission/APP_STORE_METADATA.md`.
- [ ] Ensure **Age Rating** is set to **12+** (required for AI).

### 🤖 6. AI & Safety
- [ ] Verify the **AI Disclosure Modal** triggers on the "Create" tab.
- [ ] Confirm the **Report Content** flag is functional in the generated output.

### 👤 7. Reviewer Info
- [ ] Copy the credentials from `Submission/REVIEWER_NOTES.md` into the App Review section.

### 🖼️ 8. Screenshots
- [ ] Prepare 3-5 screenshots showing the **Timeline**, **Sermon Architect**, and **Settings/Pro** view.

### 🚀 9. Archive & Upload
- [ ] Set build target to **Any iOS Device (arm64)**.
- [ ] Go to **Product > Archive**.
- [ ] Select **Distribute App** > **App Store Connect**.

### 🧪 10. TestFlight
- [ ] Distribute to **External Testers** for one final verification before clicking "Submit for Review".

---
**Deployment Status**: 🟢 READY
**Source of Truth**: `/Volumes/Untitled/sermonflow`
