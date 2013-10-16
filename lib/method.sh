# $1 = binding

no_draft() {
	local line
	while IFS= read -r line; do
		[[ "$(header draft <"$line")" == true ]] || echo "$line"
	done
}

list_page() {
	find "$PAGE_DIR" -name "*.md" | no_draft | sort
}

list_post() {
	find "$POST_DIR" -name "*.md" | no_draft | sort
}

# $1 = map
# $2 = in
# $3 = out
safe_template() {
	[[ -f "$2" ]] || error "layout not found: $2"
	template "$1" < "$2" > "$3"
}

baker_prepare() {
	[[ -d .baker ]] || mkdir .baker
	[[ -f .baker/status ]] || touch .baker/status
	: > .baker/status_new
	[[ -d "$OUTPUT_DIR" ]] || mkdir "$OUTPUT_DIR"
	cp -r "$PUBLIC_DIR"/* "$OUTPUT_DIR"
	cp -r "$CONTENT_DIR" "$OUTPUT_DIR"
}

baker_finish() {
	mv .baker/status_new .baker/status
	[[ -f "$DEBUG" ]] && error "see '$DEBUG'"
}

# $1 = file
need_bake() {
	local md5
	[[ -d  "$1" ]] && md5="$(ls -lR "$1" | md5sum | sed "s|-|$1|g")" || md5="$(md5sum "$1")"
	echo "$md5" >> .baker/status_new
	! grep -q "^$md5$" .baker/status
}

bake_posts() {
	local post
	while IFS= read -r post; do
		(
		need_bake "$post" || continue
		echo "$post"
		safe_template "$(map_merge "$1" "$(post_binding "$post")")" \
			"$LAYOUT_DIR/$(header layout <"$post").html" \
			"$OUTPUT_DIR/$(md_to_url "$post")"
		) &
	done < <(list_post)
	wait
}

bake_pages() {
	local page
	while IFS= read -r page; do
		(
		need_bake "$page" || continue
		echo "$page"
		safe_template "$(map_merge "$1" "$(page_binding "$page")")" \
			"$LAYOUT_DIR/$(header layout <"$page").html" \
			"$OUTPUT_DIR/$(md_to_url "$page")"
		) &
	done < <(list_page)
	wait
}

md_to_url() {
	[[ "$1" =~ ^(.*/)?([^/]+)\.md$ ]] && echo "${BASH_REMATCH[2]}.html"
}

# $1 = file
next_post() {
	list_post | tac | grep "$1$" -A 1 | grep -v "$1$"
}

next_post_title() {
	local post="$(next_post "$1")"
	[[ -f "$post" ]] && header title < "$post"
}

next_post_url() {
	md_to_url "$(next_post "$1")"
}

# $1 = file
prev_post() {
	list_post | tac | grep "$1$" -B 1 | grep -v "$1$"
}

prev_post_title() {
	local post="$(prev_post "$1")"
	[[ -f "$post" ]] && header title < "$post"
}

prev_post_url() {
	md_to_url "$(prev_post "$1")"
}

# $1 = file
post_binding() {
	local date="$(header date < "$1")"
	: | map_set \
		title "$(header title < "$1")" \
		url "$(md_to_url "$1")" \
		date "$date" \
		rss.date "$(date -R -d "$date")" \
		summary "$(body <"$1" | summary)" \
		prev.url "$(prev_post_url "$1")" \
		prev.title "$(prev_post_title "$1")" \
		next.url "$(next_post_url "$1")" \
		next.title "$(next_post_title "$1")" \
		content "$(body <"$1" | markdown )"
}

page_binding() {
	: | map_set \
		title "$(header title < "$1")" \
		url "$(md_to_url "$1")" \
		meta "$(header meta < "$1")" \
		content "$(body <"$1" | markdown)"
}

# $1 = function
filter() {
	local list
	local i=0
	local line
	while IFS= read -r line; do
		if [[ "$list" ]]; then
			list="$(map_set "$i" "$($1 "$line")" <<<"$list")"
		else
			list="$(: | map_set "$i" "$($1 "$line")")"
		fi
		((i++))
	done
	echo "$list"
}

post_collection_binding() {
	list_post | tac | filter post_binding
}

page_collection_binding() {
	list_page | tac | filter page_binding
}

bake_index() {
	bake_index=false
	need_bake "$POST_DIR" && bake_index=true
	need_bake "$PAGE_DIR" && bake_index=true
	need_bake "$LAYOUT_DIR" && bake_index=true
	need_bake "$INCLUDE_DIR" && bake_index=true
	$bake_index || return

	local post_collection="$(post_collection_binding)"
	local page_collection="$(page_collection_binding)"
	(
	echo index
	safe_template "$(map_set posts "$post_collection" pages "$page_collection" <<<"$1")" \
		"$LAYOUT_DIR/index.html" "$OUTPUT_DIR/index.html"
	) &
	(
	echo rss
	safe_template "$(map_set posts "$post_collection" pages "$page_collection" <<<"$1")" \
		"$LAYOUT_DIR/rss.html" "$OUTPUT_DIR/rss.xml"
	) &

	wait
}

summary() {
	local len
	[[ "$1" =~ ^[0-9]+$ ]] && len=$1 || len=100
	local rep=""
	local newline=$'\n'
	local line
	while IFS= read -r line; do
		rep+="$line$newline"
		(( ${#rep} < $len )) || break
	done
	markdown <<< "$rep"
}

bake() {
	baker_prepare
	local binding="$(< "$BINDING")"
	is_map <<<"$binding" || error "invalid format: $BINDING"

	headline buiding index
	timer bake_index "$binding"

	headline buiding posts
	timer bake_posts "$binding"

	headline buiding pages
	timer bake_pages "$binding"

	baker_finish
}
