class UpdateToolService
  attr_accessor :name, :language, :master

  def initialize(name, language, master=false)
    @name = name
    @language = language
    @master = master
  end

  def update
    branch = create_new_branch
    update_content
    create_pull_request(branch)
  end

  private

  def filename
    master ? "#{name}.#{language}.master.json" : "#{name}.#{language}.json"
  end

  def new_file_content
    @new_file_content ||= YAML.load_file("locales/#{name}.#{language}.yml")
  end

  def current_file_content
    @current_file_content ||= begin
      current_content = octokit_client.contents repo, path: filename, sha: @base_branch_sha
      JSON.parse(Base64.decode64(current_content.content).force_encoding('UTF-8'))
    end
  end

  def update_file_content
    new_file_content.each do |key, value|
      path = key.split('_')[1..]
      deep_set(current_file_content.deep_stringify_keys!, path, value)
    end

    JSON.pretty_generate(current_file_content)
  end

  def deep_set(hash, path, value)
    *path, final_key = path
    to_set = path.empty? ? hash : hash.dig(*path)

    return unless to_set
    to_set[final_key] = value
  end

  def octokit_client
    @client ||= Octokit::Client.new(access_token: '')
  end

  def new_branch_name
    @new_branch_name ||= "update-#{name}-#{language}-#{rand(100000)}"
  end

  def create_new_branch
    master = octokit_client.refs(repo).find do |reference|
      "refs/heads/master" == reference.ref
    end

    @base_branch_sha = master.object.sha
    new_branch = octokit_client.create_ref(repo, "heads/#{new_branch_name}", @base_branch_sha)
    new_branch
  end

  def repo
    "feruzoripov/dev_challenge_json_specs"
  end

  def update_content
    @new_content ||= {
      filename => update_file_content,
    }
  end

  def create_pull_request(new_branch)
    new_tree = [
      Hash(
        path: filename,
        mode: "100644",
        type: "blob",
        sha: octokit_client.create_blob(repo, update_content[filename])
      )
    ]

    commit = octokit_client.git_commit(repo, new_branch["object"]["sha"])
    tree = commit["tree"]
    new_tree = octokit_client.create_tree(repo, new_tree, base_tree: tree["sha"])
    commit_message = "Update translations"
    new_commit = octokit_client.create_commit(repo, commit_message, new_tree["sha"], commit["sha"])
    octokit_client.update_ref(repo, "heads/#{new_branch_name}", new_commit["sha"])
    title = "Update #{filename}"
    body = "Updating Translation Keys"
    octokit_client.create_pull_request(repo, "master", new_branch_name, title, body)
  end
end
