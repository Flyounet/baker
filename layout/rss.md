---
---
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
	<channel>
		<generator>Baker</generator>
		<docs>http://blogs.law.harvard.edu/tech/rss</docs>
		<title>{{ SITE_NAME }}</title>
		<link>{{ RSS_SITE_URL }}</link>
		<description>{{ SITE_DESC }}</description>
		<pubDate>{{ RSS_DATE }}</pubDate>
	</channel>
@each posts
	<item>
		<title>{{ title }}</title>
		<link>{{ RSS_SITE_URL }}/{{ id }}.html</link>
		<description>{{ summary }}</description>
		<pubDate>{{ date }}</pubDate>
	</item>
@end
</rss>
