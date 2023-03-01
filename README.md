<!-- # Collected Workflows &amp; Proofs of Concept  -->
<!-- omit from toc -->

<h1 align="center"></br>Collected Workflows and Proofs of Concept</h1>
<!--<p align="center">
<a href="#"><img src="https://img.shields.io/static/v1?style=for-the-badge&message=Alfred&color=5C1F87&logo=Alfred&logoColor=FFFFFF&label="></a>
</p>-->

This is a collection of smaller workflows, experiments, and demonstrations of interesting concepts for writing automations with the [Alfred App](https://www.alfredapp.com/workflows/). 
If you find my workflows useful, perhaps consider reciprocating with a token of appreciation 🤗   

<a href='https://ko-fi.com/G2G1IH7RR' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>  

Some workflows live in their own repository: [Alfred Calendar++](https://github.com/zeitlings/alfred-calendar), [Set Default Browser](https://github.com/zeitlings/alfred-set-default-browser/)

---

**Table of Contents**

- [1. Workflows](#1-workflows)
  - [1.1. Duden Workflow](#11-duden-workflow)
  - [1.2. What Unicode Character is this? (ツ)\_/¯](#12-what-unicode-character-is-this-ツ_)
  - [1.3. Roman Numeral Converter](#13-roman-numeral-converter)
  - [1.4. DEVONthink `↔` PDF Expert](#14-devonthink--pdf-expert)
  - [1.5. Define Word - A Better Dictionary](#15-define-word---a-better-dictionary)
- [2. Proof of Concept \& Demos](#2-proof-of-concept--demos)
  - [2.1. Extended Hotkeys](#21-extended-hotkeys)
  - [2.2. Permission Handler](#22-permission-handler)

---

# 1. Workflows 

## 1.1. Duden Workflow

[![](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-dude)

<table> 
    <tr>
        <td>
            <img src="assets/icons/duden.png"> 
        </td>
        <td>
           Search, navigate and view information from duden.de German spelling dictionary. 
        </td>
    </tr>
</table>


- ` shift ⇧ ` or `cmd ⌘+Y`: Get QuickLook previews for the landing page, grammar, and synonyms
- `cmd ⌘+L` to view the full entry contents.
- Action synonymes to list all synonyms. Action any synonym to view the entry for it.
- Action examples or idioms to list all that are available.

![](assets/images/preview_duden.jpg)

**Credits**

- [SwiftSoup](https://github.com/scinfu/SwiftSoup)

---

## 1.2. What Unicode Character is this? (ツ)_/¯

[![](https://img.shields.io/badge/download-v2.0.1-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v2.0.1-uni)
[![](https://img.shields.io/static/v1?message=WhatIsIt.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/WhatIsIt.swift)

<table> 
    <tr>
        <td>
            <img src="assets/icons/whatisit.png"> 
        </td>
        <td>
            The <i>What Unicode Character is this?</i> workflow tells you which unicode character it is. Given a character or string, you will get the unicode code points, the scalar names and general categories.
        </td>
    </tr>
</table>

### Example `ツ`

- KATAKANA LETTER TU
- `U+30C4`
- Other Letter

### Modifiers

- `⌘ cmd` yields `\u{30C4}` (swift, ES6 formatted)
- `⌥ opt` yields `\u30C4` (python, go formatted)
- `⌃ ctrl` yields `&#x30C4;` (HTML entity)
- `⇧ shift` yields `0x30C4` (hex literal)

### Inverse

Given a hex value either raw or in any of the above formattings will return its corresponding unicode character.
- `whatisit? \u{1F914}` yields info for 🤔


![](assets/images/preview_whatisit.jpg)


---

## 1.3. Roman Numeral Converter

[![](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-rn)
[![](https://img.shields.io/static/v1?message=RomanNumeral.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/RomanNumeral.swift)


Convert Roman numerals to decimal and vice versa. Accepts Arabic numbers in the range 1 to 3999.

![](assets/images/preview_roman.jpg)

---

## 1.4. DEVONthink `↔` PDF Expert


[![](https://img.shields.io/badge/download-v2.1.1-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v2.1.1-xdev)


<table>
    <tr>
        <td>
            <img src="assets/icons/dt3pdf.png">
        </td>
        <td>
            Get either the DEVONthink 3 reference URL from PDF Expert, that is the <code>x-devonthink-item</code> page link for the active document opened in PDF Expert, the <i>selection link</i> if you have text selected, or the <i>annotation link</i> if your selection intersects an annotation and checking for annotations is enabled.
        </td>
    </tr>
</table>


The PDF, of course, has to live in one of your open DEVONthink databases. 
- `cmd ⌘` to open the PDF on the same page in DEVONthink
- `.xdev` to enable or disable opening the document in DEVONthink when using the hotkey

**Expected result A**  
`x-devonthink-item://1D7FA99A-AAFF-4883-9853-F0666A650400?page=6`  
**Expected result B**  
`x-devonthink-item://1D7FA99A-AAFF-4883-9853-F0666A650400?page=6&start=66&length=9&search=selection`  
**Expected result C**  
`x-devonthink-item://1D7FA99A-AAFF-4883-9853-F0666A650400?page=6&annotation=Squiggly&x=212&y=406`

### Known issues

- Fails with documents opened in PDF Expert split view



https://user-images.githubusercontent.com/25689591/218268102-3c07c799-4906-4d2b-9e55-38691f6b0a34.mp4


<!-- https://user-images.githubusercontent.com/25689591/216837085-fa114af5-ab98-4c1c-a866-a44725b4578a.mp4 -->

<!--
<details>
  <summary>Expand to watch a preview 👓</summary>

  https://user-images.githubusercontent.com/25689591/216837085-fa114af5-ab98-4c1c-a866-a44725b4578a.mp4

</details>    
-->

## 1.5. Define Word - A Better Dictionary

[![](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-dict)

<table>
    <tr>
        <td>
            <img src="assets/icons/dict.png">
        </td>
        <td>
            Customizable Dictionary with Preview - and Dark Mode.
        </td>
    </tr>
</table>

- `shift` or `cmd+Y` to preview the dictionary entry  
- `cmd+C` to copy the dictionary entry's plain text to the clipboard  
- `cmd+L` to view the plain text as large type 

You can define fallback dictionaries for lookups, set the font size of previews, search for synonymes, or manually select a dictionary to use.

![](assets/images/dict-dark.jpg)



---

# 2. Proof of Concept & Demos

<!-- ![WIP](https://img.shields.io/static/v1?style=for-the-badge&message=WIP&color=F00&logo=Alfred&logoColor=FFFFFF&label=) -->

## 2.1. Extended Hotkeys


<a href="https://github.com/zeitlings/alfred-workflows/releases/tag/v0.0.1-eh"><img src="https://img.shields.io/badge/download-v0.0.1-informational"></a>

__Modifier Palettes & Double Tap Hotkeys.__ Proof of concept and demo implementation of modifier palettes to invoke actions on consecutive keystrokes in Alfred.

Modifier Palette example behavior. 
- `⌥O`, `⌥K` To trigger action A.  
- `⌥I`, `⌥K` To trigger action B.

Double-Tap Hotkey example behavior  
- `⌃+`, `⌃+` To trigger action.

### Some Details

The core idea is to inject environment variables into the workflow configuration and to modify them with some delay.


- To set up modifier palettes, all you have to do is define an identifier on any hotkey, `⌥O`, such as "`openA`". This is the "text" argument that the hotkey passes on as `{query}`. Set the identifier to some *environment* variable, say "`gate`", and use a downstream `conditional object` triggered by a different hotkey, `⌥K`, to check if the variable (`{var:gate}`) is equal to the identifier `openA`. Any action that you make depend on this condition will be triggered iff `gate` is equal to `openA`, i.e. if you have recently tapped the hotkey associated with the identifier.

- To set up double-tap hotkeys, proceed in the same way, defining an identifier for the hotkey's "text" argument. For each double tap hotkey, an environment variable is injected that is either `0` or `1` for inactive or active. 
	

`Disclaimer`: Alfred may crash if you get the timing of the keystrokes just right. This is due to a data race where the same variable ("`gate`") is accessed and modified by different threads at the same time. Also, for the double-tap hotkeys, there is some "bleed" into the other hotkeys with the way it is set up in the demo. Tapping a, then b, will also trigger b, instead of having to tap b twice.

![](assets/images/preview_extended.jpg)


---

## 2.2. Permission Handler 

An example of how to handle permissions gracefully for your executables. (For now, take a look at the *Duden Workflow* that implements the permission handler).

