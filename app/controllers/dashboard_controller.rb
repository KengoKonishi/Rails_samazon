class DashboardController < ApplicationController
    before_action :authenticate_admin!, except: :index
    layout 'dashboard/dashboard'
    
    def index
    end
end
