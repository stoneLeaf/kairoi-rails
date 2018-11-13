# frozen_string_literal: true

# Controller for Projects
class ProjectsController < ApplicationController
  before_action :set_project, except: %i[index new create]
  before_action :members_only, only: :show
  before_action :managers_only, only: %i[edit update]
  before_action :leads_only, only: :destroy

  rescue_from ActiveRecord::RecordNotFound, with: :handle_project_not_found

  def index; end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.build(project_params)

    # Validation is done in controller because it depends on current_user
    # TODO: ugly and probably a better way to do it
    # if current_user.projects.exists?(name: project_params[:name])
    #  @project.errors.add(:name, "you already have a project with the same name")
    # end

    if @project.save
      current_user.collaborations.create(project: @project,
                                         nature: Collaboration.natures[:lead])
      flash[:success] = "Project created!"
      redirect_to project_url(@project)
    else
      render 'new'
    end
  end

  def show; end

  def edit; end

  def update; end

  def destroy
    @project.destroy
    flash[:success] = "Project deleted."
    redirect_to projects_url
  end

  private

  def members_only
    raise Exceptions::ActionDeniedError unless @project.member_rights?(current_user)
  end

  def managers_only
    raise Exceptions::ActionDeniedError unless @project.manager_rights?(current_user)
  end

  def leads_only
    raise Exceptions::ActionDeniedError unless @project.lead_rights?(current_user)
  end

  def handle_project_not_found
    flash[:danger] = "Project not found."
    redirect_to projects_url and return
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
  end

  def unique_name_for_user

  end
end