class ListsController < ApplicationController
  before_filter :grab_page
  before_filter :login_required
  
  # GET /lists
  # GET /lists.xml
  def index
    @lists = List.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lists }
    end
  end

  # GET /lists/1
  # GET /lists/1.xml
  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/new
  # GET /lists/new.xml
  def new
    @list = List.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id])
  end

  # POST /lists
  # POST /lists.xml
  def create
    # Calculate target position
    # TODO: move to main controller as util function?
    if !params[:position].nil?
        pos = params[:position]
        insert_id = pos[:slot].to_i
        @insert_before = insert_id == 0 ? true : (pos[:before].to_i == 1)
    else
        insert_id = nil
        @insert_before = true
    end
    
    # Make the darn note
    @list = List.new(params[:list])
    @list.name ||= :List.l
    @list.page = @page
    saved = @list.save
    
    # And the slot, don't forget the slot
    if saved
        @slot = @page.new_slot_at(@list, insert_id, @insert_before)
        @insert_element = insert_id == 0 ? 'page_slot_footer' : "page_slot_#{insert_id}"
        @new_list = true
    end

    respond_to do |format|
      if @list.save
        flash[:notice] = 'List was successfully created.'
        format.html { redirect_to(@list) }
        format.js {}
        format.xml  { render :xml => @list, :status => :created, :location => @list }
      else
        format.html { render :action => "new" }
        format.js {}
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.xml
  def update
    @list = List.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        flash[:notice] = 'List was successfully updated.'
        format.html { redirect_to(@list) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.xml
  def destroy
    @list = List.find(params[:id])
    @slot_id = @list.page_slot.id
    @list.page_slot.destroy
    @list.destroy

    respond_to do |format|
      format.html { redirect_to(lists_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
  
  # POST /lists/1/reorder
  def reorder
    list = List.find(params[:id])
    order = params[:items].collect { |id| id.to_i }
    
    list.list_items.each do |item|
        idx = order.index(item.id)
        item.position = idx
        puts "pos=#{item.position}"
        item.position ||= list.list_items.length
        puts "pos=#{item.position}"
        puts "--"
        item.save!
    end
    puts "!!"
    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
      format.xml  { head :ok }
    end
  end
  
end