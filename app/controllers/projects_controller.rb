class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_filter :require_login

  def index
    @projects = Project.all
  end

  def dashboard
    @projects = current_user.collaborator.projects.active
    render :json => @projects
  end


  def show
    if logged_in?
      # Showing all events from a repo for an activity feed
      # Will refactor to Github Adapter
      github = Github.new user: current_user.username, repo:"#{@project.name}", oauth_token: session["user_token"]
      all_repo_events = github.activity.events.repos

      @push_events = Project.find_push_events(all_repo_events)

      @languages = github.repos.languages.body.to_h
      @total_commits = github.repos.commits.list.count

      respond_to do |format|
        format.html { render :show }
        format.json {
          html_string = render_to_string 'show.html.erb', layout: false
          render json: {template: html_string}
        }
      end
    end
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)
    @project.admin = current_user.admin
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if !params[:mark_inactive] #normal mode
      new_collaborator = Collaborator.find_by(user_id: User.find(params[:project][:user]))
      @project.add_collaborator(new_collaborator)
      respond_to do |format|
        if @project.update(project_params)
          format.html { redirect_to @project, notice: 'Project was successfully updated.' }
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :edit }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    else #handle specific ajax call from dashboard to mark inactive
      @project.active = false
      @project.save
      render json: @project.id
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :github_id, :admin_id, :active, :new_collab)
    end
end
