# thread. wardrobe

A Vue 3 and Ionic wardrobe planner with a customizable outfit calendar, closet catalog, and color-coordinated daily looks. Outfit data is stored in browser storage by default and can be synchronized to PostgreSQL through the included Express API.

## Run

```sh
npm install
npm run dev
```

The frontend starts with sample pieces and planned looks. To run the API with its temporary in-memory store as well:

```sh
npm run dev:all
```

The frontend is available at `http://localhost:5173`; the API listens at `http://localhost:5174`. Vite forwards `/api` requests to the API. Browser local storage remains the fallback when the API is not running.

## PostgreSQL

Create a database, copy `.env.example` to `.env`, and set `DATABASE_URL` to its connection string. Start both services with `npm run dev:all`. The API creates the `wardrobe_state` JSONB table automatically on startup; the standalone DDL is in `server/schema.sql`. Hosted databases that require TLS can use `PGSSLMODE=require`.

## Verify

```sh
npm test
npm run build
```

Tests cover color palette scoring and API read, write, and input validation. API tests use an in-memory store and do not require PostgreSQL.

## GitHub Downloads

The workflow in `.github/workflows/build-download.yml` runs tests and builds the web app and an Android debug APK on pushes to `main`, pull requests, or manual runs. In GitHub, open the repository's **Actions** tab, select **Build and download app**, open a successful run, and download either `thread-wardrobe-android-debug` (APK) or `thread-wardrobe-web` (web build) from **Artifacts**. Artifacts are retained for 14 days. The APK is a debug build for testing and is not a signed Play Store release.

## Mobile App

The installed mobile app is a separate native Flutter application in `mobile_app/`; it does not render the Vue site in a WebView. It includes the outfit calendar, digital closet, wardrobe-based style ideas, color notes, and a live outfit preview. Data is stored on-device and can optionally sync with the Express/PostgreSQL API by building with `--dart-define=WARDROBE_API_URL=https://your-api-host`.

Install the Flutter SDK to run it locally:

```sh
cd mobile_app
flutter create --org com.thread --project-name thread_wardrobe --platforms android,ios .
flutter pub get
flutter test
flutter run
```

GitHub Actions generates a temporary Android Flutter project, runs `flutter test`, builds a native debug APK, and publishes it as the `thread-wardrobe-android-debug` artifact. The separate Vue app remains available as the web version. iOS builds require macOS and Xcode.

The web version's five-step walkthrough covers the digital closet, closet-based style ideas, outfit building with a live preview, calendar planning, and color notes. Style ideas are local wardrobe pairings, not an external AI service.
