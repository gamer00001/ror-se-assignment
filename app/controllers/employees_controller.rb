class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :employee_service
  before_action :set_employee, only: %i[ show edit new]

  def index
    page = params[:page].presence
    @employees, @meta = employee_service.employee_list(page).values_at(:employees, :meta)
  rescue EmployeeApiError => e
    @employees = []
    handle_exception(e)
  end

  def create
    @employee = employee_service.create_employee(employee_params)
    redirect_to employee_path(@employee.id)
  rescue EmployeeApiError => e
    handle_exception(e)
  end

  def update
    @employee = employee_service.update_employee(params[:id], employee_params)
    redirect_to employee_path(@employee.id)
  rescue EmployeeApiError => e
    handle_exception(e)
  end

  private

  def employee_service
    employee_service ||= EmployeeService.new
  end

  def set_employee
    @employee ||= if params[:id].present?
                    employee_service.retrieve_employee(params[:id])
                  else
                    Employee.new
                  end
  rescue EmployeeApiError => e
    handle_exception(e)
  end

  def handle_exception(error)
    parsed_data = JSON.parse(error.message)
    @errors = parsed_data['errors']
    employee_data = parsed_data['employee'].except("errors", "validation_context")
    @employee = Employee.new(employee_data)

    render render_view, status: :unprocessable_entity
  end

  def render_view
    case action_name
    when 'create'
      :new
    when 'update'
      :edit
    else
      action_name.to_sym
    end
  end

  def employee_params
    params.require(:employee).permit(:name, :position, :date_of_birth, :salary, :id).merge(id: params[:id])
  end
end
