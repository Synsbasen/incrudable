# frozen_string_literal: true

require_relative "incrudable/version"

module Incrudable
  extend ActiveSupport::Concern

  included do
    before_action :set_record, only: %i[show edit update destroy]
    before_action :set_records, only: %i[index]
    before_action :set_new_record, only: %i[new create]

    after_action :verify_authorized, unless: :skip_authorization?
    after_action :verify_policy_scoped, unless: :skip_policy_scope?
  end

  def index; end
  def show; end
  def new; end
  def edit; end

  def create  
    respond_to do |format|
      format.html { handle_html_response(record.save, :new, :after_create_path) }
      format.json { handle_json_response(record.save) }
    end
  end

  def update
    respond_to do |format|
      format.html { handle_html_response(record.update(record_params), :edit, :after_update_path) }
      format.json { handle_json_response(record.update(record_params)) }
    end
  end

  def destroy
    if record.destroy
      flash[:success] = t('.success', default: 'Successfully deleted.')
    end

    redirect_to after_destroy_path
  end

  private

  def permitted_params
    raise NotImplementedError, "You must override `permitted_params` in your controller"
  end

  def record_params
    params.fetch(resource_name, {}).permit(permitted_params)
  end

  def new_record_defaults
    {}
  end

  def after_destroy_path
    send("#{resource_name.pluralize}_path")
  end

  def skip_authorization?
    false
  end

  def skip_policy_scope?
    %w[new create].include?(action_name)
  end

  def record_param_identifier
    :id
  end

  # ----- The following methods shouldn't be overridden in the controller ----- #

  def resource
    controller_path.classify.demodulize.singularize.constantize
  end

  def resource_name
    resource.name.underscore.pluralize.tr('/', '_')
  end

  def record
    instance_variable_get("@#{resource_name}")
  end

  def set_instance_variable(name, value)
    instance_variable_set("@#{name}", value)
  end
  
  def set_record
    set_instance_variable(resource_name, policy_scope(resource).find_by!(record_param_identifier => params[record_param_identifier]))
    authorize record
  end

  def set_records
    set_instance_variable(resource_name.pluralize, policy_scope(resource))
    authorize instance_variable_get("@#{resource_name.pluralize}")
  end
  
  def set_new_record
    set_instance_variable(resource_name, resource.new(new_record_defaults.merge(record_params)))
    authorize record
  end

  def handle_html_response(success, template, path)
    if success
      flash[:success] = t(".success", default: "Successfully completed.")

      if respond_to?(path, true) && send(path).present?
        redirect_to send(path)
      else
        redirect_back fallback_location: root_path
      end
    else
      flash[:error] = record.errors.full_messages.to_sentence
      render template
    end
  end
  
  def handle_json_response(success)
    if success
      render json: { success: true, record: record }
    else
      render json: { success: false, errors: record.errors.full_messages.to_sentence }
    end
  end
end

