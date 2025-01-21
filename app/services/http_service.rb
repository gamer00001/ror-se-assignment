class HttpService
  include HTTParty

  def initialize(base_uri)
    self.class.base_uri(base_uri)
    @default_headers = { 'Content-Type' => 'application/json' }
  end

  def get(endpoint, options = {}, headers = {})
    handle_response(self.class.get(endpoint, merge_options(options, headers)))
  end

  def post(endpoint, body, headers = {})
    handle_response(self.class.post(endpoint, body: body.to_json, headers: merge_headers(headers)))
  end

  def put(endpoint, body, headers = {})
    handle_response(self.class.put(endpoint, body: body.to_json, headers: merge_headers(headers)))
  end

  private

  def merge_headers(headers)
    @default_headers.merge(headers)
  end

  def merge_options(options, headers)
    options.merge(headers: merge_headers(headers))
  end

  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    else
      log_error(response)
      { error: "Request failed with status code #{response.code}" }
    end
  end

  def log_error(response)
    Rails.logger.error("HTTP Request Failed: Code=#{response.code}, Body=#{response.body}")
  end
end
