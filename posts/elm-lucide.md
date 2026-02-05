---
title: Bringing 1600+ Lucide icons into Elm
date: 2026-02-04
slug: elm-lucide
status: published
---

[Lucide icons](https://lucide.dev) is one of the most popular icon sets today. It has some really wonderful icons for interface design.

In the past, for my Elm projects, I've used Feather icons. In new Elm projects, I wanted to use Lucide Icons, only to discover that there is no Elm package to import and use Lucide icons. I was surprised: the Elm ecosystem, even if niche, pretty much supports all modern / contemporary libraries and tools. So not finding an Elm Lucide package was very surprising.

Just as surprisingly, the [Feather icons Elm package](https://github.com/feathericons/elm-feather) hasn't been updated in 6+ years.

And so, a new side-quest was born: publishing the first [elm-lucide](https://package.elm-lang.org/packages/chandru89new/elm-lucide/latest/) package to bring Lucide icons to the Elm ecosystem.

The first thing I did was to find out how Feather icons were being rendered in Elm. I found this:

```elm
alignLeft : Icon
alignLeft =
    makeBuilder "align-left"
        [ Svg.line [ x1 "17", y1 "10", x2 "3", y2 "10" ] []
        , Svg.line [ x1 "21", y1 "6", x2 "3", y2 "6" ] []
        , Svg.line [ x1 "21", y1 "14", x2 "3", y2 "14" ] []
        , Svg.line [ x1 "17", y1 "18", x2 "3", y2 "18" ] []
        ]
```

So, just use SVG module to render the paths and other tags. The values of these tags come from the SVG content for each icon.

To do this for Lucide, I'll need two things:

- download all SVG data for all the 1600+ icons on Lucide
- then, for each SVG, convert the XML into Elm-syntax

Getting all the Lucide icons is simple. [lucide-static](https://lucide.dev/guide/packages/lucide-static) is a JavaScript file that has all the SVG icons. I ran a simple `curl` to fetch all the icons in a single JS file.

Each icon looks like this:

```js
const TextAlignStart = `
<svg
  class="lucide lucide-text-align-start"
  xmlns="http://www.w3.org/2000/svg"
  width="24"
  height="24"
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="2"
  stroke-linecap="round"
  stroke-linejoin="round"
>
  <path d="M21 5H3" />
  <path d="M15 12H3" />
  <path d="M17 19H3" />
</svg>
`;
```

The goal is to take the contents inside the `<svg>` tag, convert them into Elm-specific syntax. Basically:

from this:

```xml
<path d="M21 5H3" />
<path d="M15 12H3" />
<path d="M17 19H3" />
```

to this:

```elm
S.path [ SA.d "M21 5H3" ] []
, S.path [ SA.d "M15 12H3" ] []
, S.path [ SA.d "M17 19H3" ] []
```

While I pondered over this, I realized that if I could transform this SVG XML into an [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree), I can then parse it to extract the relevant info I need.

For example:

```js
{
    children: [
        { node: "path", attributes: [{ d: "M21 5H3" }] },
        { node: "path", attributes: [{ id: "M15 12H3" }] },
        ...
    ]
}
```

I can then use this structure and create a string which is valid Elm syntax:

```elm
S.path [ SA.d "M21 5H3" ] []
, S.path [ SA.d "M15 12H3" ] []
, S.path [ SA.d "M17 19H3" ] []
```

The trick was that I needed to do this SVG/XML to AST conversion in a Node environment. Upon research, I found that [`jsdom`](https://github.com/jsdom/jsdom) helps with this. So, I ended up doing this:

```js
try {
  let div = new jsdom.JSDOM(
    `<div>${svgString}</div>`
  ).window.document.querySelector("div");
  let svg = div.querySelector("svg");
  icon.classList = svg.classList.toString();
  icon.children = [];
  let children = Array.from(div.querySelectorAll(`svg > *`));
  icon.children = children
    .map((c) => [c.nodeName, extractAttributes(c.attributes)])
    .map(childToList);
  return icon;
} catch (e) {
  log(e);
  return null;
}
```

That is:

- get the SVG string (this was easy, just read the value of an exported icon from lucide-static.js)
- wrap it in a `<div>` and make `jsdom` render it
- then, extract what I need (`svg`'s children)
- convert each child into a tuple of `[node name, node attributes as key-value pairs]`

For example, for this node:

```xml
<path d="M13 21h8" />
```

This is the tuple I get:

```js
["path", { d: "M13 21h8" }];
```

And finally, once I have all the tuples, I just convert them into Elm strings.

And I combine all of that into one large module-declaring string and then print that to an Elm file called `LucideIcons.elm`.

One additional trick I need to do here is to enable customization of the icon. So I construct the icon in a way where it's a function that takes an `options` parameter (of type `List (Svg.Attribute msg)`) and renders the SVG icon with those options. This allows for some nice, simple customization of the icon as an SVG element.

```elm
alignLeftIcon : List (S.Attribute msg) -> H.Html msg
alignLeftIcon options =
    S.svg (baseOptions ++ options) [ S.path [ SA.d "M21 5H3" ] [], S.path [ SA.d "M15 12H3" ] [], S.path [ SA.d "M17 19H3" ] [] ]
```

All of this is in a `build.js` script that automates the whole thing. When I run this, I have a `LucideIcon.elm` file which defines and exports all the 1600+ icons in Lucide as Elm functions.

Since the `build.js` script downloads the latest `lucide-static`, whenever there is an update in Lucide's version, I just run this and I have all the new/updated icons as well.

You can find the [`elm-lucide` package here](https://package.elm-lang.org/packages/chandru89new/elm-lucide/latest/). I try and update as soon as there are updates to the main Lucide library.
