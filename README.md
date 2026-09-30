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

The Ionic Vue app is configured with Capacitor for Android and iOS. Generate a native project and sync the current web build with `npm run mobile:add:android` or `npm run mobile:add:ios`, then use `npm run mobile:android` or `npm run mobile:ios` to open it in the platform IDE. Android builds require Android Studio and its SDK. iOS builds require macOS and Xcode. After web changes, run `npm run mobile:sync` to build and sync the native projects.

The five-step first-run tour covers the digital closet, closet-based style ideas, outfit building with a live preview, calendar planning, and color notes. It can be replayed from the help icon in the app header. Style ideas are local wardrobe pairings, not an external AI service. Pages and garment pickers scroll independently on touch and desktop layouts.
