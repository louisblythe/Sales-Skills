# frozen_string_literal: true

require 'yaml'

Dir.chdir(File.expand_path('..', __dir__))
errors = []
skill_names = Dir.glob('skills/*').select { |path| File.directory?(path) }.map { |path| File.basename(path) }
errors << 'No skill directories found' if skill_names.empty?

skill_names.each do |name|
  path = "skills/#{name}/SKILL.md"
  unless File.file?(path)
    errors << "#{path}: missing"
    next
  end

  frontmatter = File.read(path).match(/\A---\r?\n(.*?)^---[ \t]*\r?$/m)
  unless frontmatter
    errors << "#{path}: missing YAML frontmatter"
    next
  end

  begin
    data = YAML.safe_load(frontmatter[1])
    unless data.is_a?(Hash) && data['name'] == name
      errors << "#{path}: frontmatter name must match its directory"
      next
    end

    description = data['description']
    errors << "#{path}: description must be a non-empty string" unless description.is_a?(String) && !description.strip.empty?
  rescue Psych::Exception => e
    errors << "#{path}: #{e.message}"
  end
end

File.read('README.md').scan(/\]\((skills\/[^)\s#]+)\)/).flatten.uniq.each do |path|
  target = File.directory?(path) ? File.join(path, 'SKILL.md') : path
  errors << "README.md: broken skill link #{path}" unless File.file?(target)
end

Dir.glob('agents/*.md').each do |path|
  routing = File.read(path).split(/^## Routing map\s*\r?$/, 2)[1]
  next unless routing

  routing.split(/^## /, 2).first.scan(/\x60([a-z0-9-]+)\x60/).flatten.uniq.each do |name|
    errors << "#{path}: unknown routed skill #{name}" unless skill_names.include?(name)
  end
end

abort errors.join("\n") unless errors.empty?

puts "Validated #{skill_names.length} skills, README skill links, and any agent routing maps."
