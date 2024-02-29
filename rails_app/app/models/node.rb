# frozen_string_literal: true

require 'csv'
require 'ostruct'

class Node < ApplicationRecord
  belongs_to :parent, class_name: 'Node', optional: true

  def self.from_csv(filename)
    CSV.foreach(filename, headers: true) do |row|
      create!(id: row['id'], parent_id: row['parent_id'])
    end
  end

  def self.ancestors(id)
    results = connection.select_all(<<~SQL, nil, [id], preparable: true).to_a
      WITH RECURSIVE ancestors AS (
        SELECT
          id,
          parent_id,
          1 AS depth
        FROM
          nodes
        WHERE
          id = $1
        UNION ALL
        SELECT
          n.id,
          n.parent_id,
          na.depth + 1
        FROM
          nodes n
          JOIN ancestors na ON n.id = na.parent_id
      ),
      max_depth AS (
        SELECT
          MAX(depth) as depth
        FROM
          ancestors
      )
      SELECT
        id,
        parent_id,
        (max_depth.depth - ancestors.depth + 1) as depth
      FROM
        ancestors,
        max_depth;
    SQL

    results.map { |result| OpenStruct.new(result) }
  end

  def self.common_ancestor(left, right)
    left_ancestors = ancestors(left)
    right_ancestors = ancestors(right)

    return unless left_ancestors.any? && right_ancestors.any?
    return unless left_ancestors&.last&.id == right_ancestors&.last&.id

    OpenStruct.new(
      root_id: left_ancestors.last.id,
      lowest: (left_ancestors & right_ancestors).first
    )
  end
end
