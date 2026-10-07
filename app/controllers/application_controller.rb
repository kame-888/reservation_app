class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :back_to_list_path

  protected

  def configure_permitted_parameters
    keys = [:first_name, :family_name, :avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end

  private

  def back_to_list_path
    session[:rooms_index_url].presence || rooms_path
  end
end
