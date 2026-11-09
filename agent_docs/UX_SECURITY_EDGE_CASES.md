# UX & Security Edge Cases — comebak.in

This file documents critical UX and security edge cases that must be handled in code.

## 1. Authentication & Security

### 1.1 Device Binding for Magic Links (PKCE)
- **Rule:** A magic link requested on Device A must **not** authenticate Device B.
- **Mechanism:** Supabase uses the PKCE flow by default. The `code_verifier` is stored in the local storage of the device that requested the link. When the link is clicked on another device, the exchange fails because the verifier is missing.
- **UX Fallback:** If the exchange fails (e.g., user clicked the link on a laptop), the app must show a friendly error: "Please open the link on the same device that requested it."
- **Developer Note:** Do not disable PKCE. Do not use implicit flow.

### 1.2 OAuth Provider Visibility
- **Rule:** Apple Sign-In must **only** be shown on iOS devices.
- **Rule:** Google Sign-In is shown on both iOS and Android.
- **Implementation:** Use `Platform.isIOS` to conditionally render the Apple button.

## 2. Keyboard & Focus Management
- **Rule:** Tapping outside a text field must dismiss the keyboard.
- **Implementation:** Wrap the screen in a `GestureDetector` with `onTap: () => FocusScope.of(context).unfocus()`.

## 3. Deep Linking (iOS)
- **Rule:** The app must open when a magic link is clicked.
- **Pitfall:** Flutter's default deep linking can intercept the URL before `supabase_flutter`'s internal `app_links` package can handle it.
- **Fix:** Set `FlutterDeepLinkingEnabled` to `false` in `Info.plist`.
- **Allow List:** The redirect URL (`comebak.in://login-callback`) must be explicitly added to the Supabase Dashboard's Redirect URLs allow list.