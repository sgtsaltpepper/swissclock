# MondaineSaver

Mondaine-inspirert macOS-skjermsparer bygget som en ekte `.saver`-bundle med AppKit og `ScreenSaver`-framework.

## Bygg

```bash
xcodebuild -project MondaineSaver.xcodeproj -target MondaineSaver -configuration Release build
```

Det ferdige bundle-produktet havner i Xcode sin `DerivedData`-mappe, som `MondaineRailClock.saver`.

## Lokal preview

For å teste samme klokkevisning uten `ScreenSaver`-cache, bygg preview-appen:

```bash
xcodebuild -project MondaineSaver.xcodeproj -target MondainePreview -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/MondainePreview.app
```

Preview-appen bruker samme klokkemodell og renderer som `.saver`-targeten, og viser debug-overlay som standard.

## Installer lokalt

Kopier `MondaineSaver.saver` til én av disse mappene:

- `~/Library/Screen Savers/`
- `/Library/Screen Savers/`

Deretter kan den velges i System Settings > Screen Saver.
