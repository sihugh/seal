class PullRequestFormatter
  attr_reader :pull_request

  def initialize(pull_request, index)
    @pull_request = pull_request
    @index = index
  end

  def present
    <<-EOF.gsub(/^\s+/, '')
    #{@index + 1}\) *#{repo}* | #{author} | updated #{when_updated}#{thumbs_up}
    #{labels} <#{link}|#{title}> - #{comments}
    EOF
  end

private

  def comments_count
    pull_request["comments_count"].to_i
  end

  def comments
    return "1 comment" if comments_count == 1
    "#{comments_count} comments"
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

  def labels
    pull_request['labels']
      .map { |label| "[#{format_label(label)}]" }
      .join(' ')
  end

  def format_label(label)
    escape_for_slack(label['name'])
  end

  def thumbs_up_count
    pull_request["thumbs_up"].to_i
  end

  def thumbs_up
    if thumbs_up_count > 0
      " | #{thumbs_up_count} :+1:"
    else
      ""
    end
  end

  def author
    escape_for_slack(pull_request["author"])
  end

  def link
    escape_for_slack(pull_request["link"])
  end

  def repo
    escape_for_slack(pull_request["repo"])
  end

  def title
    escape_for_slack(pull_request["title"])
  end

  def escape_for_slack(text)
    text.gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
  end
end