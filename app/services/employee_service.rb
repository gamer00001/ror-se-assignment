class EmployeeService
  BASE_URL = 'https://dummy-employees-api-8bad748cda19.herokuapp.com/employees'.freeze

  attr_reader :http_service

  def initialize
    @http_service = HttpService.new(BASE_URL)
  end

  def fetch_employees(page = nil)
    options = page ? { query: { page: page } } : {}
    http_service.get('', options)
  end

  def fetch_employee(id)
    http_service.get("/#{id}")
  end

  def create_employee(attributes)
    http_service.post('', attributes)
  end

  def update_employee(id, attributes)
    http_service.put("/#{id}", attributes)
  end
end
