# Roblox Fonts Reference

Roblox fonts come in two categories: built-in fonts available via `rbxasset://` paths,
and cloud-hosted fonts available via `rbxassetid://` asset IDs.

## Usage

```luau
-- Built-in font
Font.new("rbxasset://fonts/families/SourceSansPro.json")

-- Cloud font (requires asset ID)
Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold)

-- From enum (legacy, maps to built-in fonts only)
Font.fromEnum(Enum.Font.Gotham)
```

## Built-in Fonts (`rbxasset://fonts/families/`)

These ship with the Roblox client and are always available:

| Font              | Path                                               |
| ----------------- | -------------------------------------------------- |
| AccanthisADFStd   | `AccanthisADFStd.json`                             |
| AmaticSC          | `AmaticSC.json`                                    |
| Arimo             | `Arimo.json`                                       |
| Balthazar         | `Balthazar.json`                                   |
| Bangers           | `Bangers.json`                                     |
| BuilderExtended   | `BuilderExtended.json`                             |
| BuilderMono       | `BuilderMono.json`                                 |
| BuilderSans       | `BuilderSans.json`                                 |
| ComicNeueAngular  | `ComicNeueAngular.json`                            |
| Creepster         | `Creepster.json`                                   |
| DenkOne           | `DenkOne.json`                                     |
| Fondamento        | `Fondamento.json`                                  |
| FredokaOne        | `FredokaOne.json`                                  |
| GothamSSm         | `GothamSSm.json` (deprecated, maps to Montserrat)  |
| GrenzeGotisch     | `GrenzeGotisch.json`                               |
| Guru              | `Guru.json`                                        |
| HighwayGothic     | `HighwayGothic.json`                               |
| Inconsolata       | `Inconsolata.json`                                 |
| IndieFlower       | `IndieFlower.json`                                 |
| JosefinSans       | `JosefinSans.json`                                 |
| Jura              | `Jura.json`                                        |
| Kalam             | `Kalam.json`                                       |
| LuckiestGuy       | `LuckiestGuy.json`                                 |
| Merriweather      | `Merriweather.json`                                |
| Michroma          | `Michroma.json`                                    |
| Montserrat        | `Montserrat.json`                                  |
| Nunito            | `Nunito.json`                                      |
| Oswald            | `Oswald.json`                                      |
| PatrickHand       | `PatrickHand.json`                                 |
| PermanentMarker   | `PermanentMarker.json`                             |
| PressStart2P      | `PressStart2P.json`                                |
| Roboto            | `Roboto.json`                                      |
| RobotoCondensed   | `RobotoCondensed.json`                             |
| RobotoMono        | `RobotoMono.json`                                  |
| RomanAntique      | `RomanAntique.json`                                |
| Sarpanch          | `Sarpanch.json`                                    |
| SourceSansPro     | `SourceSansPro.json`                               |
| SpecialElite      | `SpecialElite.json`                                |
| TitilliumWeb      | `TitilliumWeb.json`                                |
| Ubuntu            | `Ubuntu.json`                                      |
| Zekton            | `Zekton.json`                                      |

### Enum.Font Aliases

Some `Enum.Font` values map to non-obvious built-in families:

| Enum.Font | Actual Family                                    |
| --------- | ------------------------------------------------ |
| Antique   | RomanAntique                                     |
| Arcade    | PressStart2P                                     |
| Bodoni    | AccanthisADFStd                                  |
| Cartoon   | ComicNeueAngular                                 |
| Code      | Inconsolata                                      |
| Fantasy   | Balthazar                                        |
| Garamond  | Guru                                             |
| Gotham*   | GothamSSm (deprecated, falls back to Montserrat) |
| Highway   | HighwayGothic                                    |
| SciFi     | Zekton                                           |

## Cloud Fonts (`rbxassetid://`)

These are hosted on the Creator Marketplace and require asset IDs:

