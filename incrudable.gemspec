# frozen_string_literal: true

require_relative "lib/incrudable/version"

Gem::Specification.new do |spec|
  spec.name = "incrudable"
  spec.version = Incrudable::VERSION
  spec.authors = ["Jimmy Poulsen", "Tobias Knudsen"]
  spec.email = ["jimmypoulsen96@gmail.com", "tobias.knudsen@gmail.com"]

  spec.summary = "A Rails concern for consistent and efficient CRUD operations"
  spec.description = "Incrudable is a Rails concern that standardizes and simplifies the creation of CRUD controllers. It provides a robust framework for handling common operations like index, show, create, update, and destroy with built-in support for authorization and error handling. By leveraging Incrudable, developers can focus on business logic while ensuring a consistent and maintainable codebase."  
  spec.homepage = "https://github.com/synsbasen/incrudable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "rails", ">= 5.2"
  spec.add_dependency "pundit", ">= 2.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
