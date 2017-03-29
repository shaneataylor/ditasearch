# DITASearch plugin
The com.taylortext.ditasearch plugin for the DITA Open Toolkit generates 
a help index and search box in your HTML5 output. Unique features include:

* DITA-aware indexing, so semantic markup like `<indexterm>` and `<shortdesc>`
  automatically increase the weight of terms in those elements.
* Uses a modified Porter2 stemming alorithm so variant forms of English words
  (running and ran, for example) are considered equivalent.
* Respects DITA `<searchtitle>` and `@search` markup.
* Includes a default synonym library that can be extended.
* Automatically adds the search box and calls the search Javascript from your HTML5
  topics (you can turn this off with a parameter).
* Search results are listed immediately below the search box, with intuitive 
  keyboard navigation (you don't need to leave the current topic to view a 
  page of search results). 

## Install
Install the plugin like any other DITA-OT plugin:

```
dita -install https://github.com/shaneataylor/ditasearch/archive/1.1.zip
```

## Use
The DITASearch plugin does not create a new transformation type. Instead, it 
adds processing to the HTML5 transformation type. This is intended to make it
easier to implement with either default HTML5 transformations or custom plugins
based on HTML5.

**NOTE** This plugin does *not* support XHTML-based transformations.

When you build your topics, you will see three changes in your output files:

1. The running header will include `<div class="ditasearch"/>`.
2. The running footer will include `<script src="{path}/ditasearch.js"></script>`.
3. A new `ditasearch.js` file will be included in the root of your output directory.
 
For simplicity, the search index and all needed code is included in the 
Javascript file. When you display the help topics, the script adds the search box inside 
of `<div class="ditasearch"/>`.

## Build parameters
As documented in the plugin itself, two build parameters are available:

### args.ditasearch.configs
Specifies an optional search configuration file containing stopwords, stemming exceptions, and synonyms.
This file can be merged with or replace the default configuration.

### args.ditasearch.nohtml
Omit adding the search HTML to topics if you are including it yourself, for example, in a frameset
or custom header and footer. The following values are supported:

* `true` – Don't add the search HTML to topics.
* `false` (default) – The build adds `<div class='ditasearch'>` to the header 
  and `<script src='{path}/ditasearch.js'>` to the footer.

## Release history

### 1.1 - Bugfix release

- Fixed: The search index was built even for non-HTML builds.
- Fixed: Search results did not scroll to the top after the query changed.

### R1 - Initial release


