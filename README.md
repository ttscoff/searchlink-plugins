# SearchLink Plugins


A collection of plugins for [SearchLink](https://brettterpstra.com/projects/searchlink/ "SearchLink")

## Installation

Just save any of these plugins to `~/.local/searchlink/plugins` and SearchLink will add them as valid searches. You could, if you wanted to, clone the entire project to that folder with:

```
$ mkdir -p ~/.local/searchlink
$ cd ~/.local/searchlink
$ git clone git@github.com:ttscoff/searchlink-plugins.git plugins
```

## Plugins

**Lyrics**

This plugin will search <https://genius.com> for a song, returning either a link (`!lyric`) or embedding the actual lyrics (`!lyrice`). It demonstrates both search and embed functionality, and is fully commented to serve as an example plugin.

**MixCase**

This plugin is a text filter that will turn `!mix A string of text` into `A STRInG of TExT`, randomly capitalizing characters. It's just to demonstrate how easily a text filter can be implemented.

**Calendar**

Another example of a text filter. This one can insert a Markdown calendar for any month and year. You can define the month and year like `!cal 5 2024` to get a calendar for May, 2024. If you use `!cal now` it will insert a calendar for the current month and year. It can also print how many days are in a month with `!days 2 2024` to show how many days are in October. Silly, and would probably be better as a TextExpander snippet, but I'm just experimenting with extending SearchLink.

**MakeADate**

This is a port of a TextExpander snippet I use. It takes a natural language date and inserts a formatted date. It provides the following formats:

| Abbr | Result |
|------|--------|
| `!ddate tomorrow 8am` | 2023-11-02 8:00am |
| `!dshort tomorrow 8am`| 2023-11-2 8:00am |
| `!diso tomorrow 8am` | 2023-11-02 08:00 |
| `!dlong tomorrow 8am` | Thursday, November 2nd, 2023 at 8:00am|

**This plugin requires that PHP be installed on the system, either with the Apple Command Line Utilties (I think), or with Homebrew (`brew install php`).**

## Contributing

Use the sample code in `lyrics.rb` to generate your own plugins. Feel free to fork and submit a PR to this repository if you create something you'd like to share!