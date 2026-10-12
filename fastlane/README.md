# Store listings

What the App Store and Google Play show for Más Mus, in the folders fastlane's
`deliver` (App Store) and `supply` (Google Play) read, so a CI job can upload
them later. Spanish only (`es-ES`), like the app.

| Folder | What | Limits |
|---|---|---|
| `metadata/es-ES/` | App Store: `name` (30), `subtitle` (30), `promotional_text` (170), `description` (4000), `keywords` (100, comma-separated, no spaces after commas, none repeating the name), `release_notes`, support, marketing and privacy URLs | checked by `test/platform/store_listing_test.dart` |
| `screenshots/es-ES/` | App Store screenshots, iPhone 6.9" (1320 × 2868), JPEG | no alpha |
| `metadata/android/es-ES/` | Google Play: `title` (30), `short_description` (80), `full_description` (4000) | checked by the same test |
| `metadata/android/es-ES/images/` | Google Play: `phoneScreenshots/` (1080 × 1920), `featureGraphic.jpg` (1024 × 500), `icon.png` (512 × 512) | no alpha except the icon |

## The images are generated, never edited

The screenshots and the feature graphic are the app's real screens, drawn
by `test/goldens/store_test.dart`; the icon by
`test/goldens/branding_test.dart`, from the same art as the launcher icon.
Their PNGs are goldens in `test/goldens/goldens/store/`. The stores refuse
alpha, which Flutter's PNGs always carry, so a script copies them here as
JPEG. After changing a screen or a headline:

```bash
flutter test --update-goldens --tags golden test/goldens/store_test.dart test/goldens/branding_test.dart
tool/store_images.sh
```

## Filled in the consoles, not here

- Category: Juegos › Cartas (both stores).
- Price: free; no in-app purchases, no ads.
- Age rating: no gambling with real money and no simulated gambling with
  coins or prizes; nothing else to declare.
- Privacy: no data collected (App Store «Privacidad de la app», Play «Seguridad
  de los datos»), privacy policy https://masmus.larri.dev/privacy/.
- Contact: info.masmus@larri.dev.
