# Collected Workflows &amp; Proofs of Concept

Description.

## Workflows

### Duden Workflow

![](assets/icons/duden.png)

Search, navigate and view information from duden.de German spelling dictionary. 

- ` shift ⇧ ` or `cmd ⌘+Y`: Get QuickLook previews for the landing page, grammar, and synonyms
- `cmd ⌘+L` to view the full entry contents.
- Action synonymes to list all synonyms. Action any synonym to view the entry for it.
- Action examples or idioms to list all that are available.

![](assets/images/preview_duden.jpg)

Download v.1.0.0 `TODO`  

**Credits**

- [SwiftSoup](https://github.com/scinfu/SwiftSoup)

### What Unicode Character is this? (ツ)_/¯

<!-- ![](assets/icons/whatisit.png) -->
<img src="assets/icons/whatisit.png" width=50, height=50> 

The *What Unicode Character is this?* workflow tells you which unicode character it is. Given a character or string, you will get the unicode code points, the scalar names and general categories.

<table> 
    <tr border-spacing=0>
        <td>
            <img src="assets/icons/whatisit.png"> 
        </td>
        <td>
            The <i>What Unicode Character is this?</i> workflow tells you which unicode character it is. Given a character or string, you will get the unicode code points, the scalar names and general categories.
        </td>
    </tr>
</table>

#### Example `ツ`

- KATAKANA LETTER TU
- `U+30C4`
- Other Letter

#### Modifiers

- `⌘ cmd` yields `\u{30C4}` (swift, ES6 formatted)
- `⌥ opt` yields `\u30C4` (python, go formatted)
- `⌃ ctrl` yields `&#x30C4;` (HTML entity)
- `⇧ shift` yields `0x30C4` (hex literal)

#### Inverse

Given a hex value either raw or in any of the above formattings will return its corresponding unicode character.
- `whatisit? \u{1F914}` yields info for 🤔


![](assets/images/preview_whatisit.jpg)

Code: Link to WhatIsIt.swift `TODO`  
Download v2.0.1 `TODO`


### Roman Numeral Converter

Convert Roman numerals to decimal and vice versa.

![](assets/images/preview_roman.jpg)

Link to RomanNumeral.swift `TODO`  
Download v.1.0.0 `TODO`

### DEVONthink ↔ PDF Expert


![](assets/icons/dt3pdf.png)

Get the DEVONthink 3 reference URL from PDF Expert, i.e. the `x-devonthink-item` page link for the active document opened in PDF Expert.

**Expected result:** `x-devonthink-item://1D7FA99A-AAFF-4883-9853-F0666A650400?page=6`


#### Known issues

- Fails for document pages that are indexed with roman numerals
- Fails for documents where the backmatter page description does not conform to the enumeration scheme
- Fails for the left-hand side document if the PDF Expert split view is enabled



## Proof of Concept & Demos

### Modifier Palettes & Double Tap Hotkeys

Proof of Concept and demo implementation of modifier palettes to invoke actions on key combinations in Alfred. 

Modifier Palette example behavior  
: `⌥+O ⌥+K` To trigger action A.  
: `⌥+I ⌥+K` To trigger action B.

Double Tap example behavior  
: `⌥+# ⌥+#` To trigger action.

Cf. Wiki `TODO`.  
Download `TODO`.


### Permission Handler

An example of how to gracefully handle permissions for your executables.  
Cf. Wiki `TODO`

