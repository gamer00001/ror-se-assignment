class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :employee_service
  before_action :set_employee, only: %i[ show edit new create update]

  def index
    page = params[:page].presence
    employee_data = employee_service.fetch_employees(page)
    @meta = employee_data["meta"]
    @employees  = employee_data["data"].map {|e| Employee.new(e) }
  end

  def create
    if @employee.valid?
      new_employee = employee_service.create_employee(employee_params)
      @employee = Employee.new(new_employee)
      redirect_to employee_path(@employee.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @employee.valid?
      updated_employee = employee_service.update_employee(params[:id], employee_params)
      @employee = Employee.new(updated_employee)
      redirect_to employee_path(@employee.id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def employee_service
    employee_service ||= EmployeeService.new
  end

  def set_employee
    @employee ||= if ["create", "update"].include?(action_name)
                    Employee.new(employee_params.merge(id: params[:id]))
                  elsif params[:id].present?
                    Employee.new(employee_service.fetch_employee(params[:id]))
                  else
                    Employee.new
                  end
  end

  def employee_params
    params.require(:employee).permit(:name, :position, :date_of_birth, :salary, :id)
  end
end
