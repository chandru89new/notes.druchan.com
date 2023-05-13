# notes.druchan.com

Repo to store blog posts and the script that generates the static site/blog.

## Contents

- Requirements
- Setup
- Workflow
  - Writing posts
  - Building the site
  - Testing locally
  - Uploading/deploying to server
- Editing/updating generator script
  - Main.purs
  - Watching for changes
  - Templates and Styling

## Requirements

- Node (any latest >= 18)
- Yarn (typically enabled by npm, but you could also do `corepack enable`)
- Firebase (for testing locally + deploying to server because this project uses Google Firebase for hosting)

(Firebase is optional. You can still build the project and serve it anyway you like.)

## Setup 

```bash
~ yarn install
```

This will install everything required.

## Workflow

### Writing posts

- Write posts in `contents/` directory.
- Filename is `<slug>.md` where `<slug>` is the URL-friendly version of the title.
- The first few lines of the file are the metadata. The format is:

```markdown
---
title: "Title of the post in quotes"
date: YYYY-MM-DD
slug: slug
---
blog post content here
```

### Building the site

```bash
~ yarn build
```

This will build the site and output in `./public` directory.

### Testing locally

```bash
~ firebase serve
```

Alternatively, you could use any other method too. Eg, using `http-server`:

```bash
~ npx http-server public
```

### Uploading/deploying to server

```bash
~ firebase login # if not already logged in
~ firebase deploy
```

## Editing/updating generator script

### Main.purs

The whole building logic is in `src/Main.purs`. 

### Watching for changes

```bash
~ yarn watch
```

The watch options are in "nodemonConfig" in the `packages.json` file. By the config, the script will watch for changes in `src/`, `contents/` and `templates/` directories.

### Templates and Styling

The templates, in the `templates/` directory, are for the home page (`index.html`), the blog post page (`post.html`) and the archives page (`archives.html`). A `404.html` page is for the page-not-found. It's not a template.
