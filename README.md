<h1 align="center">
	<a href='#'><img src='https://img.shields.io/static/v1?style=for-the-badge&message=Alfred&color=fff&logo=Alfred&logoColor=000&label=' style='border:0px;height:36px;' /></a>
	</br>Collected Workflows
</h1>

This is a collection of smaller workflows, experiments, and demonstrations of interesting concepts for writing automations with the [Alfred App](https://www.alfredapp.com/workflows/). 
<!-- If you find my workflows useful, perhaps consider reciprocating with a token of appreciation 🤗 -->  

__Some workflows live in their own repository:__  
- [µBib | Citations, BibTeX, and Research](https://github.com/zeitlings/ubib)
- [Quill | Text processing utility](https://github.com/zeitlings/alfred-quill) 
- [Ayai · GPT Nexus (preview)](https://github.com/zeitlings/ayai-gpt-nexus)
- [DEVONthink 3 Portal](https://github.com/zeitlings/alfred-devonthink) 
- [Logseq Workflow](https://github.com/zeitlings/alfred-logseq)
- [Ollama Workflow](https://github.com/zeitlings/alfred-ollama)
- [Default Browser](https://github.com/zeitlings/alfred-set-default-browser/)
- [Unified Search](https://github.com/zeitlings/alfred-unified-search) <img src="https://img.shields.io/badge/new-FFFFFF?style=flat-square&logo=alfred&logoColor=424242" />
- [Calendar++](https://github.com/zeitlings/alfred-calendar) 

<!--
<table align="center">
    <td>
        <a href='https://ko-fi.com/G2G1IH7RR' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>  
    </td>
    <td>
        <p>
            Some workflows live in their own repository:<br>
            <a href="https://github.com/zeitlings/alfred-devonthink">DEVONthink 3 Portal</a> |
            <a href="https://github.com/zeitlings/alfred-calendar">Calendar++</a> |
            <a href="https://github.com/zeitlings/alfred-set-default-browser/">Default Browser</a>
        </p>
    </td>
</table>
-->

<a href='https://ko-fi.com/G2G1IH7RR' target='_blank'><img height='36' align='right' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>  

---

**Table of Contents**

- [1. Workflows](#1-workflows)
  - [1.1. Duden Workflow](#11-duden-workflow)
  - [1.2. What Unicode character is this?](#12-what-unicode-character-is-this)
  - [1.3. Roman Numeral Converter](#13-roman-numeral-converter)
  - [1.4. DEVONthink ←→ PDF Expert](#14-devonthink--pdf-expert)
  - [1.5. Define Word - A Better Dictionary](#15-define-word---a-better-dictionary)
  - [1.6. AlfredOCR](#16-alfredocr)
  - [1.7. Favorites](#17-favorites)
  - [1.8. New File](#18-new-file)
  - [1.9. Keyboard Brightness](#19-keyboard-brightness)
  - [1.10. GIF from Video](#110-gif-from-video)
  - [1.11. Bluetooth Device Battery](#111-bluetooth-device-battery)
  - [1.12. QResolve](#112-qresolve)
  - [1.13. GIF from Images](#113-gif-from-images)
  - [1.14 Extract Keywords](#114-extract-keywords)
  - [1.15 Color Picker](#115-color-picker)
  - [1.16 PDF to Text](#116-pdf-to-text)
  - [1.17 PDF Split](#117-pdf-split)
  - [1.18 PDF Compress](#118-pdf-compress)
  - [1.19 Scratchpad](#119-scratchpad)
  - [1.20 Window Navigator](#120-window-navigator)
  - [1.21 Fuzzy Search](#121-fuzzy-search)
  - [1.22 PDF to Table](#122-pdf-to-table)
- [2. Proof of Concept \& Demos](#2-proof-of-concept--demos)
  - [2.1. Extended Hotkeys](#21-extended-hotkeys)
  - [2.2. Permission Handler](#22-permission-handler)
  - [2.3. GUI Input Experiment](#23-gui-input-experiment)
  - [2.4. Heads-up Display](#24-heads-up-display)

---

# 1. Workflows 

## 1.1. Duden Workflow

[![Download button for workflow: Duden workflow](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-dude)

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

<img src="assets/images/preview_duden.png" width="564px" />

**Credits:**  [SwiftSoup](https://github.com/scinfu/SwiftSoup)

---
<!-- What Unicode Character is this? (ツ)_/¯ -->
## 1.2. What Unicode character is this?

[![Download button for workflow: What Unicode character is this?](https://img.shields.io/badge/download-v2.0.2-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v2.0.2-uni)
[![Swift source code button for workflow: What Unicode character is this?](https://img.shields.io/static/v1?message=WhatIsIt.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/WhatIsIt.swift)

<table> 
    <tr>
        <td>
            <img src="assets/icons/whatisit.png"> 
        </td>
        <td>
            The <i>What Unicode character is this?</i> workflow tells you which unicode character it is. Given a character or string, you will get the unicode code points, the scalar names and general categories.
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


<img src="assets/images/preview_whatisit.png" width="564px" />


---

## 1.3. Roman Numeral Converter

[![Download button for workflow: Roman Numeral Converter](https://img.shields.io/badge/download-v1.2.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.2.0-rn)
[![Swift source code button for workflow: Roman Numeral Converter](https://img.shields.io/static/v1?message=RomanNumeral.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/RomanNumeral.swift)


<table>
    <tr>
        <td>
            <img src="assets/icons/rn.png" width="170px">
        </td>
        <td>
            Convert Roman numerals to decimal and vice versa. Accepts Arabic numbers in the range 1 to 3999.
        </td>
    </tr>
</table>

<img src="assets/images/preview_roman.png" width="550px" />

---

## 1.4. DEVONthink ←→ PDF Expert


[![Download button for workflow: DEVONthink to PDF Expert](https://img.shields.io/badge/download-v2.1.2-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v2.1.2-xdev)


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

[![Download button for workflow: Define Word - A Better Dictionary](https://img.shields.io/badge/download-v1.2.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.2.0-dict)

<table>
    <tr>
        <td>
            <img src="assets/icons/dict.png">
        </td>
        <td>
            Customizable Dictionary with Quicklook Preview - and Dark Mode.
        </td>
    </tr>
</table>

`shift` or `cmd+Y` to preview the dictionary entry  
`ctrl` to see the dictionary associated with the entry  
`cmd + ⏎` to paste a word to the frontmost application (spell checker)  
`cmd+C` to copy the dictionary entry's plain text to the clipboard  
`cmd+L` to view the plain text as Large Type  

You can define dictionaries for lookups, set the font size of the previews, or manually select a dictionary to use. The previews reflect the global appearance, i.e. they have a dark mode. The workflow also includes a preset for looking up synonyms of a word and a convenient keyboard shortcut for quick lookups. To use the workflow as a multilingual spell checker, you can use the `cmd` modifier when actioning the entry to paste the word to the frontmost application.

<img src="assets/images/preview-dict.png" width="650px"/>


## 1.6. AlfredOCR

_No external dependencies are required to perform the OCR._

### 1.6.1 Alfred OCR Light

[![Download button for workflow: Alfred OCR Light](https://img.shields.io/badge/download-v1.3.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.3.0-ocr)
[![Swift source code button for workflow: Alfred OCR Light](https://img.shields.io/static/v1?message=AlfredOCR.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/AlfredOCR.swift)

<table>
    <tr>
        <td>
            <img src="assets/icons/ocr.png" />
        </td>
        <td>
            The workflow allows you to <b>copy text from images</b> using optical character recognition. Take a snapshot with your mouse or trackpad and the recognized text is automatically copied to the clipboard.<br>You can also extract text from images sent to the workflow's <a href="https://www.alfredapp.com/help/workflows/triggers/file-action/">File Action</a>.
        </td>
    </tr>
</table>

<img src="assets/images/preview_ocr_snapshot.gif" width="800"/>

### 1.6.2 Alfred OCR+

[![Download button for workflow: Alfred OCR+](https://img.shields.io/badge/download-v1.4.1-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.4.1-ocr2)

<table>
    <tr>
        <td>
            <img src="assets/icons/ocr+.png" />
        </td>
        <td>
            The workflow allows you to <strong>copy text from images</strong>, or to <strong>convert PDF files into searchable PDF documents</strong> using optical character recognition, and to apply compression to PDF documents.
        </td>
    </tr>
</table>

__1 / Snapshot__  
Take a snapshot with your mouse or trackpad and the recognized text is automatically copied to the clipboard. 
- Default shortcut: <kbd>⌘</kbd> <kbd>⇧</kbd> <kbd>6</kbd>
- Default keyword: `ocr`


__2 / PDF Document__

- To convert a PDF into a searchable PDF document, pass it to the workflow's *[Universal Action](https://www.alfredapp.com/help/features/universal-actions/)*.
	- To compress the resulting PDF, pass the source document on while pressing the **⌘+⇧** keys.
	- To open the resulting PDF, pass the source document on while pressing the **⌥+⇧** keys.
	- To force the replacement of a source document, pass it on while pressing the **⌥+⌘** keys.

- To compress a PDF without performing OCR, pass it to the `Compress PDF Document` File Action.
- To view the **progress tracker**, re-enable the workflow with the `Keyword` (default: `ocr`).

<img src="assets/images/preview_ocr1.png" width="564px" />
<img src="assets/images/preview_ocr2.png" width="564px" />
<img src="assets/images/preview_ocr3.png" width="564px" />


## 1.7. Favorites

[![Download button for workflow: Favorites](https://img.shields.io/badge/download-v1.1.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.1.0-fav)


<table>
    <tr>
        <td>
            <img src="assets/icons/fav.png">
        </td>
        <td>
            <p>Add files and folders to your list of favorites by using the workflow's <a href="https://www.alfredapp.com/help/features/universal-actions/">Universal Action</a>. Quickly find them again by activating the workflow with the <code>Keyword</code> (default: <code>fav</code>) or by setting a hotkey of your choice.</p>
        </td>
    </tr>
</table>


<img src="assets/images/preview_fav.png" width="564px">


- Hit `enter` or `cmd+O` to open a file or folder.
- Add items with the workflow’s [Universal Action](https://www.alfredapp.com/help/features/universal-actions/).
- **Modifiers:**
	- `ctrl`: Show full Path
	- `cmd`: Reveal in Finder
	- `opt`: Browse in Alfred
	- `cmd+shift`: Move up
	- `opt+shift`: Move down
	- `fn`: Remove from Favorites
	- `shift` or `cmd+Y`: Quicklook Preview


## 1.8. New File

[![Download button for workflow: New File](https://img.shields.io/badge/download-v1.3.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.3.0-nf)


<table>
    <tr>
        <td>
            <img src="assets/icons/nf.png" />
        </td>
        <td>
            <p>The workflow allows you to quickly create new files in the Finder.</p>
            <p>If the <em>post-haste</em> behavior is enabled, new files are created the same way as folders are when you use the shortcut (default: <code>⌥+⇧+N</code>). Otherwise you will be prompted with the input mask where you can configure the file name and type.</p>        
        </td>
    </tr>
</table>

The workflow will pick up on your location in the Finder and create the new file there. If you use the keyword, the most recently used Finder window will be selected as the destination. If no Finder window is currently open, the file will be created in the configurable fallback location.

__Bonus:__ In addition to all plain-text type files, the workflow can also quickly create `docx`, `doc`, `odt`, `rtf` and `rtfd` documents and Xcode `playground`s.

<img src="assets/images/preview_nf.gif" width="600px"/>


__Creating a new file__
- <kbd>⌘</kbd> to view the full path to the target folder.
- <kbd>↩</kbd> to create the file with configured settings.
- <kbd>⌘</kbd><kbd>⇧</kbd><kbd>↩</kbd> to create the file **with clipboard** contents.
- <kbd>⌥</kbd><kbd>⇧</kbd><kbd>↩</kbd> to create the file **without clipboard** contents.

If auto-suggest is enabled, press <kbd>TAB</kbd> to accept and expand the suggested filename. (new in v1.2.0)


## 1.9. Keyboard Brightness

[![Download button for workflow: Keyboard Brightness](https://img.shields.io/badge/download-v1.1.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.1.0-kbr)
[![Swift source code button for workflow: Keyboard Brightness](https://img.shields.io/static/v1?message=Incandescent.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/Incandescent.swift)

<table>
    <tr>
        <td>
            <img src="assets/icons/keybr.png" width="170px">
        </td>
        <td>
            <p>Adjust the keyboard backlight brightness either by using the keyword or by setting up custom shortcuts.</p>
            <p>When using the keyword
                <ul>
                <li> type <kbd>></kbd> or <kbd>+</kbd> to increase the brightness</li>
                <li> type <kbd><</kbd> or <kbd>-</kbd> to decrease the brightness</li>
                </ul>
            </p>
        </td>
    </tr>
</table>

<img src="assets/images/preview_keybr.gif" width="600px"/>


## 1.10. GIF from Video

[![Download button for workflow: GIF from Video](https://img.shields.io/badge/download-v1.1.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.1.0-gif)

<table>
    <tr>
        <td>
            <img src="assets/icons/gif.png" width="256px">
        </td>
        <td>
            <p>The workflow allows you to convert video of popular formats to animated GIFs. To do this, it uses <a href="https://ffmpeg.org/">ffmpeg</a> as a dependency.</p>
        </td>
    </tr>
</table>

### Usage

Either send a video to the workflow's [*File Action*](https://www.alfredapp.com/help/workflows/triggers/file-action/) or invoke the workflow using the keyword and search for the video file you want to convert. Then select the image size you want the resulting GIF to have from the list to start the conversion.

<img src="assets/images/preview_gif1.png" width="564px"/>
<img src="assets/images/preview_gif2.png" width="564px"/>


## 1.11. Bluetooth Device Battery

[![Download button for workflow: Bluetooth Device Battery](https://img.shields.io/badge/download-v1.1.2-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.1.2-btb)
[![Swift source code button for workflow: Bluetooth Device Battery](https://img.shields.io/static/v1?message=DeviceBattery.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/DeviceBattery.swift)

<table>
    <tr>
        <td><img src="assets/icons/btb.png" width="128px"></td>
        <td>View the battery charge status of connected Bluetooth devices<br>(macOS 13.0+). Install Apple's <a href="https://developer.apple.com/fonts/">SF Pro font</a> to see the icons.</td>
    </tr>
</table>

<img src="assets/images/preview_btb.png" width="564" >

## 1.12. QResolve

[![Download button for workflow: QResolve](https://img.shields.io/badge/download-v1.1.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.1.0-qr)
[![Swift source code button for workflow: QResolve](https://img.shields.io/static/v1?message=QResolve.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/QResolve.swift)

<table>
    <tr>
        <td><img src="assets/icons/qresolve.png" width="128px"></td>
        <td>Resolve and open links from QR codes</td>
    </tr>
</table>

### Usage

**A /** Take a snapshot of the QR code you want to open the link to
- Default keyword: `qrr`
- Recommended shortcut: **⌘+⇧+7**

**B /** Send an image containing the QR code to the workflow's [File Action](https://www.alfredapp.com/help/workflows/triggers/file-action/)

<img src="assets/images/preview-qrr-1.png" width="564" >
<img src="assets/images/preview-qrr-2.png" width="564" >


## 1.13. GIF from Images

[![Download button for workflow: GIF from Images](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-gif2)

<table>
    <tr>
        <td>
            <img src="assets/icons/gif2.png" width="256px">
        </td>
        <td>
            <p>
            The workflow allows you to convert a series of still images into animated GIFs. For this, it uses <a href="https://imagemagick.org/">ImageMagick</a> as a dependency.
        </td>
    </tr>
</table>

### Usage

Send a series of still images to the workflow's [*File Action*](https://www.alfredapp.com/help/workflows/triggers/file-action/) to create an animated GIF. The smallest image determines the dimensions of the result. All source images are assumed to be of the same file type, e.g. jpg or png.

<img src="assets/images/preview_gif3.png" width="564px"/>

## 1.14 Extract Keywords

[![Download button for workflow: Extract Keywords](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-kw)

<table>
    <tr>
        <td>
            <img src="assets/icons/kw.png" width="200px">
        </td>
        <td>
            <p>
            Extract keywords and keyphrases from articles, books or other documents with <a href="https://github.com/LIAAD/yake/">YAKE!</a>
        </td>
    </tr>
</table>

### Usage

- Send `PDF`, `docx`, `doc`, `rtf` or `txt` documents to the workflow's File Actions
- Pass the text from your selection in macOS on to the workflow's Universal Action
- Use the keyword and paste your text (default: `kw`) 

### Dependencies

The workflow relies on **Python3** to install the YAKE standalone.

#### YAKE!
- `pip install git+https://github.com/LIAAD/yake` 
- [official installation guide](https://github.com/LIAAD/yake/#option-3-standalone-installation-for-development-or-integration)

#### pdftotext
- `brew install poppler` 
- [formula on brew.sh](https://formulae.brew.sh/formula/poppler)

<img src="assets/images/preview_kw1.png" width="564px"/>
<img src="assets/images/preview_kw2.png" width="564px"/>

## 1.15 Color Picker

[![Download button for workflow: Color Picker](https://img.shields.io/badge/download-v1.3.3-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.3.3-cp) [![Swift source code button for workflow: Color Picker](https://img.shields.io/static/v1?message=ColorPicker.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/ColorPicker.swift)

<table>
    <tr>
        <td>
            <img src="assets/icons/cp.png" width="150px">
        </td>
        <td>
            <p>Pick a color to get its hex, rgba, hsl representation or NSColor initializer.</p>
        </td>
    </tr>
</table>

### Usage 

Activate the *Color Sampler* with the keyword (default: `cp`) and pick the desired color.

<img src="assets/images/preview_cp.png" width="564px"/>

### Color History

To review previously picked colors, activate the workflow with the keyword preceded by a colon (default: `:cp`).

<img src="assets/images/preview_cp2.png" width="564px"/>


## 1.16 PDF to Text

[![Download button for workflow: PDF to Text](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-pdftotext)

<table>
    <tr>
        <td>
            <img src="assets/icons/pdftotext.png" width="150px">
        </td>
        <td>
            Extract text from PDF documents.
        </td>
    </tr>
</table>


### Usage

Extract the entire text from one or more PDFs by sending them to the workflow's [File Action](https://www.alfredapp.com/help/workflows/triggers/file-action/) or locate a PDF with the [File Filter](https://www.alfredapp.com/help/workflows/inputs/file-filter/) by using the keyword (default: `pdftotext`). To extract the text from specific pages of a single document, use the <kbd>⌘</kbd> modifier. The result will be exported as a plain text document.

#### File Filter

<img src="assets/images/preview_pdftotext-1.png" width="564px"/>

- <kbd>↩</kbd> Proceed to extract the entire text.
- <kbd>⌘</kbd><kbd>↩</kbd> Proceed by specifing the pages to extract.
- <kbd>⌃</kbd><kbd>↩</kbd> Proceed, push the result to the [File Buffer](https://www.alfredapp.com/help/features/file-search/#file-buffer) and [action it in Alfred](https://www.alfredapp.com/help/features/universal-actions/).


#### File Action

<img src="assets/images/preview_pdftotext-2.png" width="564px"/>

- <kbd>↩</kbd> Proceed to extract the entire text.
- <kbd>⌘</kbd><kbd>↩</kbd> Proceed by specifing the pages to extract (single file only).
- <kbd>⌃</kbd><kbd>↩</kbd> Proceed, push the result(s) to the [File Buffer](https://www.alfredapp.com/help/features/file-search/#file-buffer) and [action them in Alfred](https://www.alfredapp.com/help/features/universal-actions/).

#### Specifying the Pages

<img src="assets/images/preview_pdftotext-3.png" width="564px"/>

- <kbd>↩</kbd> Proceed to extract text from the specified pages.
- <kbd>⌘</kbd><kbd>↩</kbd> Preview the first and last PDF pages w/ Alfred's PDF View.
- <kbd>⌥</kbd><kbd>↩</kbd> Preview the contents of the first and last page w/ Alfred's Text View.
- <kbd>⌃</kbd><kbd>↩</kbd> Proceed, push the result to the [File Buffer](https://www.alfredapp.com/help/features/file-search/#file-buffer) and [action it in Alfred](https://www.alfredapp.com/help/features/universal-actions/).

<img src="assets/images/preview_pdftotext-4.png" width="564px"/>

Press <kbd>↩</kbd> to return to the view where you can set the start and end pages.

<img src="assets/images/preview_pdftotext-5.png" width="564px"/>

### Dependencies

- With [Homebrew](https://brew.sh/) install
- Poppler: `brew install poppler`


## 1.17 PDF Split

[![Download button for workflow: PDF Split](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-pdfsplit)

<table>
    <tr>
        <td>
            <img src="assets/icons/pdfsplit.png" width="150px">
        </td>
        <td>
            Easily extract a specific page range from an existing PDF document and create a new PDF file with the selected pages.
        </td>
    </tr>
</table>

### Usage

Either invoke the workflow by using the keyword (default: `pdfsplit`) and locate a PDF, or send a PDF to the workflow's [File Action](https://www.alfredapp.com/help/workflows/triggers/file-action/). Specify the start and end pages of the range you want to be extracted. The specified first and last page can be previewed by pressing the <kbd>⌘</kbd> modifier. 

<img src="assets/images/preview_pdfsplit-1.png" width="564px"/>
<img src="assets/images/preview_pdfsplit-2.png" width="564px"/>

#### Specifying the Pages

<img src="assets/images/preview_pdfsplit-3.png" width="564px"/>

- <kbd>↩</kbd> Proceed to extract text from the specified pages.
- <kbd>⌘</kbd><kbd>↩</kbd> Preview the first and last PDF pages w/ Alfred's PDF View.
- <kbd>⌥</kbd><kbd>↩</kbd> Proceed, push the result to the [File Buffer](https://www.alfredapp.com/help/features/file-search/#file-buffer) and [action it in Alfred](https://www.alfredapp.com/help/features/universal-actions/).

<img src="assets/images/preview_pdfsplit-4.png" width="564px"/>

Press <kbd>↩</kbd> to return to the view where you can set the start and end pages.

### Dependencies

- With [Homebrew](https://brew.sh/) install
- Poppler: `brew install poppler`


## 1.18 PDF Compress

[![Download button for workflow: PDF Compress](https://img.shields.io/badge/download-v1.0.1-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.1-pdfcompress)

<table>
    <tr>
        <td>
            <img src="assets/icons/pdfcompress.png" width="150px">
        </td>
        <td>
            Compress PDF documents.
        </td>
    </tr>
</table>

### Usage


Either invoke the workflow by using the keyword (default: `pdfcompress`) and locate a PDF, or send a PDF to the workflow's "Compress PDF Document" [File Action](https://www.alfredapp.com/help/workflows/triggers/file-action/). 

A compression preset can be selected by pressing <kbd>⌥</kbd> before proceeding with <kbd>↩</kbd>. 

#### File Filter

<img src="assets/images/preview_pdfcmpr-1.png" width="564px"/>

- <kbd>↩</kbd> Proceed to compress the PDF using the default strategy.
- <kbd>⌥</kbd><kbd>↩</kbd> Select a compression preset.

#### File Action

<img src="assets/images/preview_pdfcmpr-2.png" width="564px"/>

- <kbd>↩</kbd> Proceed to compress the PDF using the default strategy.
- <kbd>⌥</kbd><kbd>↩</kbd> Select a compression preset.

#### Compression Presets

<img src="assets/images/preview_pdfcmpr-3.png" width="564px"/>

- <kbd>↩</kbd> Proceed to compress the PDF using the selected strategy.


The result will be a compressed document in the same location as the source PDF file.


### Dependencies

- With [Homebrew](https://brew.sh/) install
- Ghostscript: `brew install gs`



## 1.19 Scratchpad

[![Download button for workflow: Scratchpad](https://img.shields.io/badge/download-v1.2.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.2.0-pad)

<table>
    <tr>
        <td>
            <img src="assets/icons/pad.png" width="150px">
        </td>
        <td>
            <p>
            Quickly access up to 9 scratchpads for spontaneous note-taking.<br> 🟡 🟠 🔴 🟣 🔵 🟢 
            </p>
        </td>
    </tr>
</table>


### Usage 

Press the keyboard shortcut to open the scratchpad that was last used.  
Press the keyboard shortcut again or <kbd>⎋</kbd> to dismiss the scratchpad without saving.

In __Editing Mode__
* <kbd>⌘⏎</kbd> to save changes¹
* <kbd>⇧⏎</kbd> to preview as rendered markdown
* <kbd>⌥⏎</kbd> to view all pads and search your notes²
* <kbd>⌘⇧⏎</kbd> to cycle through your scratchpads

In __Markdown Mode__
* <kbd>⏎</kbd> or <kbd>⇧⏎</kbd> to start editing
* <kbd>⌥⏎</kbd> to view all pads and search your notes²
* <kbd>⌘⇧⏎</kbd> to cycle through your scratchpads
* <kbd>⎋</kbd> to either cancel or go back through previously viewed pads 


Press the secondary keyboard shortcut or enter the workflow's keyword (default: `pad`) to view all scratchpads and to search their contents.

<img src="assets/images/preview_pad-1.gif" width="564px"/>
<img src="assets/images/preview_pad-2.png" width="564px"/>
<img src="assets/images/preview_pad-3.png" width="564px"/>


__Notes:__  
¹  Changes are also saved when previewing and when switching the active pad.  
²  When searching for a pad containing a keyword, the first matching line will be used as subtitle. Press <kbd>⌘L</kbd> to view the matched line as [Large Type](https://www.alfredapp.com/help/features/large-type/).


## 1.20 Window Navigator

[![Download button for workflow: Window Navigator](https://img.shields.io/badge/download-v1.3.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.3.0-winnav) [![Swift source code button for workflow: Window Navigator](https://img.shields.io/static/v1?message=WindowNavigator.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/WindowNavigator/WindowNavigator.swift) [![Objective-C source code button for workflow: Window Navigator](https://img.shields.io/static/v1?message=AccessibilityBridgingHeader.h&color=%233A95E3&logo=Xcode&logoColor=FFFFFF&label=Code)](/assets/code/WindowNavigator/AccessibilityBridgingHeader.h)

<table>
    <tr>
        <td>
            <img src="assets/icons/winnav.png" width="150px">
        </td>
        <td>
            <p>
            Navigate to any window of the currently focused application or any application across all desktops, or switch windows within the current desktop space.
            </p>
        </td>
    </tr>
</table>

> [!NOTE]
> macOS 15  deprecates an API that Window Navigator uses to retrieve window information. Already compiled executables will continue to work as expected, but compilation will fail if you try to run the workflow for the first time with macOS 15.
> I'm investigating a solution to this problem. 


### Usage 

1. Search the windows of the active app globally using the Navigator keyword. 
2. Search app windows in the current desktop space using the Switcher keyword. 
3. Search all visible windows of all apps globally using the Global keyword.
* <kbd>↩</kbd> to navigate to the selected window.
* <kbd>⌘</kbd><kbd>↩</kbd> to close the selected window.
* <kbd>⌥</kbd><kbd>↩</kbd> to quit the owning application.

#### 1. Navigator

<img src="assets/images/preview_winnav-1.png" width="564px"/>

#### 2. Switcher

<img src="assets/images/preview_winnav-2.png" width="564px"/>  

#### 3. Global

<img src="assets/images/preview_winnav-3.png" width="564px"/>  



## 1.21 Fuzzy Search

[![Download button for workflow: Fuzzy Search](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-fuzzy)

<table>
    <tr>
        <td>
            <img src="assets/icons/fuzzy.png" width="125px">
        </td>
        <td>
            Limited scope fuzzy search.
            <ul>
                <li>use <b>fzf</b> for classic matching</li>
                <li>use <b>fzf-abbrev</b> for initial character matching</li>
            </ul>
        </td>
    </tr>
</table>


## 1.22 PDF to Table

[![Download button for workflow: PDF to Table](https://img.shields.io/badge/download-v1.0.0-informational)](https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-pdftable)

<table>
    <tr>
        <td>
            <img src="assets/icons/pdftable.png" width="150px">
        </td>
        <td>
            Extract tables from PDF documents as CSV.
        </td>
    </tr>
</table>

### Usage

Extract tables from PDFs via the [Universal Action](https://www.alfredapp.com/help/features/universal-actions) and export them as CSV.
- Use __PDF to Table (Lattice)__ if there are ruling lines separating each cell
- Use __PDF to Table (Stream)__ if there are no ruling lines separating each cell


![PDF to Table Universal Action preview image](assets/images/preview_pdftable-1.png)

### Dependencies

- [Java](https://www.java.com/en/download/help/mac_install.html) (Information on installing Java)
	* [Java for macOS download page](https://www.java.com/en/download/)
- [Tabula](https://github.com/tabulapdf/tabula-java) (The jar file is included in this workflow)


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

### Details

The core idea is to inject environment variables into the workflow configuration and to modify them with some delay.


- To set up modifier palettes, all you have to do is define an identifier on any hotkey, `⌥O`, such as "`openA`". This is the "text" argument that the hotkey passes on as `{query}`. Set the identifier to some *environment* variable, say "`gate`", and use a downstream `conditional object` triggered by a different hotkey, `⌥K`, to check if the variable (`{var:gate}`) is equal to the identifier `openA`. Any action that you make depend on this condition will be triggered iff `gate` is equal to `openA`, i.e. if you have recently tapped the hotkey associated with the identifier.

- To set up double-tap hotkeys, proceed in the same way, defining an identifier for the hotkey's "text" argument. For each double tap hotkey, an environment variable is injected that is either `0` or `1` for inactive or active. 
	

`Disclaimer`: Alfred may crash if you get the timing of the keystrokes just right. This is due to a data race where the same variable ("`gate`") is accessed and modified by different threads at the same time. Also, for the double-tap hotkeys, there is some "bleed" into the other hotkeys with the way it is set up in the demo. Tapping a, then b, will also trigger b, instead of having to tap b twice.

![](assets/images/preview_extended.jpg)


---

## 2.2. Permission Handler 

An example of how to handle permissions gracefully for your executables. (For now, take a look at the *Duden Workflow* that implements the permission handler).

## 2.3. GUI Input Experiment

<a href="https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-uiex"><img src="https://img.shields.io/badge/download-v1.0.0-informational"></a>
[![](https://img.shields.io/static/v1?message=Dialog.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/Dialog.swift)

Run a graphical prompt and read the input. Proof of concept for using NSWindow and SwiftUI components to get user input through a graphical prompt and then use it in the Alfred app - or on the command line.

<img src="assets/images/preview_uiex1.png" width="564px"/>

<details> 
    <img src="assets/images/preview_uiex2.png" width="564px"/>
    <img src="assets/images/preview_uiex3.png" width="382px"/>
</details>


## 2.4. Heads-up Display

<a href="https://github.com/zeitlings/alfred-workflows/releases/tag/v1.0.0-hudex"><img src="https://img.shields.io/badge/download-v1.0.0-informational"></a>
[![](https://img.shields.io/static/v1?message=HUD.swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=Code)](/assets/code/HUD.swift)

Demo for displaying notifications on a heads-up display.  
The script takes two arguments: 
- The text to display 
- The width of the prompt

<img src="assets/images/demo.hud.gif" width="649px">
