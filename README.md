# Node & Bird Ancestry Library and API

A Rails and Sinatra-based interactive toolset and API designed for exploring
relationships in bird species node-tree data.

## Description

The Node & Bird Ancestry project includes two distinct codesets written in Rails
and Sinatra. Users can explore the ancestral relations of bird species through
node data, either via a Ruby library or REST API calls. Both codesets depend
upon a supplied CSV dataset and provide functionality to determine ancestral
lineage common ancestors and extract specific bird datasets.

The project covers some shared functionalities across both codesets:

- Loading nodes from CSV data.
- Determining the lineage of a node.
- Locating common ancestors between nodes.
- Retrieving bird datasets linked to specific nodes.

Both code sets have distinct usage patterns and processes.

## Usage

### For the Rails App:

Ensure that Rails is installed along with the required database configuration.
Use `bundle install` to install the necessary gems. Database migrations may need to
be run, such as `rails db:migrate,` to set up the tables used by models.

Example API request:

```shell
curl http://localhost:3000/birds?node_ids=[130]
```

It fetches bird data related to the node with an ID of 130.

#### RSpec Tests:

Unit and request tests are present for the models and request endpoints. They
can be run using the `bundle exec rspec <test_file_path>` command.

### For the Sinatra app:

Ensure Sinatra is installed along with other required gems via `bundle install`.
There is no database configuration required.

In the Sinatra app, APIs are invoked through URL parameters:

```shell
curl http://localhost:4567/common_ancestor?a=5497637&b=2820230
```

This will return the common ancestor for nodes 5497637 and 2820230.

#### RSpec Tests:

RSpec Tests can be run using the command `bundle exec rspec <test_file_path>`.
