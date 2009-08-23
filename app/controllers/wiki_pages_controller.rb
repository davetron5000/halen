class WikiPagesController < ApplicationController

  before_filter :login_required, :except => [:index, :show, :history, :version, :wiki_history]

  def history
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    if !@wiki_page
      head 404
    end
  end

  def wiki_history
    @wiki_pages = WikiPage.history
  end

  def version
    wiki_page = WikiPage.find(params[:wiki_page_id])
    if (wiki_page)
      if params[:sha1]
        wiki_page.history.each do |version|
          @wiki_page = version if version.sha1 == params[:sha1]
        end
        if @wiki_page
          @no_edit = true
          @version = params[:sha1]
          logger.info("HERE")
          render :action => 'show'
        else
          logger.warn "No version #{params[:sha1]} for #{params[:wiki_page_id]}"
          head 404
        end
      end
    else
      logger.warn "No page #{params[:wiki_page_id]}"
      head 404
    end
  end

  # GET /wiki_pages
  # GET /wiki_pages.xml
  def index
    @wiki_pages = WikiPage.search(params[:search])
    
    if @wiki_pages.size == 0
      flash[:error] = "Your search didn't return any results"
    elsif @wiki_pages.size == 1
      redirect_to :action => 'show', :id => @wiki_pages[0].name
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @wiki_pages }
        format.rss { render :layout => false }
      end
    end
    @wiki_pages = []
  end

  # GET /wiki_pages/1
  # GET /wiki_pages/1.xml
  def show
    @wiki_page = WikiPage.find(params[:id])
    if (@wiki_page)
      store_seen_page(@wiki_page.name)
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @wiki_page }
      end
    else
      redirect_to :action => 'new', :name => params[:id]
    end
  end

  # GET /wiki_pages/new
  # GET /wiki_pages/new.xml
  def new
    @wiki_page = WikiPage.new(:name => params[:name])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wiki_page }
    end
  end

  # GET /wiki_pages/1/edit
  def edit
    @wiki_page = WikiPage.find(params[:id])
    @wiki_page.content = "\n<!-- Move this tag to wherever you want the diagram to appear -->\n\ngliffy. #{params[:diagram_id]} | center | L\n\n" + @wiki_page.content if params[:diagram_id]
  end

  # POST /wiki_pages
  # POST /wiki_pages.xml
  def create
    @wiki_page = WikiPage.new(params[:wiki_page])
    @wiki_page.author = current_user

    respond_to do |format|
      if (params[:commit] == 'Cancel')
          format.html { redirect_to(wiki_page_url(params[:referring_pagename])) }
          format.xml  { head :ok }
      else
        if @wiki_page.save
          flash[:notice] = 'WikiPage was successfully created.'
          format.html { redirect_to(@wiki_page) }
          format.xml  { render :xml => @wiki_page, :status => :created, :location => @wiki_page }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @wiki_page.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /wiki_pages/1
  # PUT /wiki_pages/1.xml
  def update
    @wiki_page = WikiPage.find(params[:id])

    respond_to do |format|
      if @wiki_page
        if (params[:commit] == 'Cancel')
          format.html { redirect_to(@wiki_page) }
          format.xml  { head :ok }
        else
          if @wiki_page.update_attributes(params[:wiki_page])
            @wiki_page.author = current_user
            @wiki_page.save
            flash[:notice] = 'WikiPage was successfully updated.'
            format.html { redirect_to(@wiki_page) }
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @wiki_page.errors, :status => :unprocessable_entity }
          end
        end
      else
        head 404
      end
    end
  end

  # DELETE /wiki_pages/1
  # DELETE /wiki_pages/1.xml
  def destroy
    @wiki_page = WikiPage.find(params[:id])
    respond_to do |format|
      if @wiki_page
        @wiki_page.author = current_user
        @wiki_page.destroy
        format.html { redirect_to(wiki_pages_url) }
        format.xml  { head :ok }
      else
        head 404
      end
    end
  end

  private

  # Stores a page that the user has visited
  def store_seen_page(page_name)
    session[:history] ||= []
    session[:history].delete page_name
    session[:history] << page_name
  end
end
