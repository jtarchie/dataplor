# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Node, type: :model do
  before do
    Node.from_csv(File.join(__dir__, '../assets/test.csv'))
  end

  context 'when loading nodes from a CSV file' do
    it 'creates a table of id and parent_id' do
      results = Node.connection.select_all(<<~SQL).to_a
        SELECT COUNT(*), MIN(id), MAX(id) FROM nodes
      SQL
      expect(results).to eq [{ 'count' => 5, 'max' => 5_497_637, 'min' => 125 }]
    end
  end

  context 'when loading ancestors' do
    it 'returns all nodes to the parent' do
      ancestors = Node.ancestors(5_497_637)
      expect(ancestors.length).to eq 4
      expect(ancestors.first).to eq OpenStruct.new(
        depth: 4,
        id: 5_497_637,
        parent_id: 4_430_546
      )
      expect(ancestors.last).to eq OpenStruct.new(
        depth: 1,
        id: 130,
        parent_id: nil
      )
    end
  end

  context 'when comparing ancestors of two nodes' do
    it 'returns the common ancestor and root node' do
      common = Node.common_ancestor(5_497_637, 2_820_230)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq OpenStruct.new(
        depth: 2,
        id: 125,
        parent_id: 130
      )

      common = Node.common_ancestor(5_497_637, 130)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq OpenStruct.new(
        depth: 1,
        id: 130,
        parent_id: nil
      )

      common = Node.common_ancestor(5_497_637, 4_430_546)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq OpenStruct.new(
        depth: 3,
        id: 4_430_546,
        parent_id: 125
      )

      common = Node.common_ancestor(4_430_546, 4_430_546)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq OpenStruct.new(
        depth: 3,
        id: 4_430_546,
        parent_id: 125
      )
    end

    it 'returns nil when one of the nodes does not exist' do
      common = Node.common_ancestor(9, 4_430_546)
      expect(common).to be_nil

      common = Node.common_ancestor(9, 101)
      expect(common).to be_nil
    end
  end
end
