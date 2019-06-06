# frozen_string_literal: true

class Api::V1::HomeViewersController < Api::BaseController
  before_action :set_home, only: %i[create index destroy]
  respond_to :json

  def index
    @viewers = policy_scope(HomeViewer)
               .includes(:user)
               .where(home_id: @home.id)
               .page(params[:page])
  end

  def create
    @viewer = HomeViewer.new(home: @home, email: home_viewer_params[:email])

    if @viewer.assigned_user_to_home
      respond_with(@viewer)
    else
      respond_form_with_error(@viewer.errors, home_viewer_params)
    end
  end

  def destroy
    @viewer = @home.home_viewers.find(params[:id])
    if @viewer.destroy
      respond_with(@viewer)
    else
      respond_form_with_error(@viewer.errors)
    end
  end

  private

  def set_home
    @home = policy_scope(Home).find(params[:home_id])
    authorize @home, :edit?
  end

  def invite_user; end

  def home_viewer_params
    params.permit(:email)
  end
end
