class CreateToolService
  attr_accessor :params, :payload

  def initialize(params)
    @params = params
  end

  def create
    if payload && payload['ref'] == "refs/heads/master" # ignore other branches
      Tool.create!(name: tool_name, language: tool_language, json_spec: json_spec)
      translate_keys = create_translate_keys
      create_translate_file(translate_keys)
    end
  end

  private

  def payload
    @payload ||= JSON.parse(params['payload'])
  end

  def filename
    payload["commits"].first["added"].first
  end

  def json_spec
    @json_spec ||= begin
      content = (Octokit.contents "feruzoripov/dev_challenge_json_specs", path: filename).content
      Base64.decode64(content).force_encoding('UTF-8')
    end
  end

  def tool_name
    filename.split('.').first
  end

  def tool_language
    filename.split('.').second
  end

  def create_translate_file(h)
    File.open("#{Rails.root}/app/locales/#{tool_name}.#{tool_language}.yml", "w") { |file| file.write(h.to_yaml) }

    puts '#########################################'
    puts "Created #{tool_name}.#{tool_language}.yml"
    puts '#########################################'
  end

  def flatten_hash(h)
    return { "" =>  h } unless h.is_a?(Hash)

    Hash[
      h.map do |a,v1|
        flatten_hash(v1).map do |b,v2|
          [[a,b].map(&:to_s).delete_if(&:empty?).join('_'), v2]
        end
      end.flatten(1)
    ]
  end

  def create_translate_keys
    result = {}
    parsed_json_spec = JSON.parse(json_spec)
    flatten_hash(parsed_json_spec).each do |key, value|
      if value.is_a? String
        result["#{tool_name}_#{key}"] = value
      end
    end
    result
  end
end
