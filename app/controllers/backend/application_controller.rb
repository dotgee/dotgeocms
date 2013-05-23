require "application_responder"

class Backend::ApplicationController < ActionController::Base
  before_filter :set_locale
  self.responder = ApplicationResponder
  respond_to :html, :json

  layout "backend"

  protect_from_forgery

  set_current_tenant_by_subdomain(:account, :subdomain)
  before_filter :require_login

  private
  def not_authenticated
    redirect_to login_url, :alert => "First log in to view this page."
  end

  def set_locale
      session[:locale] = params[:locale] if params[:locale]
      session[:locale] ||= :fr
      I18n.locale = session[:locale]
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_tenant)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to backend_root_url, :alert => t("access_denied")
  end
end