| Font                   | Asset ID       |
| ---------------------- | -------------- |
| Akronim                | `12187368317`  |
| Are You Serious        | `12187363616`  |
| Audiowide              | `12187360881`  |
| Barlow                 | `12187372847`  |
| Barrio                 | `12187371991`  |
| Blaka                  | `12187365104`  |
| Builder Mono (cloud)   | `16658246179`  |
| Bungee Inline          | `12187370000`  |
| Bungee Shade           | `12187367666`  |
| Caesar Dressing        | `12187368843`  |
| Cairo                  | `12187377099`  |
| Caveat                 | `12187369802`  |
| Codystar               | `12187363887`  |
| Damion                 | `12187607722`  |
| Dancing Script         | `8764312106`   |
| Eater                  | `12187372382`  |
| Faster One             | `12187370928`  |
| Finger Paint           | `12187375716`  |
| Fira Sans              | `12187374954`  |
| Frijole                | `12187375194`  |
| Fuzzy Bubbles          | `11322590111`  |
| Great Vibes            | `12187375958`  |
| Hind                   | `12187361116`  |
| Hind Siliguri          | `12187361378`  |
| IBM Plex Sans JP       | `12187364147`  |
| Inter                  | `12187365364`  |
| Irish Grover           | `12187376910`  |
| Italianno              | `12187374273`  |
| Kanit                  | `12187373592`  |
| Kings                  | `12187371622`  |
| La Belle Aurore        | `12187607116`  |
| Lato                   | `11598289817`  |
| Libre Baskerville      | `12187365769`  |
| Lobster                | `8836875837`   |
| Lora                   | `12187366657`  |
| M PLUS Rounded 1c      | `12188570269`  |
| Marhey                 | `12187364648`  |
| Monofett               | `12187606783`  |
| Monoton                | `12187374098`  |
| Montserrat (cloud)     | `11702779517`  |
| Mukta                  | `12187365559`  |
| Mulish                 | `12187372629`  |
| NanumGothic            | `12187361718`  |
| Nosifer                | `12187377325`  |
| Nothing You Could Do   | `12187367901`  |
| Noto Sans              | `12187370747`  |
| Noto Sans HK           | `12187362892`  |
| Noto Serif HK          | `12187366846`  |
| Noto Serif JP          | `12187369639`  |
| Noto Serif SC          | `12187376739`  |
| Noto Serif TC          | `12187368093`  |
| Nunito Sans            | `12187363368`  |
| Open Sans              | `11598121416`  |
| PT Sans                | `12187606934`  |
| PT Serif               | `12187606624`  |
| Pacifico               | `12187367362`  |
| Parisienne             | `12187361943`  |
| Playfair Display       | `12187374765`  |
| Poppins                | `11702779409`  |
| Prompt                 | `12187607287`  |
| Quicksand              | `12187371324`  |
| Rajdhani               | `12187375422`  |
| Raleway                | `11702779240`  |
| Roboto Slab            | `12187368625`  |
| Rubik                  | `12187365977`  |
| Rubik Burned           | `12187363148`  |
| Rubik Iso              | `12187362120`  |
| Rubik Marker Hatch     | `12187367066`  |
| Rubik Maze             | `12187366475`  |
| Rubik Wet Paint        | `12187369046`  |
| Rye                    | `12187372175`  |
| Sedgwick Ave Display   | `12187376357`  |
| Shadows Into Light     | `12187607493`  |
| Silkscreen             | `12187371840`  |
| Sono                   | `12187374537`  |
| Sono Monospace         | `12187362578`  |
| Tajawal                | `12187377588`  |
| Tangerine              | `12187376545`  |
| Teko                   | `12187376174`  |
| Unica One              | `12187364842`  |
| Work Sans              | `12187373327`  |
| Yellowtail             | `12187373881`  |

## Notes

- GothamSSm was deprecated May 2024; Enum.Font.Gotham now silently maps to
  Montserrat
- BuilderSans is Roblox's official replacement for Gotham
- There is no API to enumerate all available fonts at runtime; maintain your own
  lookup table
- `TextService:GetFamilyInfoAsync(assetId)` returns info about a specific font
  family but cannot enumerate fonts

## Error Diagnostics

- **"Temp read failed"** in Studio logs means you loaded the font with a wrong
  ID or invalid path. It does NOT mean a transient network error. Double-check
  the asset ID or rbxasset path.
- **"Font expected, got nil"** means `Font.new()` constructed successfully but
  the font could not be resolved at render time.

## Cloud Font Loading Behavior

Cloud fonts (rbxassetid://) are not bundled with the client. When first loaded:

1. Text initially renders in SourceSansPro (the fallback font)
2. The cloud font downloads in the background
3. Once downloaded, text re-renders with the correct font
4. This font swap changes text metrics (size/width), which can break layouts
   that were measured against the fallback font

To handle this, consider:
- Adding a short delay before measuring text, or re-measuring after font loads
- Using `ContentProvider:PreloadAsync()` to preload the font before rendering
- Preferring built-in fonts (rbxasset://) when possible to avoid this issue
