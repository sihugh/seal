class PullRequestFormatter
  attr_reader :pull_request

  def initialize(pull_request, index)
    @pull_request = pull_request
    @index = index
  end

  def present
    <<-EOF.gsub(/^\s+/, '')
    #{@index + 1}\) *#{escaped_repo(pull_request)}* | #{escaped_author(pull_request)} | updated #{when_updated(pull_request)}#{thumbs_up(pull_request)}
    #{labels(pull_request)} <#{escaped_link(pull_request)}|#{escaped_title(pull_request)}> - #{comments(pull_request)}
    EOF
  end

private

  def comments(pr)
    return "1 comment" if pr["comments_count"] == "1"
    "#{pr["comments_count"]} comments"
  end

  def when_updated(pr)
    days_plural(age_in_days(pr))
  end

  def age_in_days(pull_request)
    (Date.today - pull_request['updated']).to_i
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

  def labels(pull_request)
    pull_request['labels']
      .map { |label| "[#{escaped_label(label)}]" }
      .join(' ')
  end

  def thumbs_up(pr)
    if pr["thumbs_up"].to_i > 0
      " | #{pr["thumbs_up"].to_i} :+1:"
    else
      ""
    end
  end

  def escaped_author(pr)
    escape_for_slack(pr["author"])
  end

  def escaped_label(label)
    escape_for_slack(label['name'])
  end

  def escaped_link(pr)
    escape_for_slack(pr["link"])
  end

  def escaped_repo(pr)
    escape_for_slack(pr["repo"])
  end

  def escaped_title(pr)
    escape_for_slack(pr["title"])
  end

  def escape_for_slack(text)
    text.gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
  end

end