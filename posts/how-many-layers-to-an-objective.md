---
title: "How many layers to track an objective?"
date: 2026-03-22
slug: how-many-layers-to-an-objective
status: published
---

Linear has this hierarchy of layers to track, say, a feature. Not too dissimilar from all this "epic, story, task, sub-task" kind of nonsense that goes around. Linear calls it "project -> issue -> sub-issue" etc.

I am going through a project I am working on and someone has set up projects for each feature, and each project has similar-looking issues: `<feature> frontend implementation`, `<feature> backend implementation`, `<feature> research`, `<feature> acceptance test` and so on. Our backlog is dozens of these tickets.

Alright. Let me take a look at the status of a feature. That means I go to the "projects" page. That page lists the issues each of which is `<feature> ____` and if I want to look at what's the status on, say, the frontend of it, I have to go into the issue named `<feature> frontend implementation`. (The overall status is visible for each issue without going into it, yes, but by _status_ I mean what's actually happening in this issue? Are there comments left by someone? Are there commits pushed towards this issue?)

You'd think this is OK. No. It sucks.

Each stage is a layer. Each layer is a different page. Each layer has its own set of metadata and concepts to grok. Each layer comes with a change in context that's so subtle yet throws you off-kilter if you aren't razor focused about what it is that you're looking for every step of the way. And boy have reels done their number on our focus.

Linear has one of the simplest, cleanest interfaces I've ever used. Despite that, all the different layers, the hierarchies, and the metadata and their visual representations felt jarring. Too much _effort_ to get to the info I need.

--

When I began working on a feature — which was a "project" with 4 different issues on Linear — I closed all tickets and created just one ticket for the feature. All action-items / sub-tasks of that ticket were just markdown checklists:

```text
Feature Abcd

- [ ] Implement frontend
- [ ] Implement backend
...
```

Updates on the feature became comments under the ticket. Extra info relevant to the implementations became part of the description:

```text
Feature Abcd

- [ ] Implement frontend
- [ ] Implement backend
...

--

We'll use [this open-source project](link) for the server implementation.

-- and other info goes here...
```

The simplification helped. I didn't have to drag myself through layers of UI to get or set information on some task. One ticket was all it needed.

--

I can hear the argument. "This won't work for teams working on multiple parts of the same feature!" "This won't work for epics that are inherently complex and involve lots of different threads!"

Sure. Maybe.

The thing is, Linear is a means to an end. The end is shipping the feature to users. There are two core reasons for Linear (and the likes):

- Capture what needs to be worked on (features, bugs, optimizations, explorations etc.)
- Have a communication layer that is much more refined than a PM pinging everyone and asking verbose questions and reading verbose answers.

What I mean is, "OK, what's the status of the UI for feature XYZ?" can be answered with a checkbox and some comments under a ticket. Or by going to the project/epic, finding the correct story/issue and clicking it, then finding the right task/sub-issue and clicking it, only to find that _that_ particular item hasn't been updated since inception because the developer couldn't be bothered to update an item so far down the layer-hole.

Oh, also, multiple people working on the same feature can update the same ticket.

--

Yeah, yeah, this is about to turn into the same-old complaint of "project-management-as-a-job" ruining the pleasures of just working on stuff.

Linear, which started out as this really simple antidote to Jira and the likes, is now probably getting there itself. I am sure user feedback is what drives these decisions: users want layers, users want hierarchies etc. So it feels totally justified in introducing these "carefully-designed" complexities into the product.

The gripe is that the feedback comes from folks who see project management as an end and not a means?

Also, it's not just about the app. How do we end up using something? The app provides the "flexibility", but that doesn't mean we add 5 layers of information to track a simple objective.

--

Organizational management is a deeply and richly studied thing. No doubt about it. The stupidity is that we imported the complex layers of NASA's and military organizations' management styles, pretending to be building things just as humongous or of similar sophistication when all we're building, Andy, is a web app.
