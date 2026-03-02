---
title: "Going back to the morning newspaper model"
date: 2026-03-02
slug: going-back-to-newspaper-model
status: published
---

Recently, [Current RSS reader](https://www.terrygodier.com/current) hit the headlines and I had a gander at what it is, how it's designed and what the underlying philosophy is.

It's a beautiful-looking app. But the fundamentals are problematic and repeat the same mistakes that lead to different kinds of problems you and I face w.r.t. digital content overwhelm as we try to grapple with, catch up on, and manage our digital consumption.

###### I. We consume about a fraction of what hits our streams

For many years now [RSS feeds](https://en.wikipedia.org/wiki/RSS) have been a boon as social media and YouTube took over the digital content landscape. But as the maker of the Current RSS reader points out, the email inbox-style design has added a subconscious anxiety to managing RSS feeds too. Why do we need an unread count?

When you are subscribed to a few hundred feeds, the amount of links staring at you is huge. But, and here's the obvious thing, we actually are interested in, on a rough average, about 20% of things out of that list. It makes no sense to have an anxiety-inducing user-interface that says you have 1438 unread links. You probably care only to read about 20-30 of them today.

But this is not the only problem. This is not even the key problem.

###### II. "Streams" are problematic, and they are using it to hack our behavior.

In my W.I.P. guide/booklet, [_Escape from Algotraz_](https://notes.druchan.com/escape-from-algotraz#iii.-stream-vs-batch), I talk about this fundamental issue about social media "feeds". They are an _infinite stream_. Never-ending. The more you scroll, the more it keeps scrolling.

This is one of the darkest design patterns we've cooked up. If you grew up in the older internet, you remember hitting the end of a paginated list of items. There used to be an _end_ to things. Now there isn't. It's not an eventuality.

Despite there being an infinite amount of content to consume, apps can decide to "end" the list of items for you. They can choose to say, "oh that's it for now, come back and check in a few hours, we'll show you new content." But they won't.

RSS feeds are limited by the number of feeds you're subscribed to but they still manage to _stream_ an almost infinite-looking stream at you. Couple that with the unread count and you're back to anxiety-town about unmanageable digital content consumption.

Apps like Current RSS reader (which literally uses the word "river" for the stream of content from your feeds) are merely reinforcing this bad pattern. Smart removal of items from the feed is not going to solve the fundamental issue (and it only introduces more cognitive load for us).

We do not want streams. Our brains are not wired to process streams. They need a break and, if the designers and developers care, apps can be designed this other way.

###### III. Our brains are good with batch processing.

Have you ever done this thing where you said to yourself that you'll catch up on the unread items over the weekend? Or that you'll do all the chores (cleaning, laundry, meal prep) over the weekend?

We're essentially "batching". Turns out batching is a good antidote to "streams".

Here's another analogy. This one works for folks who grew up with physical newspapers around. Do you remember getting the morning newspaper, skimming through the headlines and reading a few of the news items in detail? What after that? We were done. That's it. Even if you went back to read some more, there was this palpable feeling of being "done". A closure of sorts. Task = done.

The digital user interface landscape today is designed specifically to prevent you from feeling this way.

###### IV. The onus is on ourselves to fix this for us.

I couldn't find an app that did this for me and worse, I couldn't find literature around this either. While there's so much brouhaha about [calm technology](https://calmtech.com/), when it comes to content overwhelm, it seems the onus is on us, the users, to find out a way to fix it.

So I started experimenting with ways to manage my content (and discovering, inculcating and testing the underlying philosophical argument). Eventually, I managed to write up a simple solution: every day, I produce a plain HTML page of links from all my feed sources. With my 300+ feed subscriptions, I get about 400 links on average. Of this, I am only interested in about 10-20% on average.

This plain HTML page is my newspaper equivalent. While I do read news elsewhere, this "digest" happens to be my way of batch processing my daily content I want to keep tabs on.

And it has worked fabulously well for about 500 days now. In the morning, I open my _digest_, and open the links that I am interested in (a combination of news items, op-eds, LettersOfNote-like pieces, stuff from Hacker News/Lobsters, Veritasium-like YouTube videos, some cooking channels, some chess channels, parody or satirical content etc.). And then, if I have time in the morning, finish reading most of it before work, or read them in bits and pieces through the day.

Most importantly, I know this is all I want to read for the day. There may be an occasional 2-3 extra things I consume (someone shared a link on WhatsApp; I accidentally opened social media; links from email).

At the basic level, why this has worked well for me is the mental perception. My digest gives me a finite list of content to work through. Out of this finite list, I am interested in a fraction. It's all ridiculously manageable.

The fact that we're only interested in a small fraction of content should be so obvious, right? But try that with an infinite stream of content. A fraction of infinity still feels like infinity. But with finite content — as in a digest or a newspaper — you realise the manageability instantly.

###### V. "How we got here" is clear. And so is "how to get out of here?"

I am convinced that an entire class of problems is solved if the interface lends itself to reminding us of the finiteness of content and time. (Look no further than the "inbox zero" trend. The idea was to create finite chunks out of an infinite stream, so that you can then manage that finite chunk easily while also having the (false) feeling of having cleared everything.)

Eschew streams.

Create interfaces (or pick those) that have a finiteness to them. No infinitely scrolling interfaces. No constantly _streaming_ screens. Just simple plain pages that start and end and when they end, it's a nice little reminder that you are done for the day and can go back to other things in life.

If we want to go _back_ to a healthier digital content consumption era, we might just need to use the principles of older interfaces going back to the newspaper era.

P.S.: I didn't want to make this a plug for my solution so I am linking to the open-source codebase here: [rdigest](https://github.com/chandru89new/rdigest). The app doesn't matter; what matters is the underlying principle of design that I've written about above and that's something almost anyone can now mimic with the advent of AI/LLMs.
