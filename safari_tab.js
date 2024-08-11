#!/usr/bin/osascript -l JavaScript

ObjC.import("Foundation");

const args = $.NSProcessInfo.processInfo.arguments;
// args[0..3] are filename, "/usr/bin/osascript", "-l", "JavaScript"
if (args.count > 4) {
	var search_type = args.js[4].js;
	var search_terms = args.js[5].js;
	var link_text = args.js[6].js;
}

const saf = Application('Safari');

const to_rx = (text) => {
	return text.split('').join('.*?');
}

if (search_type == 'saf') {
	var current_tab_title = saf.windows[0].currentTab.name()
	var current_tab_url = saf.windows[0].currentTab.url()



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

	var terms = search_terms.split(/ +/);
	var regex = '';
	terms.forEach((term) => regex += to_rx(term));

	var rx = new RegExp(regex, 'i');

	var res = tabs.filter((tab) => { return (rx.test(tab['title']) || rx.test(tab['url'])) })[0];
	data = {
		'url': res['url'],
		'title': res['title'],
		'link_text': link_text
	}
}


console.log(JSON.stringify(data))
