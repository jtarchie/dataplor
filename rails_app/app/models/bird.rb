# frozen_string_literal: true

class Bird < ApplicationRecord
  belongs_to :node

  def self.ids_from_nodes(node_ids)
    all_node_ids = Node.descendant_node_ids(node_ids)
    Bird.where(node_id: all_node_ids).pluck(:id)
  end
end
