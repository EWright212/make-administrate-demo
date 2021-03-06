#/bin/bash

set -e

usage() {
	name=$(basename "$0")

	cat <<-EOT
	${name} [project_name]

	Create a new Rails project for testing Administrate. Fresh Rails app, with a
	single model with migrations run already.
	EOT
	exit 1
}

if [ "$#" -lt 1 ]; then
	usage;
	exit 1;
fi

source ~/.rvm/scripts/rvm



main() {
	project_name=$1
	
	type rvm | head -n 1	

	echo "=> Switch to the suspenders version of Ruby..."
	rvm use 2.6.6

	echo "=> Installing the latest suspenders release..."
	gem install suspenders

	echo "=> Creating a minimal Rails application..."
	suspenders $project_name --skip-keeps --skip-action-mailbox \
		--skip-action-text --skip-active-storage --skip-action-cable --skip-spring

	echo "=> Creating an example Post model and migrating..."
	cd $project_name
	bundle exec rails g model post title:string body:text published_at:datetime
	bundle exec rails db:migrate

	echo "=> Adding Administrate and re-bundling.."
	echo "$(awk '/^gem/ && !done { print "gem \"administrate\""; done=1;}; 1;' Gemfile)" > Gemfile
	bundle

	bundle exec rails g administrate:install

	echo
	echo
	echo "$project_name created as a new Rails app, with Administrate bundled."
}

main "$@"
