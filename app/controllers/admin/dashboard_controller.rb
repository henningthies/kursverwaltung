module Admin
  class DashboardController < ApplicationController
    before_action :require_admin
    layout "admin"

    def index
      @active_courses_count = Course.published.count
      @confirmed_count      = Enrollment.confirmed.count
      @waitlisted_count     = Enrollment.waitlisted.count
      @revenue_cents        = Order.revenue_cents
      # BEWUSSTE DEMO-SCHWACHSTELLE (T3 Performance): wie courses#index ohne includes/
      # counter_cache — die Zähler je Zeile erzeugen N+1-Queries. NICHT vorab fixen.
      @courses = Course.ordered
    end
  end
end
