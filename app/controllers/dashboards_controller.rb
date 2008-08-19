class DashboardsController < ApplicationController
  layout 'pages'
  
  # GET /dashboard
  def show
    @recent_activities = ApplicationLog.find(:all, :order => 'created_on DESC').group_by do |obj|
        obj.created_on.to_date.to_s
    end
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end