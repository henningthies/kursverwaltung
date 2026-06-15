require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # Vor dem Euro-Zeichen steht ein geschütztes Leerzeichen (U+00A0).
  NBSP = "\u00A0".freeze

  test "price_display zeigt Gratis bei 0 Cent" do
    assert_equal "Gratis", price_display(0)
  end

  test "price_display formatiert kleine Beträge deutsch" do
    assert_equal "9,99#{NBSP}€", price_display(999)
    assert_equal "49,00#{NBSP}€", price_display(4900)
  end

  test "price_display setzt Tausender-Trennzeichen" do
    assert_equal "1.200,00#{NBSP}€", price_display(120_000)
    assert_equal "1.234.567,89#{NBSP}€", price_display(123_456_789)
  end
end
