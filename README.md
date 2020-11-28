# OnContainer

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/on_container`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'on_container'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install on_container

## Usage

### Development Routines & Docker Entrypoint Scripts

We use some routines included in this gem to create compelling development entrypoint scripts for docker development containers.

In this example, we'll be using the `on_container/dev/rails` routine bundle to create our dev entrypoint:

```ruby
#!/usr/bin/env ruby

# frozen_string_literal: true

require 'on_container/dev/rails'

set_given_or_default_command

# `on_setup_lock_acquired` prevents multiple app containers from running
# the setup process concurrently:
on_setup_lock_acquired do
  ensure_project_gems_are_installed
  ensure_project_node_packages_are_installed

  wait_for_service_to_accept_connections 'tcp://postgres:5432'
  setup_activerecord_database unless activerecord_database_ready?

  remove_rails_pidfile if rails_server?
end if command_requires_setup?

execute_given_or_default_command
```

### Loading secrets into environment variables, and inserting credentials into URL environment variables

When using Docker Swarm, the secrets are loaded as files mounted into the container's filesystem.

The `on_container/load_env_secrets` runs a couple of routines that reads these files into environment variables.

For our Rails example app, we added the following line to the `config/boot.rb` file:

```ruby
# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'on_container/load_env_secrets' # Load secrets injected by Kubernetes/Swarm

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
```

The `on_container/load_env_secrets` also merges any credential available in environment variables into any matching
`_URL` environment variable. For example, consider the following environment variables:

```shell
DATABASE_URL=postgres://postgres:5432/?encoding=unicode
DATABASE_USER=postgres
DATABASE_PASS=3x4mpl3P455w0rd
```

The routine will merge `DATABASE_USER` and `DATABASE_PASS` into `DATABASE_URL`:

```ruby
puts ENV['DATABASE_URL']
> postgres://postgres:3x4mpl3P455w0rd@postgres:5432/?encoding=unicode
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/on_container. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/on_container/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OnContainer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/on_container/blob/master/CODE_OF_CONDUCT.md).
