class RepoController < ApplicationController

  before_filter :signed_in_user

  def directory_hash(path, name=nil)
    data = {:data => (name || path)}
    data[:children] = children = []
    Dir.entries(path).sort.each do |entry|
      next if ( /^\./ =~ entry )
      full_path = File.join(path, entry)
      if File.directory?(full_path)
        children << directory_hash(full_path, entry)
      elsif /.pl$|.oy$/ =~ entry
        children << entry
      end
    end
    return data
  end

  def list

    @repos = directory_hash('repos')

    @repos[:children].each do |r|
      r[:info] = Repo::info( r[:data] )
    end

    if params[:highlight]
      @highlight = params[:highlight]
    else
      @highlight = @repos[:children].last[:data]
    end

    respond_to do |format|
      format.html
    end

  end

  def get

    @version = Repo::version(params[:path])

    if /.pl/ =~ params[:path]
      redirect_to interpreter_arguments_path(sha: @version, path: params[:path]) 
    else
      redirect_to arguments_new_metacol_path(sha: @version, path: params[:path]) 
    end
    
  end

  def pull

    flash[:notice] = params[:name] + ": " + Git.open("repos/"+params[:name]).pull()
    logger.info "PULLED CHANGES FOR #{params[:name]}"
    redirect_to repo_list_path( highlight: params[:name])

  end

end