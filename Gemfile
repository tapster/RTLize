source "http://rubygems.org"

# Declare your gem's dependencies in rtlize.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

rails_version = ENV["RAILS_VERSION"] || "4.0.0"

rails = case rails_version
when "master"
  {:github => "rails/rails"}
else
  "~> #{rails_version}"
end

gem "rails", rails
