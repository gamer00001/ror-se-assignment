class EmployeeApiError < StandardError; end
class EmployeeService
  BASE_URL = 'https://dummy-employees-api-8bad748cda19.herokuapp.com/employees'.freeze

  attr_reader :http_service

  def initialize
    @http_service = HttpService.new(BASE_URL)
  end

  def employee_list(page = nil)
    options = page ? { query: { page: page } } : {}
    employees_data = handle_response(http_service.get('', options))
    employees  = employees_data['data'].map {|e| Employee.new(e) }
    { employees: employees, meta: employees_data['meta'] }
  end

  def retrieve_employee(id)
    employee_data = handle_response(http_service.get("/#{id}"))
    Employee.new(employee_data)
  end

  def create_employee(attributes)
    validate_employee(attributes)

    employee_data = handle_response(http_service.post('', attributes))
    Employee.new(employee_data)
  end

  def update_employee(id, attributes)
    validate_employee(attributes)

    employee_data = handle_response(http_service.put("/#{id}", attributes))
    Employee.new(employee_data)
  end

  private

  def validate_employee(attributes)
    employee = Employee.new(attributes)

    unless employee.valid?
      errors = employee.errors.map do |e| e.full_message end
      data = {
        errors: errors,
        employee: employee
      }
      raise EmployeeApiError, data.to_json
    end
  end

  def handle_response(response)
    raise EmployeeApiError, { errors: ["Request failed with status #{response.code}: #{response.body}" ], employee: Employee.new }.to_json unless response.success?

    response.parsed_response
  end
end
