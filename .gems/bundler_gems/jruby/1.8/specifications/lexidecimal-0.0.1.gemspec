# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lexidecimal}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Masover"]
  s.date = %q{2010-05-27}
  s.email = %q{ninja@slaphack.com}
  s.files = ["README", "lib/lexidecimal.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{lexically-stortable string representations of BigDecimal}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
