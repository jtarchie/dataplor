# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bird, type: :model do
  before do
    Node.from_csv(File.join(__dir__, '../assets/test.csv'))

    Node.all.each_with_index do |node, index|
      Bird.create!(id: index + 1, node_id: node.id)
    end
  end

  context 'when loading birds from a root node' do
    it 'returns all birds ids including decendants' do
      expect(Bird.ids_from_nodes([130])).to contain_exactly(2, 1, 3, 4, 5)
      expect(Bird.ids_from_nodes([125])).to contain_exactly(1, 3, 4, 5)
      expect(Bird.ids_from_nodes([4_430_546])).to contain_exactly(4, 5)
    end
  end

  context 'when loading birds from lead node' do
    it 'returns just that nodes bird id' do
      expect(Bird.ids_from_nodes([2_820_230])).to eq [3]
    end
  end

  context 'when loading birds from multiple nodes' do
    it 'returns all the birds with no duplicates' do
      expect(Bird.ids_from_nodes([2_820_230, 4_430_546])).to contain_exactly(3, 4, 5)
      expect(Bird.ids_from_nodes([130, 125])).to contain_exactly(1, 2, 3, 4, 5)
    end
  end
end
