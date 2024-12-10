# SearchLink Plugins


A collection of plugins for [SearchLink](https://brettterpstra.com/projects/searchlink/ "SearchLink").

## Installation

Just save any of these plugins to `~/.local/searchlink/plugins` and SearchLink will add them as valid searches. You could, if you wanted to, clone the entire project to that folder with:

```
$ mkdir -p ~/.local/searchlink
$ cd ~/.local/searchlink
$ git clone git@github.com:ttscoff/searchlink-plugins.git plugins
```

> If you intend to develop your own plugins or make modifications to existing ones, fork the repo first and close that to your local drive, allowing you to make pull requests from your fork.

## About Plugins

All of [SearchLink's searches](https://github.com/ttscoff/searchlink/tree/main/lib/searchlink/searches) are defined as [plugins](https://github.com/ttscoff/searchlink/wiki/Plugins). You can duplicate any of them into the plugins folder and override default functionality, or use them as examples for developing your own.

## Plugins

### Calendar

Another example of a text filter. This one can insert a Markdown calendar for any month and year. You can define the month and year like `!cal 5 2024` to get a calendar for May, 2024. If you use `!cal now` it will insert a calendar for the current month and year. It can also print how many days are in a month with `!days 2 2024` to show how many days are in February, 2024. Silly, and would probably be better as a TextExpander snippet, but I'm just experimenting with extending SearchLink.

### Custom Google

This plugin demonstrates adding your own custom search engine through Google. Create a [custom engine here](https://programmablesearchengine.google.com/controlpanel/all) to search specific pages/sites, then modify the plugin according to the comments at the top to create your own custom site search.

Requires a [Google API key](https://github.com/ttscoff/searchlink/wiki/Using-Google-Search).

### IMDB

This plugin uses a custom site search from Google Programmable Search to search IMDB, actors, or titles. Just another demo of how to use custom engines to create plugins. Requires a [Google API key](https://github.com/ttscoff/searchlink/wiki/Using-Google-Search).

Adds searches `!imdb`, `!imdba` (actor search), and `!imdbt` (tv/movie title search).

### Lyrics

This plugin will search <https://genius.com> for a song, returning either a link (`!lyric`) or embedding the actual lyrics (`!lyrice`). It demonstrates both search and embed functionality, and is fully commented to serve as an example plugin.

### MakeADate

This is a port of a TextExpander snippet I use. It takes a natural language date and inserts a formatted date. It provides the following formats:

| Abbr | Result |
|------|--------|
| `!ddate tomorrow 8am` | 2023-11-02 8:00am |
| `!dshort tomorrow 8am`| 2023-11-2 8:00am |
| `!diso tomorrow 8am` | 2023-11-02 08:00 |
| `!dlong tomorrow 8am` | Thursday, November 2nd, 2023 at 8:00am|

***This plugin requires that PHP be installed on the system, either with the Apple Command Line Utilties (I think), or with Homebrew (`brew install php`).***

### ManPage

This plugin searches mapages.org for a matching command and returns the url, including command name and man section, e.g. `https://manpages.org/lsof/8`, as well as a title with a brief description of the command. So running SearchLink on `!man lsof` would return `[lsof](https://manpages.org/lsof/8 "lsof (8): list open files")`. If the search term contains multiple words, they'll be parsed individually until one of the words gets at least a partial search result, the shortest of which will be used.

### MixCase

This plugin is a text filter that will turn `!mix A string of text` into `A STRInG of TExT`, randomly capitalizing characters. It's just to demonstrate how easily a text filter can be implemented.

### Setapp affiliate linking

There are two plugins, bitly_setapp and isgd_setapp that will take an app name that's avaialable on Setapp and turn it into an affiliate link so you can make some money on recommendations. Links are shortened with either bit.ly or is.gd, depending on the plugin. Bit.ly shortening requires an access token.

### Weather

Can output a current conditions with searches !weather and !current, and a forecast with !forecast. All output in Markdown format. Requires a weatherapi.com API key.

## Contributing

Use the sample code in `lyrics.rb` ([documented in the SearchLink wiki](https://github.com/ttscoff/searchlink/wiki/Plugins)) to generate your own plugins. Feel free to fork and submit a PR to this repository if you create something you'd like to share!
