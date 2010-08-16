# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jruby-jars}
  s.version = "1.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Oliver Nutter"]
  s.date = %q{2010-06-06}
  s.description = %q{This gem includes the core JRuby code and the JRuby 1.8 stdlib as jar files.
It provides a way to have other gems depend on JRuby without including (and
freezing to) a specific jruby-complete jar version.}
  s.email = ["headius@headius.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "lib/jruby-jars.rb", "lib/jruby-jars/version.rb", "lib/jruby-core-1.5.1.jar", "lib/jruby-stdlib-1.5.1.jar"]
  s.homepage = %q{http://www.jruby.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{This gem includes the core JRuby code and the JRuby 1.8 stdlib as jar files}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
