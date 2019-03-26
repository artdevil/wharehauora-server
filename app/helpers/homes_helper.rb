# frozen_string_literal: true

module HomesHelper
  def selected_other(list_for_select, selected_data)
    !list_for_select.include?(selected_data)
  end
end
