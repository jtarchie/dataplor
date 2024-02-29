# frozen_string_literal: true

require_relative '../lib/node'

RSpec.describe 'node' do
  let(:repo) { Node.from_csv(File.join(__dir__, 'test.csv')) }

  context 'when loading nodes from a CSV file' do
    it 'creates a table of id and parent_id' do
      results = repo.client.execute <<~SQL
        SELECT COUNT(*), MIN(id), MAX(id) FROM nodes
      SQL
      expect(results).to eq [{ 'COUNT(*)' => 5, 'MAX(id)' => 5_497_637, 'MIN(id)' => 125 }]
    end
  end

  context 'when loading ancestors' do
    it 'returns all nodes to the parent' do
      ancestors = repo.ancestors(5_497_637)
      expect(ancestors.length).to eq 4
      expect(ancestors.first).to eq Node::AncestorResult.new(
        depth: 4,
        id: 5_497_637,
        parent_id: 4_430_546
      )
      expect(ancestors.last).to eq Node::AncestorResult.new(
        depth: 1,
        id: 130,
        parent_id: nil
      )
    end
  end

  context 'when comparing ancestors of two nodes' do
    it 'returns the common ancestor and root node' do
      common = repo.common_ancestor(5_497_637, 2_820_230)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq Node::AncestorResult.new(
        depth: 2,
        id: 125,
        parent_id: 130
      )

      common = repo.common_ancestor(5_497_637, 130)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq Node::AncestorResult.new(
        depth: 1,
        id: 130,
        parent_id: nil
      )

      common = repo.common_ancestor(5_497_637, 4_430_546)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq Node::AncestorResult.new(
        depth: 3,
        id: 4_430_546,
        parent_id: 125
      )

      common = repo.common_ancestor(9, 4_430_546)
      expect(common).to be_nil

      common = repo.common_ancestor(4_430_546, 4_430_546)
      expect(common.root_id).to eq 130
      expect(common.lowest).to eq Node::AncestorResult.new(
        depth: 3,
        id: 4_430_546,
        parent_id: 125
      )
    end
  end
end
