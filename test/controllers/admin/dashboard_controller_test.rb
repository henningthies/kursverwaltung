require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin   = users(:admin)
    @learner = users(:learner)
  end

  test "dashboard requires login" do
    get admin_dashboard_url
    assert_redirected_to new_session_url
  end

  test "learner is blocked from the dashboard" do
    sign_in_as(@learner)
    get admin_dashboard_url
    assert_redirected_to root_url
  end

  test "admin sees the dashboard with KPIs" do
    sign_in_as(@admin)
    get admin_dashboard_url
    assert_response :success
    assert_select "h1", text: /Kurse/
  end

  test "revenue KPI sums only paid orders" do
    @learner.orders.create!(status: "paid",    total_cents: 5000, paid_at: Time.current)
    @learner.orders.create!(status: "pending", total_cents: 9999)

    sign_in_as(@admin)
    get admin_dashboard_url
    # 50,00 € aus der bezahlten Bestellung; die pending darf nicht zählen.
    assert_match(/50,00/, response.body)
    assert_no_match(/99,99/, response.body)
  end

  test "lists courses with price and enrollment counts" do
    sign_in_as(@admin)
    get admin_dashboard_url
    assert_match "Claude Code im Projektalltag", response.body
    assert_match(/129,00/, response.body)
  end
end
