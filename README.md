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

* To perform DITASearch indexing for a custom, plugin, set `ditasearch-gen-index` to `true`
  so that DITASearch templates are processed.
* This plugin does *not* support XHTML-based transformations.

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

1.7.6
: Fix: DITASearch parsing was performed even when not building HTML5

1.7.5
: TC-5477 Fix: UTF-8 encoding is not default for new Jenkins agent

1.7.4
: TC-4758 Refactor to use ditafileset pipeline

1.7.3
: Fix log warning

1.7.2
: Don't rely on deprecated .list files

1.7.1
: Improve readability of index files

1.7
: TC-3559 Add result ranking to HTML
: TC-3559 Remove query param from result URL

1.6
: Fix Windows build problem

1.5
: Make shortdesc clickable, fix bug when clicking shortdesc
: Fix: In Firefox, ditasearch class was removed on keyboard navigation

1.4
: Make CSS selectors less specific (easier to override)

1.3
: Pass search query to analytics, new topic

1.2
: Support DITA-OT 3.1

1.1
: Test for an HTML-type transformation before generating index
: Scroll to top of results after rebuilding result list

R1
: Initial release
