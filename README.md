# baker, the real static blog generator in bash

![baker](http://i.imgur.com/Tngl5Vv.png)

- [x] Template
- [x] Markdown
- [x] Draft
- [ ] Video/Audio (ffmpeg)
- [x] Tag
- [x] RSS
- [x] Atom Feed

## Start your first post

1. Give it a title: `./baker post I love pizza so much!` This command will create a markdown file that has the slug `i-love-pizza-so-much` in the `post` directory. If the `$EDITOR` environment variable is set, it will open up the post markdown file with the editor.

2. Change `draft` from `true` to `false` to publish the post (or use the `./baker toggle id`).

3. Bake all posts: `./baker bake`

4. Verify which post you already cooked: `./bake list`

5. Configure your own flavour. Try it: `./bake -b -f flavour.conf`

6. Know your bakery: `./baker -h`

## Template redesigned

The new template engine is much faster (and smaller) than the previous version. It now uses bash's scope as its context.

### variable

Variable identifier should only use `[A-Za-z_]`. Notice that any number is not allowed in a variable name.

```
{{ var }}

{{ content }} # embed child layout output
```

### if

Notice that spaces are not allowed between `!` and `var`.

```
@if !var
	...
@end
```

### each

`@each` iterates an array. This is why a number is not allowed in a variable name.

For example,

```
posts = [
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

is encoded as:

```
posts_0_title=first
posts_0_content=example1

posts_1_title=second
posts_1_content=example2
```

```
@each posts
	{{ title }} - {{ content }}
@end
```

### include

`@include` includes a partial from `$LAYOUT_DIR/$filename.md`. Notice that `.md` is already added.

```
@include filename
```

### cmd

`@cmd` gets stdout from embedded bash script.

```
@cmd

for i in {1..10}; do
	echo "$i"
done

@end
```

## Configuration

### Headers in post

The headers in post indicate how Baker has to bake :

* `title: `: The title of post in the index (and in the post). Also used to generate the filename. 
* `date: `:  The date of the post in the form `2015-11-20T11:06:07Z` (Created by Baker when generating a new post).
* `update: `: The date of the last update in the post (not automatique, same form as `date: `).
* `tags: `: The list of tags (comma separated) for the post.
* `layout: `: The name of layout used to generate the post. The name should have not contain the `.md` at the end.
* `draft: `: When cooking your post, Baker put your post in the `draft` directory if set to true, in `out` directory either.
* `summary: `: The summary is printed in the index (and could be added in the post).
* `sumprint: `: If set to true, the summary will be added in the beginning of the post (depends on your layout).

### Variables in Baker

Baker is able to load a config file either by itself (if your config file is named `baker.conf`) or by using the `-f filename`.  
Here are some variables you could change (in fact all could be changed, it will depend on your needs) :

* `POST_DIR` : where to store your markdown files
* `OUTPUT_DIR` : Where to store your compiled html files
* `DRAFT_DIR` : Where to store your compiled html draft files
* `LAYOUT_DIR` : Where to store your layout markodown files
* `PUBLIC_DIR`: Where to store your static content (css, images, js, ...)

* `SITE_NAME` : The site title
* `SITE_DESC` : The site description
* `DISQUS` : The username of your Disqus account (check the layout)

* `AUTHOR_NAME` : Your name
* `AUTHOR_DESC` : Speak about yourself
* `AUTHOR_EMAIL` : Your email
* `AUTHOR_EMAIL_HASH` : Based on your `AUTHOR_NAME` to make your avatar id
* `AUTHOR_TWITTER`: Your Twitter name account
* `AUTHOR_GITHUB` : Your Github name account

* `TAGS_BASELIST` : When creating a post this Tags list is autmoatically added
* `TAGS_LINK`: The html (based on your layout) to generate tags list. `==tagNameSlugged==` will be replaced by the tga name slugged. `==tagName==` will be replaced by the tag name.
* `RSS_SITE_URL` : Inform readers where to find your posts when they read the RSS Feed
* `PRINT_ALL_SUMMARY`: Add the summary of your post inside your post. Use `none`, `all` or `user`. `all` and `none` override the `sumprint` header.

## Markdown

It currently uses the implementation from [Daring Fireball](http://daringfireball.net/projects/markdown/).

## License

This software is made by taylorchu, and is released under GPL2.
