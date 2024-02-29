# frozen_string_literal: true

require 'sqlite3'
require 'csv'

class Node
  def self.from_csv(filename)
    client = SQLite3::Database.new ':memory:'
    client.results_as_hash = true
    client.execute <<~SQL
      CREATE TABLE nodes (
        id INTEGER,
        parent_id INTEGER
      );
    SQL

    CSV.foreach(filename, headers: true) do |row|
      client.execute 'INSERT INTO nodes (id, parent_id) VALUES (:id, :parent_id)', row.to_h
    end

    Node.new(client)
  end

  attr_reader :client

  def initialize(client)
    @client = client
  end

  AncestorResult = Struct.new(:depth, :id, :parent_id, keyword_init: true)

  def ancestors(id)
    results = @client.execute(<<~SQL, { id: id })
      WITH RECURSIVE ancestors AS (
        SELECT
          id,
          parent_id,
          1 AS depth
        FROM
          nodes
        WHERE
          id = :id
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

    results.map { |result| AncestorResult.new(result) }
  end

  CommonAncestorResult = Struct.new(:root_id, :lowest, keyword_init: true)

  def common_ancestor(left, right)
    left_ancestors = ancestors(left)
    right_ancestors = ancestors(right)

    return unless left_ancestors&.last&.id == right_ancestors&.last&.id

    CommonAncestorResult.new(
      root_id: left_ancestors.last.id,
      lowest: (left_ancestors & right_ancestors).first
    )
  end
end
