#!/usr/bin/osascript -l JavaScript

ObjC.import('stdlib');
ObjC.import('Foundation');

const stdout = function (msg) {
    $.NSFileHandle.fileHandleWithStandardOutput.writeData(
        $.NSString.alloc.initWithString(String(msg))
            .dataUsingEncoding($.NSUTF8StringEncoding)
    )
}

const stderr = function (msg) {
    $.NSFileHandle.fileHandleWithStandardError.writeData(
        $.NSString.alloc.initWithString(String(msg))
            .dataUsingEncoding($.NSUTF8StringEncoding)
    )
}

const args = $.NSProcessInfo.processInfo.arguments;
// args[0..3] are filename, "/usr/bin/osascript", "-l", "JavaScript"
if (args.count > 4) {
	var search_type = args.js[4].js;
	var search_terms = args.js[5].js;
	var link_text = args.js[6].js;
}

let saf;
switch (search_type) {
  case 'tabb':
  case 'tabbf':
  	saf = Application('Brave');
  	break;
  case 'tabe':
  case 'tabef':
  	saf = Application('Microsoft Edge');
  	break;
  case 'tabc':
  case 'tabcf':
    saf = Application('Google Chrome');
    break;
  case 'tabs':
  case 'tabsf':
    saf = Application('Safari');
}

saf.includeStandardAdditions = true;


String.prototype.to_rx = function(distance) {
    return this.split('').join(`.{0,${distance}}`);
}

if (search_type.endsWith('f')) {
	let current_tab_title;
	let current_tab_url;
	if (search_type.startsWith('tabs')) {
		current_tab_title = saf.windows[0].currentTab.name()
		current_tab_url = saf.windows[0].currentTab.url()
	} else {
		current_tab_title = saf.windows[0].activeTab.name()
		current_tab_url = saf.windows[0].activeTab.url()
	}

	data = {
		"url": current_tab_url,
		"title": current_tab_title,
		"link_text": link_text
	}
} else {
	var tabs = []

	saf.windows().forEach(function(win) {
		win.tabs().forEach(function(tab) {
			tabs.push({
				'title': tab.name(),
				'url': tab.url()
			});
		});
	});
	tabs.forEach((tab) => stderr(tab['title']));
	var terms = search_terms.split(/ +/);
	var regex = '';

	var res = null;
	var matches = [];
	var distance = 0;
	while (distance < 5) {
		var terms_rx = terms.map(term => term.to_rx(distance));
		var rx = new RegExp(terms_rx.join('.*?'), 'i');

		matches = tabs.filter((tab) => { return (rx.test(tab['title']) || rx.test(tab['url'])) });
		if (matches.length == 0) {
			distance += 1;
		} else {
			break;
		}
	}

	if (matches.length > 0) {
		res = matches[0];
		data = {
			'url': res['url'],
			'title': res['title'],
			'link_text': link_text
		}
	} else {
		data = {
			'url': false,
			'title': null,
			'link_text': link_text
		}
	}
}

stdout(JSON.stringify(data));
