release:
	bump patch
	gem build csv-query
	gem push csv-query-*.gem
