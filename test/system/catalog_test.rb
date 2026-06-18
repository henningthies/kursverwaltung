require "application_system_test_case"

class CatalogTest < ApplicationSystemTestCase
  # Smoke-Test: Marketplace rendert im echten Browser und zeigt aktive Kurse.
  test "marketplace zeigt aktive Kurse" do
    visit root_path

    assert_text "Claude Code im Projektalltag"
  end

  # Die Kursdetailseite rendert die Bewertungssektion (Feature course-reviews).
  test "kursdetailseite zeigt die Bewertungssektion" do
    visit catalog_course_path(courses(:claude_code))

    assert_text "Was Teilnehmer sagen"
  end
end
