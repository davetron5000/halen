require 'gliffy'

class DiagramsController < ApplicationController

  Mime::Type.register 'image/jpeg', :jpg, [], ["jpeg"] 
  Mime::Type.register 'image/png', :png, [], ["png"] 
  Mime::Type.register 'image/svg+xml', :svg, [], ["svg"] 

  # Lists all diagrams.  if :wiki_page_id is set, finds the @wiki_page matching
  def index
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    @diagrams = self.gliffy_handle.folder_documents(APP_CONFIG['gliffy_folder']).sort{|a,b| a.name <=> b.name}
  end

  # Creates a new diagram and redirects the user to the editor.  The editor will be configured
  # such that, when they are done, they are returned to the wiki_page in edit mode, with the diagram tag inserted
  def new
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    new_name = params[:diagram_name] || 'New Diagram'
    new_diagram = self.gliffy_handle.document_create(new_name,APP_CONFIG['gliffy_folder'])
    redirect_to edit_url(@wiki_page,new_diagram.document_id)
  end

  def destroy
    self.gliffy_handle.document_delete(params[:id])
    redirect_to diagrams_url(params)
  end

  # Edits the diagram, returning the user to the wiki page in edit mode with the diagram id inserted
  def edit
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    redirect_to edit_url(@wiki_page,params[:id])
  end

  def show
    size = params[:size] || :L
    respond_to do |format|
      format.jpg { send_data self.gliffy_handle.document_get(params[:id],:jpeg,size), :type => "image/jpeg", :disposition => 'inline' }
      format.png { send_data self.gliffy_handle.document_get(params[:id],:png,size), :type => "image/png", :disposition => 'inline' }
      format.svg { send_data self.gliffy_handle.document_get(params[:id],:svg,size), :type => "image/svg+xml", :filename => params[:id] + ".svg" }
      format.xml { send_data self.gliffy_handle.document_get(params[:id],:xml,size), :type => "text/xml", :filename => params[:id] + ".xml" }
    end
  end

  def gliffy_handle
    APP_CONFIG[:gliffy]
  end

  def edit_url(wiki_page,diagram_id)
    return_url = diagrams_url unless wiki_page
    return_url = edit_wiki_page_path(wiki_page,:diagram_id => diagram_id,:only_path => false) if wiki_page
    self.gliffy_handle.document_edit_link(diagram_id,return_url,"Return to #{APP_CONFIG['wiki_name']}")
  end
end
