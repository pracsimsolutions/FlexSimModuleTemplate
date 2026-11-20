# FlexSimModuleTemplate

A bare starting point for a FlexSim module. It builds, loads, and has one FlexScript method you can call:

```
FlexSimModuleTemplate.helloWorld(42);
```

Everything else is up to you.

Made for **FlexSim 2027 or later** and **Visual Studio 2026 or later**.

## Before you start

- FlexSim 2027+
- Visual Studio 2026+ with the "Desktop development with C++" workload
- This folder must sit inside your FlexSim install, at `<FlexSim 2027>\modules\`. The build copies FlexSim's headers from the install's `program\system` folder, so it won't work from anywhere else.
- Read FlexSim's [Module SDK quick start](https://help.autodesk.com/view/FLEXSIMIN/2027/ENU/?guid=FlexSim_User_Manual_reference_developeradvanceduser_modulesdk_quickstart_html). It covers the FlexSim settings you need for module development.

The repo has no `.dll` and no `.t` file, on purpose. You generate both (steps 3 and 4).

## Getting started

1. **Rename it (optional).** Run `scripts\rename-module.bat MyModule`. It renames the files and the names inside them. Then rename this folder to `MyModule` too. The folder name has to match the module name, or FlexSim won't find it.
2. **Close FlexSim** if it's open. It locks the `.dll`.
3. **Build the DLL.** Run `scripts\build-module.bat`. This creates `MyModule.dll` in the module folder.
4. **Create the `.t` file.** Open FlexSim, then go to **File > Save Defaults**. This creates `MyModule.t`. FlexSim loads the `.t` file, not the `.fsx`.
5. **Restart FlexSim.** Open the script console and run:
   ```
   print(MyModule.helloWorld(42));
   ```
   If you didn't rename it, use `FlexSimModuleTemplate` instead of `MyModule`.

After you change any C++, repeat steps 2 and 3. After you change the `.fsx`, repeat step 4.

## What's in the folder

| Path | What it is |
|---|---|
| `FlexSimModuleTemplate.fsx` | The module's tree, in text form. It tells FlexSim what to add (a library, the `helloWorld` interface). Save Defaults turns it into the `.t`. |
| `FlexSimModuleTemplateDLL\` | The C++ project. Open `FlexSimModuleTemplate.sln` in Visual Studio if you prefer to build there. |
| `FlexSimModuleTemplateDLL\FlexSimModuleTemplate.cpp / .h` | The `helloWorld` method. Copy this pattern to add more. |
| `FlexSimModuleTemplateDLL\module.cpp` | The entry points FlexSim calls when it loads the DLL. |
| `scripts\` | Helper scripts, listed below. |

## Scripts

| Script | What it does |
|---|---|
| `build-module.bat` | Builds the DLL. Add a version, like `build-module.bat 27.0.1`, to run `update-module-version` first. |
| `rename-module.bat` | Renames the module everywhere except the folder itself. |
| `update-module-version.bat` | Sets the module's version in the `.fsx` (`update-module-version.bat 27.0.1`). The template starts without a version. The script adds the `release`, `revision` and `flexsim release` nodes the first time, and updates them after that. Redo Save Defaults afterwards. |
| `package-module.bat` | Zips up what you want to send to someone. See below. |

## Packaging

Use this when you want to send the module to someone without sending your source.

Run `scripts\package-module.bat`. It makes `dist\MyModule.zip` containing:

- `MyModule.dll` and `MyModule.t`, always. They're listed in `scripts\package-list.txt` as an example, but they'd be included even if you deleted those lines.
- anything else you list in `scripts\package-list.txt`

It stops with a message if the `.dll` or `.t` is missing. Build and Save Defaults first.

Nothing else goes in the zip. The `.fsx`, the C++ source and the `.sln` stay out unless you list them.

### Adding files

If your module needs other files, like bitmaps, add them to `scripts\package-list.txt`. One path per line, relative to the module folder:

```
bitmaps
help\guide.pdf
data\*.csv
```

- A **file** adds that file.
- A **folder** adds everything inside it, including folders inside folders. `bitmaps` above also picks up `bitmaps\icons\small\a.bmp`.
- A **pattern** like `*.csv` adds every match.
- Lines starting with `#` are ignored.
- A path that doesn't exist stops the script, so typos don't slip through. Paths outside the module folder aren't allowed.

Folder structure is kept inside the zip.

### Using the zip

Unzip it into `<FlexSim 2027>\modules\`. The zip already has a `MyModule` folder in it. Restart FlexSim.

## Links

- [FlexSim Module SDK quick start](https://help.autodesk.com/view/FLEXSIMIN/2027/ENU/?guid=FlexSim_User_Manual_reference_developeradvanceduser_modulesdk_quickstart_html)
