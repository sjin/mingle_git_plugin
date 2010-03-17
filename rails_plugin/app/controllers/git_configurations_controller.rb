class GitConfigurationsController < ApplicationController

  verify :method => :post, :only => [ :save, :create ]
  verify :method => :put, :only => [ :update ]

  privileges :project_admin => ['index', 'save', 'update', 'show', 'create']

  def current_tab
    Project::ADMIN_TAB_INFO
  end

  def admin_action_name
    super.merge(:controller => 'repository')
  end

  # render the settings page for git configuration
  def index
    @git_configuration = GitConfiguration.find(:first, :conditions => ["marked_for_deletion = ? AND project_id = ?", false, @project.id])
    respond_to do |format|
      format.html do
        render :template => 'git_configurations/index'
      end
      format.xml do
        if !@git_configuration.blank? 
          render :xml => [@git_configuration].to_xml
        else
          render :xml => "No Git configuration found in project #{@project.identifier}.", :status => 404
        end
      end
    end
  end

  def save
    create_or_update
    if @git_configuration.errors.empty?
      flash[:notice] = 'Repository settings were successfully saved.' 
    else
      set_rollback_only
      flash[:error] = @git_configuration.errors.full_messages.join(', ')
    end

    redirect_to :action => 'index'
  end

  def show
    @git_configuration = MinglePlugins::Source.find_for(@project)
    respond_to do |format|
      format.xml do
        if @git_configuration 
          render :xml => @git_configuration.to_xml
        else
          render :xml => "No git configuration found in project #{@project.identifier}.", :status => 404
        end
      end
    end
  end

  def update
    @git_configuration = GitConfiguration.find_by_id(params[:id])
    create_or_update if @git_configuration
    
    respond_to do |format|
      format.xml do
        if @git_configuration.nil?
          render :xml => "No Git configuration found in project #{@project.identifier} with id #{params[:id]}.", :status => 404
        elsif @git_configuration.errors.empty?
          render :xml => @git_configuration.to_xml
        else
          render :xml => @git_configuration.errors.to_xml, :status => 422
        end
      end
    end
  end

  def create
    create_or_update
    respond_to do |format|
      format.xml do
        if @git_configuration.errors.empty?
          head :created, :location => url_for(:action => @git_configuration.id, :format => :xml)
        else
          render :xml => @git_configuration.errors.to_xml, :status => 422
        end
      end
    end
  end

  def create_or_update
    @git_configuration = GitConfiguration.create_or_update(@project.id, params[:id], params[:git_configuration])
  end

end