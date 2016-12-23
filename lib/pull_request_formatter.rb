class PullRequestFormatter
  attr_reader :pull_request

  [:comments_count, :thumbs_up_count].each do |field|
    define_method(field) do
      pull_request[field.to_s].to_i
    end
  end

  [:author, :link, :repo, :title].each do |field|
    define_method(field) do
      escaped_property(field.to_s)
    end
  end

  def initialize(pull_request, index)
    @pull_request = pull_request
    @index = index
  end

  def present
    <<-EOF.gsub(/^\s+/, '')
    #{@index + 1}\) *#{repo}* | #{author} | updated #{when_updated}#{format_thumbs_up}
    #{format_labels} <#{link}|#{title}> - #{format_comments}
    EOF
  end

private

  def format_comments
    return "1 comment" if comments_count == 1
    "#{comments_count} comments"
  end

  def format_labels
    labels.map { |label| "[#{label}]" }
      .join(' ')
  end

  def labels
    pull_request['labels']
      .map { |label| "#{escape(label['name'])}" }
  end

  def format_thumbs_up
    if thumbs_up_count > 0
      " | #{thumbs_up_count} :+1:"
    else
      ""
    end
  end

  def when_updated
    age_in_days = (Date.today - pull_request['updated']).to_i
    days_plural(age_in_days)
  end

  def days_plural(days)
    case days
    when 0
      'today'
    when 1
      "yesterday"
    else
      "#{days} days ago"
    end
  end

  def escaped_property(key)
    escape(pull_request[key])
  end

  def escape(text)
    text.gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
  end
end