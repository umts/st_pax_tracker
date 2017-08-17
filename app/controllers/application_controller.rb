class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :access_control
  before_action :check_primary_account

  private

  def deny_access
    if request.xhr?
      head :unauthorized
    else
      render file: 'public/401.html',
             status: :unauthorized,
             layout: false
    end
  end

  # Disable ABC size because this block will likely be
  # changed in a later branch
  # rubocop:disable AbcSize
  def set_current_user
    binding.pry
    @current_user =
      if session.key? :user_id
        User.find_by id: session[:user_id]
      elsif request.env.key? 'fcIdNumber'
        User.find_by spire: request.env['fcIdNumber']
      end
    if @current_user.present?
      session[:user_id] = @current_user.id
    else redirect_to unauthenticated_session_path
    end
  end
  # rubocop:enable AbcSize

  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back(fallback_location: 'public/404.html') and return
  end
  # rubocop:enable Style/AndOr

  def check_primary_account
    return if request.env['UMAPrimaryAccount'] == request.env['uid']
    @primary_account = request.env['UMAPrimaryAccount']
    @uid = request.env['uid']
    render 'sessions/unauthenticated_subsidiary',
           status: :unauthorized,
           layout: false
  end

  def access_control
    deny_access && return unless @current_user.present? && @current_user.admin?
  end
end
