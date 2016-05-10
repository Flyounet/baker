# baker, the real static blog generator in bash (and perl for Mardown transformation).

Before starting here are examples of baker in action :

- [Timeline mode](https://flyounet.net/projets/baker-example/) (same content, but [Original template](https://flyounet.net/projets/baker-example-original/))
- [Original example](https://dl.dropboxusercontent.com/u/10527821/baker/index.html)

## License

This software is made by taylorchu, and is released under GPL2.  
All modifications made by Flyounet are released under the WTFPL and DSSL.

## Features

Baker is full of features, more or less 

- [x] Templates (design your templates, Baker will fill it with datas), see Template section
- [x] Markdown (all your Mardkown texts are transformed to HTML),
- [x] Draft/Hidden, see section
- [x] Tags (call it Tags or cateories or whatever you like)
- [x] RSS feed (Feed valid [FeedValidator](http://feedvalidator.org/))
- [x] Atom feed (Feed valid [FeedValidator](http://feedvalidator.org/))
- [x] Easy Configuration file (easy, if you read the doc)

## Usages

Baker is CLI software. This means Command Line Interface. Here are some commands available:

- `./baker -h` : Give you the help. It's your best friend for running Baker.
- `./baker -I` : Give you the configuration settings.
- `./baker -p "title"` : Create the post with the `title` and open your default `$EDITOR` (or `vi`).
- `./baker -l` : List all your posts with their states.
- `./baker -b` : Bake all your posts with love. Also include the content of the `PUBLIC_DIR` to your `OUTPUT_DIR`.
- `./baker -e id` : Edit your post _id_.

## Enhance your site

### Templates

Templates or Layout is a system where you build your pages, include other pages, make statements, and Baker takes it all and build your site.

All template files **MUST** have the **`.md`** extension.

#### Templates : structure example 

You could for example have a template for the `index` pages, one for the page containing text only, and another for your photo posts.  
All of these pages include a header file. You could have something like this :

```
+ templates (dir) :
|
+- index.md
|  @include header.md
|
+- posts.md
|  @include header.md
|
+- photos.md
|  @include header.md
|  @include js-photo.md
|  @include css-photo.md
|
+- header.md
|  @include css-global.md
|
+- css-global.md
|
+- js-photo.md
|
+- css-photo.md

```

#### Templates : File structure

A Template file is composed of two parts :

- Header (enclosed by two dashed line `---`). Header may contain variables. Headers are similar to headers in posts.
- Content

Here is an example :

```
---
colorcss: blue
testing: true
---
@include global-css
@if !testing
	@include {{ colorcss }}
@end

A so **beautiful** test.
```

#### Templates : Variables

Variable identifier should only use `[A-Za-z_]`. Notice that any number is not allowed in a variable name.

```
{{ var }}

{{ content }} # embed child layout output
```

#### Templates : Directives

As you could see, Baker is able to understand directives. Those directives start with a `@` and MUST be the first element on a line.  
Directives are :

- `@include file` : Include part (only content) of a template file. You don't need to add the `.md`, it's added automatically. See example above.
- `@if variable ... @end` : If the variable exists then the content of `@if ... @end` is added to the template. See example above.
- `@if !variable ... @end` : If the variable doesn't exist (or is empty) then the content of `@if ... @end` is added to the template. Space is **not** allowed between `!` and the _variable_.
- `@each variable ... @end` : _variable_ MUST be an array. Iterate on the content of the array. See example below.
- `@cmd ... @end` : Execute the shell code, and embbed the `stdout`. Be aware that this could have impact on your workstation/server. See example below.

#### Templates : Directives examples

**Example for the `@each variable ... @end`** :

```
myVar = [
	{
		"title": "first",
		"content": "example1",
	},
	{
		"title": "second",
		"content": "example2",
	},
]
```

is (internally) encoded as:

```
myVar_0_title=first
myVar_0_content=example1

myVar_1_title=second
myVar_1_content=example2
```

and using the following template: 

```
@each myVar
	{{ idx }} : {{ title }} - {{ content }}
@end
```

becomes:
```
	0 : first - example1
	1 : second - example2
```
Please note the `idx` variable is used internally by Baker.

**Example for the `@cmd ... @end`** :

```
@cmd
  for i in {1..10}; do
    echo "$i"
  done
@end
```

### Posts configuration

The headers in post indicate how Baker has to bake :

* `title: `: The title of post in the index (and in the post). Also used to generate the filename. 
* `date: `:  The date of the post in the form `2015-11-20T11:06:07Z` (Created by Baker when generating a new post).
* `update: `: The date of the last update in the post (not automatique, same form as `date: `). Could be updated with `baker -u id`.
* `tags: `: The list of tags (comma separated) for the post.
* `layout: `: The name of layout used to generate the post. The name should have not contain the `.md` at the end.
* `draft: `: When cooking your post, Baker put your post in the `draft` directory if set to true, in `out` directory either.
* `hidden: `: When cooking your post, Baker put your post in the `hidden` directory if set to true, without any reference.
* `summary: `: The summary is printed in the index (and could be added in the post).
* `sumprint: `: If set to true, the summary will be added in the beginning of the post (depends on your layout).

### Baker configuration

Baker is able to load a config file either by itself (if your config file is named `baker.conf`) or by using the `-f filename`.  
Here are some variables you could change (in fact all could be changed, it will depend on your needs) :

* `POST_DIR` : where to store your markdown files
* `OUTPUT_DIR` : Where to store your compiled html files
* `DRAFT_DIR` : Where to store your compiled html draft files
* `LAYOUT_DIR` : Where to store your layout markodown files
* `PUBLIC_DIR`: Where to store your static content (css, images, js, ...)
* `HIDDEN_DIR`: Where to store your hidden post (default is `OUTPUT_DIR`)

* `SITE_NAME` : The site title
* `SITE_DESC` : The site description
* `DISQUS` : The username of your Disqus account (check the layout)

* `AUTHOR_NAME` : Your name
* `AUTHOR_DESC` : Speak about yourself
* `AUTHOR_EMAIL` : Your email
* `AUTHOR_EMAIL_HASH` : Based on your `AUTHOR_NAME` to make your avatar id
* `AUTHOR_TWITTER`: Your Twitter name account
* `AUTHOR_GITHUB` : Your Github name account

* `TAGS_BASELIST` : When creating a post this Tags list is automatically added
* `TAGS_LINK`: The html (based on your layout) to generate tags list. `==tagNameSlugged==` will be replaced by the tag name slugged. `==tagName==` will be replaced by the tag name.
* `TAGS_LAYOUT` : Use this particular Layout (instead of the default `index.md`) to generate `index_tag.html`.
* `RSS_SITE_URL` : Inform readers where to find your posts when they read the RSS Feed
* `PRINT_ALL_SUMMARY`: Add the summary of your post inside your post. Use `none`, `all` or `user`. `all` and `none` override the `sumprint` header.
* `EDITOR`: Use this editor to edit your post.
* `BAKER_EXTRA_HEADER`: When Baker create a post it adds the header(s) in the post (use `::` as separator).
* `BAKER_TIMELINE_COMPARATOR`: Baker use this variable to compare date of post to set a new `<section>`.
* `BAKER_TIMELINE_RENDERER`: Baker use this variable to render the test of new `<section>`.

### Draft & Hidden posts:

* Draft posts : You don't have always time to terminate what you write. So, the default value of the header `draft: ` in each post is set to `true`. This means that when you bake all your posts, those kind of posts are generated in the `DRAFT_DIR`. It's only to avoid your unfinished publication to be readable by everyone. Drafted posts or not included in the indexes.
* Hidden posts : You sometimes want to publish something that is relatively secret, the `hidden: ` header is here for that. The hidden posts are generated in the `OUTPUT_DIR` (by default, and could be override) and not indexed. If you need something more secure, you should select a dedicated directory with at least a per user/password access.

### Markdown

It currently uses the implementation from [Daring Fireball](http://daringfireball.net/projects/markdown/). As a consequence, `perl` is needed for `baker` to work.

![baker](http://i.imgur.com/Tngl5Vv.png)
