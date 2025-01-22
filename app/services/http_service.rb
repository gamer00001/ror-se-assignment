class HttpService
  include HTTParty

  attr_accessor :default_headers

  def initialize(base_uri)
    self.class.base_uri(base_uri)
    @default_headers = { 'Content-Type' => 'application/json' }
  end

  def get(endpoint, options = {}, headers = {})
    self.class.get(endpoint, merge_options(options, headers))
  end

  def post(endpoint, body, headers = {})
    self.class.post(endpoint, body: body.to_json, headers: merge_headers(headers))
  end

  def put(endpoint, body, headers = {})
    self.class.put(endpoint, body: body.to_json, headers: merge_headers(headers))
  end

  private

  def merge_headers(headers)
    default_headers.merge(headers)
  end

  def merge_options(options, headers)
    options.merge(headers: merge_headers(headers))
  end
end
