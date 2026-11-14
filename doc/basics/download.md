# Download

Offer a stored file to the user with `Storage.download`: the share sheet on mobile and desktop, a browser download on the web.

- [Basic Usage](#basic-usage)
- [Quick Reference](#quick-reference)
- [How the Handler Works](#how-the-handler-works)
- [Without the Plugin](#without-the-plugin)
- [Gotchas](#gotchas)
- [Related Documentation](#related-documentation)

<a name="basic-usage"></a>
## Basic Usage

```dart
import 'package:magic/magic.dart';

Future<void> main() async {
  await Storage.download('reports/2024.pdf', name: 'Annual Report.pdf');
}
```

`Storage` is core's facade. `magic_picker` supplies the part core cannot ship, the share sheet, by registering `PickerServiceProvider`. Register it once in `lib/config/app.dart` (the installer does) and the call above works on every platform.

<a name="quick-reference"></a>
## Quick Reference

| Platform | What `Storage.download` does |
|:---------|:-----------------------------|
| Mobile and desktop | Calls `LocalAdapterContract.downloadHandler`, which `PickerServiceProvider` sets to open the share sheet. |
| Web | Triggers a browser download. The handler is never called. |

The `name` argument is the file name offered to the user. Without it the file's own base name is used.

<a name="how-the-handler-works"></a>
## How the Handler Works

`LocalAdapterContract.downloadHandler` is a static `Future<void> Function(String fullPath, String name)?` in core. `PickerServiceProvider.boot()` assigns it, so the share sheet is wired after `Magic.init` has booted the providers. The handler shares the stored file through `share_plus` and passes `name` as the file name override, because `XFile` ignores its `name` on IO and would otherwise offer the path's base name.

`PickerServiceProvider` takes an optional `share` callback that replaces the share sheet. It exists for tests, where there is no platform channel to answer; see [Testing](../guides/testing.md).

<a name="without-the-plugin"></a>
## Without the Plugin

On mobile and desktop `download` throws `UnsupportedError` while no handler is set. The message names `magic_picker`:

```text
Storage download on IO platforms needs a handler. Install magic_picker or set LocalAdapterContract.downloadHandler.
```

Install the plugin, or assign your own handler, for example one that copies the file to a folder you choose. A file that does not exist makes `download` throw an `Exception` before the handler is reached.

<a name="gotchas"></a>
## Gotchas

| Mistake | Fix |
|:--------|:----|
| Calling `Storage.download` on mobile or desktop without the plugin | Register `PickerServiceProvider`, or set `LocalAdapterContract.downloadHandler` yourself. |
| Expecting the handler to run on the web | The web adapter downloads through the browser and ignores it. |
| Assigning your own handler before `Magic.init` finishes | `PickerServiceProvider.boot()` runs during init and overwrites it. Assign yours after boot. |
| Downloading a path that was never stored | `download` throws an `Exception` saying the file was not found. |

<a name="related-documentation"></a>
## Related Documentation

- [Pick](./pick.md): picking the file that you later store.
- [XFile Conversion](./xfile.md): the `XFile` the share sheet receives.
- [Testing](../guides/testing.md): recording share calls and resetting the handler.
